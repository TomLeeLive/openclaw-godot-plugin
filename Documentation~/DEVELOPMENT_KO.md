# 🛠️ 개발 가이드 (Development Guide)

OpenClaw Godot Plugin 개발을 위한 상세 가이드입니다.

## 목차

1. [프로젝트 구조](#프로젝트-구조)
2. [개발 환경 설정](#개발-환경-설정)
3. [아키텍처 이해](#아키텍처-이해)
4. [새 도구 추가하기](#새-도구-추가하기)
5. [디버깅](#디버깅)
6. [코드 스타일](#코드-스타일)

---

## 프로젝트 구조

```
openclaw-godot-plugin/
├── addons/
│   └── openclaw/
│       ├── plugin.cfg          # 플러그인 메타데이터
│       ├── openclaw_plugin.gd  # 메인 EditorPlugin
│       ├── connection_manager.gd # HTTP 연결 관리
│       └── tools.gd            # 도구 실행 로직
├── OpenClawPlugin~/            # Gateway 확장 (TypeScript)
│   ├── index.ts                # 확장 진입점
│   ├── package.json
│   └── tsconfig.json
├── Documentation~/             # 문서 (Godot 제외됨)
│   ├── DEVELOPMENT.md
│   ├── TESTING.md
│   └── CONTRIBUTING.md
├── README.md
└── LICENSE
```

### 핵심 파일 설명

| 파일 | 역할 |
|------|------|
| `openclaw_plugin.gd` | EditorPlugin 진입점, UI 생성, 신호 연결 |
| `connection_manager.gd` | Gateway HTTP 통신 (register, poll, heartbeat) |
| `tools.gd` | 40개 도구 실행 로직 |
| `OpenClawPlugin~/index.ts` | Gateway 확장, `godot_execute` 도구 제공 |

---

## 개발 환경 설정

### 필수 요구사항

- **Godot 4.x** (4.2+ 권장)
- **Node.js 18+** (Gateway 확장 빌드용)
- **OpenClaw 2026.2.3+**

### 1. 저장소 클론

```bash
git clone https://github.com/TomLeeLive/openclaw-godot-plugin.git
cd openclaw-godot-plugin
```

### 2. 개발용 Godot 프로젝트 설정

```bash
# 테스트 프로젝트 생성
mkdir -p ~/godot-dev-project
cp -r addons ~/godot-dev-project/
```

Godot에서 프로젝트 열기:
1. `Project → Project Settings → Plugins`
2. **OpenClaw** 활성화

### 3. Gateway 확장 설치

```bash
# 확장 복사
cp -r OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# Gateway 재시작
openclaw gateway restart
```

### 4. 개발 모드 확인

Godot Output 패널에서 확인:
```
[OpenClaw] Plugin loading...
[OpenClaw] Plugin loaded!
[OpenClaw] Registering with gateway...
[OpenClaw] Registered! Session: godot_xxxxx
```

---

## 아키텍처 이해

### 통신 흐름

```
┌──────────────────┐     HTTP      ┌──────────────────┐
│   Godot Editor   │◄────────────►│  OpenClaw Gateway │
│                  │              │   (port 18789)    │
│  ┌────────────┐  │              │                   │
│  │ Connection │  │  /register   │  ┌─────────────┐  │
│  │  Manager   │──┼──────────────┼─►│   Sessions  │  │
│  └────────────┘  │              │  └─────────────┘  │
│        │         │  /poll       │        │          │
│        ▼         │◄─────────────┼────────┘          │
│  ┌────────────┐  │              │                   │
│  │   Tools    │  │  /result     │  ┌─────────────┐  │
│  └────────────┘──┼──────────────┼─►│   Claude    │  │
│                  │              │  └─────────────┘  │
└──────────────────┘              └───────────────────┘
```

### 1. 등록 (Register)

플러그인 로드 시 Gateway에 세션 등록:

```gdscript
# connection_manager.gd
func _register():
    var body = {
        "project": ProjectSettings.get_setting("application/config/name"),
        "version": Engine.get_version_info().string,
        "platform": "GodotEditor",
        "tools": _get_tool_list()
    }
    _http_post("/godot/register", body, _on_register_complete)
```

### 2. 폴링 (Poll)

명령 대기 (Long polling, 30초 타임아웃):

```gdscript
func _poll():
    if is_polling:
        return  # 중복 요청 방지
    is_polling = true
    _http_get("/godot/poll?sessionId=" + session_id, _on_poll_complete)
```

### 3. 명령 실행 및 결과 전송

```gdscript
func _on_command_received(tool_call_id: String, tool_name: String, args: Dictionary):
    var result = tools.execute(tool_name, args)
    connection_manager.send_result(tool_call_id, result)
```

### Play 모드 유지

`PROCESS_MODE_ALWAYS` 설정으로 Play 모드에서도 연결 유지:

```gdscript
func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS  # 핵심!
```

---

## 새 도구 추가하기

### 예제: `audio.play` 도구 추가

오디오 파일을 재생하는 도구를 추가해보겠습니다.

#### Step 1: tools.gd에 도구 등록

```gdscript
# tools.gd 상단 TOOLS 배열에 추가

var TOOLS = [
    # ... 기존 도구들 ...
    
    # 새 도구 추가
    {
        "name": "audio.play",
        "description": "Play an audio file in the editor",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Resource path to audio file (e.g., res://sounds/bgm.ogg)"
                },
                "volume": {
                    "type": "number",
                    "description": "Volume in dB (default: 0)"
                }
            },
            "required": ["path"]
        }
    }
]
```

#### Step 2: execute() 함수에 핸들러 추가

```gdscript
func execute(tool_name: String, args: Dictionary) -> Dictionary:
    match tool_name:
        # ... 기존 케이스들 ...
        
        "audio.play":
            return _audio_play(args)
        
        _:
            return {"success": false, "error": "Unknown tool: " + tool_name}
```

#### Step 3: 핸들러 함수 구현

```gdscript
func _audio_play(args: Dictionary) -> Dictionary:
    var path = args.get("path", "")
    var volume = args.get("volume", 0.0)
    
    # 리소스 존재 확인
    if not ResourceLoader.exists(path):
        return {"success": false, "error": "Audio file not found: " + path}
    
    # 오디오 스트림 로드
    var stream = load(path) as AudioStream
    if stream == null:
        return {"success": false, "error": "Invalid audio file: " + path}
    
    # AudioStreamPlayer 생성 및 재생
    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = volume
    
    # 에디터 루트에 추가
    editor_interface.get_base_control().add_child(player)
    player.play()
    
    # 재생 완료 후 자동 삭제
    player.finished.connect(func(): player.queue_free())
    
    return {
        "success": true,
        "path": path,
        "duration": stream.get_length()
    }
```

#### Step 4: Gateway 확장 업데이트 (선택)

`OpenClawPlugin~/index.ts`의 도구 목록은 Godot에서 자동 전송되므로 수정 불필요.
단, 도구 설명을 개선하려면:

```typescript
// index.ts - tools 배열에 추가 (선택적)
{
  name: "audio.play",
  description: "Play audio file in Godot Editor",
  inputSchema: {
    type: "object",
    properties: {
      path: { type: "string", description: "Audio resource path" },
      volume: { type: "number", description: "Volume in dB" }
    },
    required: ["path"]
  }
}
```

#### Step 5: 테스트

```bash
# Gateway 재시작
openclaw gateway restart
```

OpenClaw에서 테스트:
```
You: Play the background music

OpenClaw:
[Executes audio.play {path: "res://audio/bgm.ogg", volume: -5}]

Playing bgm.ogg (duration: 180.5s)
```

---

## 디버깅

### 1. Godot Output 패널

플러그인 로그 확인:
```
[OpenClaw] Plugin loading...
[OpenClaw] Command: scene.getCurrent
[OpenClaw] Error: Node not found
```

### 2. print_debug() 사용

```gdscript
func _some_function():
    print_debug("Debug: ", some_variable)  # 파일명/라인 포함
```

### 3. Gateway 로그 확인

```bash
# Gateway 로그 실시간 확인
tail -f ~/.openclaw/logs/gateway.log
```

### 4. HTTP 요청 디버깅

```gdscript
# connection_manager.gd에 추가
func _http_post(endpoint: String, body: Dictionary, callback: Callable):
    print("[OpenClaw] POST %s: %s" % [endpoint, JSON.stringify(body)])
    # ... 기존 코드 ...
```

### 5. 일반적인 문제 해결

| 문제 | 원인 | 해결 |
|------|------|------|
| 플러그인 로드 안됨 | GDScript 문법 오류 | Output 패널 확인, 문법 수정 |
| 연결 실패 | Gateway 미실행 | `openclaw gateway start` |
| 도구 실행 안됨 | 도구명 불일치 | TOOLS 배열과 match 문 확인 |
| Play 모드 연결 끊김 | PROCESS_MODE 미설정 | `process_mode = PROCESS_MODE_ALWAYS` |
| HTTP 요청 중복 | 플래그 미확인 | `is_polling` 플래그 사용 |

---

## 코드 스타일

### GDScript 컨벤션

```gdscript
# 클래스 선언
class_name MyClass
extends Node

## 문서 주석 (Ctrl+Shift+D로 표시)
## @param value: 설정할 값
## @return: 성공 여부
func my_function(value: String) -> bool:
    # 상수는 UPPER_SNAKE_CASE
    const MAX_RETRIES = 3
    
    # 변수는 snake_case
    var retry_count = 0
    
    # 명시적 타입 사용
    var result: Dictionary = {}
    
    # 조기 반환 패턴
    if value.is_empty():
        return false
    
    return true

# private 함수는 _ 접두사
func _internal_helper():
    pass

# 시그널은 과거형
signal connection_changed(connected: bool)
signal command_received(tool_call_id: String, tool_name: String)
```

### 에러 처리 패턴

```gdscript
func _safe_operation() -> Dictionary:
    # 항상 success 필드 포함
    if some_error_condition:
        return {"success": false, "error": "Error message"}
    
    return {
        "success": true,
        "data": some_data
    }
```

### 비동기 처리

```gdscript
# HTTPRequest 완료 대기
func _make_request():
    var http = HTTPRequest.new()
    add_child(http)
    
    http.request_completed.connect(_on_request_completed)
    http.request("http://localhost:18789/endpoint")

func _on_request_completed(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
    if result != HTTPRequest.RESULT_SUCCESS:
        push_error("Request failed")
        return
    
    var json = JSON.parse_string(body.get_string_from_utf8())
    # 처리...
```

---

## 다음 단계

- [TESTING.md](TESTING.md) - 테스트 가이드
- [CONTRIBUTING.md](CONTRIBUTING.md) - 기여 가이드

---

*문서 업데이트: 2026-02-08*
