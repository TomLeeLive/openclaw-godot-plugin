# OpenClaw Godot 플러그인 - 셋업 가이드

이 가이드는 다양한 사용 사례에 맞게 OpenClaw Godot 플러그인을 설정하는 방법을 설명합니다.

## 🎯 이게 뭔가요?

OpenClaw Godot 플러그인은 Godot 에디터를 AI 어시스턴트에 연결하여 **AI 기반 게임 개발**을 가능하게 합니다. 마치 다음과 같은 일을 할 수 있는 코딩 파트너가 생긴 것과 같습니다:

- 씬 트리 검사 및 수정
- 노드 생성, 트랜스폼 조정, 속성 설정
- 게임 실행 및 입력 시뮬레이션
- 스크린샷 촬영 및 로그 읽기
- 모두 자연스러운 대화로!

## 🤔 어떤 모드가 필요한가요?

설정을 시작하기 전에, 어떤 모드가 본인의 워크플로우에 맞는지 이해하세요:

| AI 사용 방법 | 필요한 모드 | 이유 |
|-------------|------------|-----|
| **채팅 앱** (Telegram, Discord) | 모드 A: Gateway | OpenClaw가 명령을 Godot으로 라우팅 |
| **Claude Code** 터미널에서 | 모드 B: MCP | 직접 연결 필요 |
| **Cursor / VS Code** | 모드 B: MCP | 직접 연결 필요 |
| **Claude Desktop** 앱 | 모드 B: MCP | 직접 연결 필요 |
| **둘 다** | 하이브리드 | 양쪽의 장점 모두 |

### 이미 OpenClaw를 사용 중이라면...

OpenClaw를 통해 AI 어시스턴트와 채팅 중이라면 (Telegram이나 Discord 등), **MCP 설정이 필요 없습니다** - 어시스턴트가 이미 Gateway를 통해 Godot 도구에 접근할 수 있습니다!

```
You (Telegram) → OpenClaw Gateway → AI 어시스턴트 → godot_execute 도구 → Godot
                                    ↑
                            이미 접근 가능!
```

### MCP가 유용한 경우

MCP (Model Context Protocol)가 유용한 경우:
1. **터미널에서 Claude Code를 직접 사용** (OpenClaw를 통하지 않고)
2. **Claude Desktop** 앱 사용
3. **Cursor** 또는 기타 MCP 호환 에디터 사용
4. OpenClaw에서 **Claude Code를 서브 에이전트로 스폰**하여 코딩 + 테스팅 워크플로우

```
# MCP 없이:
$ claude
> Godot 제어해줘  →  ❌ 사용 가능한 도구 없음

# MCP 있으면:
$ claude
> Godot 제어해줘  →  ✅ godot.* 도구 사용 가능
```

---

## 🅰️ 모드 A: OpenClaw Gateway (원격 접근)

**사용 시기:** Telegram, Discord, 웹을 통해 원격으로 게임을 개발하고 싶을 때.

### 사전 요구사항

- Node.js 18+
- Godot 4.x
- OpenClaw 설치 (`npm install -g openclaw`)

### 설정 단계

#### 1단계: OpenClaw Gateway 설치

```bash
# OpenClaw 전역 설치
npm install -g openclaw

# 설정 초기화 (처음만)
openclaw init

# Gateway 시작
openclaw gateway start
```

#### 2단계: Gateway Extension 설치

Extension은 OpenClaw에서 `godot_execute`와 `godot_sessions` 도구를 활성화합니다.

```bash
# 플러그인 저장소 클론
git clone https://github.com/TomLeeLive/openclaw-godot-plugin.git

# Extension 파일을 OpenClaw에 복사
cp -r openclaw-godot-plugin/OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# Gateway 재시작하여 Extension 로드
openclaw gateway restart

# 설치 확인
openclaw godot status
```

#### 3단계: Godot 플러그인 설치

1. `addons/openclaw` 폴더를 Godot 프로젝트의 `addons/` 디렉토리에 복사
2. Godot에서 프로젝트 열기
3. 플러그인 활성화: `Project → Project Settings → Plugins → OpenClaw → Enable`
4. 플러그인이 자동으로 OpenClaw Gateway에 연결됨

#### 4단계: 연결 확인

1. Output 패널에서 확인: `[OpenClaw] Connected to Gateway`
2. 또는 실행: `openclaw godot sessions`로 Godot 인스턴스 확인

#### 5단계: 채팅 통합 설정 (선택)

Telegram, Discord 또는 기타 채팅 플랫폼 설정:

```bash
openclaw config
```

### 아키텍처

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│  Telegram/   │ ───→ │    OpenClaw     │ ───→ │    Godot     │
│  Discord/웹  │ ←─── │    Gateway      │ ←─── │    에디터    │
└──────────────┘      └─────────────────┘      └──────────────┘
     핸드폰              내 컴퓨터              내 컴퓨터
   (어디서든)           (port 18789)          (HTTP polling)
```

### 사용 예시

카페에서 핸드폰으로:
```
You: "현재 씬에 뭐가 있어?"
AI: TestScene3D에는: Player (CharacterBody3D), Camera3D, DirectionalLight3D

You: "위치 10, 0, 5에 적 추가해"
AI: [Node3D "Enemy"를 (10, 0, 5)에 생성]
    완료! Enemy가 생성되었습니다.

You: "게임 실행하고 스크린샷 찍어"
AI: [씬 실행, 스크린샷 캡처]
    게임플레이 스크린샷입니다.
```

---

## 🅱️ 모드 B: MCP Direct (로컬 개발)

**사용 시기:** Claude Code, Claude Desktop, Cursor를 사용하여 Godot을 직접 제어하고 싶을 때.

### 사전 요구사항

- Node.js 18+
- Godot 4.x
- Claude Code 또는 MCP 호환 클라이언트

### 설정 단계

#### 1단계: Godot 플러그인 설치

모드 A의 3단계와 동일:
1. `addons/openclaw`을 프로젝트의 `addons/` 폴더에 복사
2. 활성화: `Project → Project Settings → Plugins → OpenClaw → Enable`

#### 2단계: MCP 서버 의존성 설치

```bash
# MCP 서버 디렉토리로 이동
cd /path/to/openclaw-godot-plugin/MCP~

# 의존성 설치
npm install
```

#### 3단계: MCP 서버 등록

**Claude Code의 경우:**
```bash
claude mcp add godot -- node /full/path/to/openclaw-godot-plugin/MCP~/index.js
```

**Claude Desktop의 경우:**

`~/Library/Application Support/Claude/claude_desktop_config.json` (Mac) 또는 `%APPDATA%\Claude\claude_desktop_config.json` (Windows) 편집:

```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/full/path/to/openclaw-godot-plugin/MCP~/index.js"]
    }
  }
}
```

**Cursor의 경우:**

`.cursor/mcp.json` 편집:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/full/path/to/openclaw-godot-plugin/MCP~/index.js"]
    }
  }
}
```

#### 4단계: Godot에서 MCP Bridge 활성화

1. Godot 프로젝트 열기
2. MCP Bridge는 플러그인과 함께 자동 시작됨
3. 기본 포트: 27183

#### 5단계: Claude Code 사용

```bash
$ claude

> 프로젝트의 모든 씬 목록 보여줘
AI: 5개 씬 발견: main.tscn, player.tscn, enemy.tscn, level1.tscn, ui.tscn

> CharacterBody2D 노드 "Player"를 Sprite2D 자식과 함께 생성해
AI: [CharacterBody2D "Player" 생성]
    [Sprite2D를 "Player" 아래에 생성]
    완료! Player 노드와 Sprite2D 자식이 생성되었습니다.

> 게임 실행하고 W 키 눌러
AI: [게임 시작]
    [W 키 누름 시뮬레이션]
    게임이 W 키가 눌린 상태로 실행 중입니다.
```

### 아키텍처

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│ Claude Code  │ ───→ │   MCP 서버      │ ───→ │    Godot     │
│ / Desktop    │ ←─── │   (Node.js)     │ ←─── │    에디터    │
│ / Cursor     │      │                 │      │              │
└──────────────┘      └─────────────────┘      └──────────────┘
    터미널              localhost:27183        localhost:27183
```

---

## 🔀 하이브리드 모드 (둘 다)

두 모드를 충돌 없이 동시에 실행할 수 있습니다!

```
집에서:   Claude Code → MCP → Godot (로컬, 빠름)
외출시:   Telegram → OpenClaw Gateway → Godot (원격)
```

### 포트 설정

| 서비스 | 기본 포트 | 설명 |
|--------|----------|------|
| MCP Bridge | 27183 | Claude Code / Desktop / Cursor용 |
| OpenClaw Gateway | 18789 | Telegram / Discord / Web용 |

---

## 🔧 설정

### Gateway URL 변경

`addons/openclaw/connection_manager.gd` 편집:
```gdscript
const GATEWAY_URL = "http://localhost:18789"  # 필요시 변경
```

### MCP 포트 변경

`addons/openclaw/mcp_bridge.gd` 편집:
```gdscript
const MCP_PORT = 27183  # 필요시 변경
```

---

## 🛠️ 문제 해결

### 플러그인이 로드되지 않음

1. Godot 버전 확인 (4.x 필요)
2. Output 패널에서 파싱 에러 확인
3. `addons/openclaw/`에 모든 `.gd` 파일이 있는지 확인

### Gateway 연결 문제

1. Gateway 실행 확인: `openclaw gateway status`
2. URL 일치 확인: 기본값 `http://localhost:18789`
3. Output 패널에서 `[OpenClaw]` 메시지 확인
4. Extension 설치 확인: `ls ~/.openclaw/extensions/godot/`

### MCP 연결 문제

1. MCP 서버 등록 확인: `claude mcp list`
2. 경로가 절대 경로인지 확인 (상대 경로 아님)
3. Godot Output에서 `[MCP Bridge]` 메시지 확인
4. 포트 27183 사용 중인지 확인: `lsof -i :27183`

### 입력 시뮬레이션이 작동하지 않음

1. 입력 시뮬레이션은 Play 모드에서만 작동
2. 게임 창에 포커스가 있는지 확인
3. 액션의 경우 Input Map에 액션이 있는지 확인

### Play 모드에서 연결이 끊김

1. 플러그인은 `PROCESS_MODE_ALWAYS`를 사용하여 Play 중에도 활성 유지
2. Heartbeat 간격은 30초
3. 연결이 끊기면 플러그인이 자동 재연결

---

## 📋 빠른 참조

| 작업 | 명령어 |
|------|--------|
| Gateway 시작 | `openclaw gateway start` |
| Gateway 중지 | `openclaw gateway stop` |
| Gateway 상태 확인 | `openclaw gateway status` |
| Godot 세션 확인 | `openclaw godot sessions` |
| Claude Code에 MCP 추가 | `claude mcp add godot -- node /path/to/MCP~/index.js` |
| MCP 서버 목록 | `claude mcp list` |

---

## 📖 다음 단계

- [DEVELOPMENT.md](DEVELOPMENT.md) - 기여자용
- [TESTING.md](TESTING.md) - 테스팅 가이드
- [CONTRIBUTING.md](CONTRIBUTING.md) - 기여 방법

---

🦞 OpenClaw 커뮤니티가 만들었습니다
