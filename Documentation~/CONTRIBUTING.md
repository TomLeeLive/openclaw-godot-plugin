# 🤝 기여 가이드 (Contributing Guide)

OpenClaw Godot Plugin에 기여해 주셔서 감사합니다!

## 목차

1. [기여 방법](#기여-방법)
2. [개발 환경 설정](#개발-환경-설정)
3. [코드 기여](#코드-기여)
4. [Pull Request 가이드](#pull-request-가이드)
5. [이슈 리포팅](#이슈-리포팅)
6. [코드 리뷰 프로세스](#코드-리뷰-프로세스)
7. [커뮤니티 가이드라인](#커뮤니티-가이드라인)

---

## 기여 방법

### 기여할 수 있는 영역

| 영역 | 설명 | 난이도 |
|------|------|--------|
| 🐛 버그 수정 | 이슈 해결, 안정성 개선 | ⭐ |
| 📝 문서화 | README, 예제, 번역 | ⭐ |
| 🔧 새 도구 추가 | tools.gd에 기능 추가 | ⭐⭐ |
| ⚡ 성능 개선 | 최적화, 메모리 관리 | ⭐⭐⭐ |
| 🏗️ 아키텍처 | 핵심 구조 변경 | ⭐⭐⭐ |

### 처음 기여자를 위한 추천 이슈

GitHub에서 `good first issue` 라벨 확인:

```
https://github.com/TomLeeLive/openclaw-godot-plugin/labels/good%20first%20issue
```

---

## 개발 환경 설정

### 1. 저장소 Fork & Clone

```bash
# 1. GitHub에서 Fork

# 2. Clone
git clone https://github.com/YOUR_USERNAME/openclaw-godot-plugin.git
cd openclaw-godot-plugin

# 3. 원본 저장소 추가
git remote add upstream https://github.com/TomLeeLive/openclaw-godot-plugin.git
```

### 2. 테스트 환경 구성

```bash
# 테스트 Godot 프로젝트 생성
mkdir -p ~/godot-dev
cp -r addons ~/godot-dev/

# Gateway 확장 설치
cp -r OpenClawPlugin~/* ~/.openclaw/extensions/godot/
openclaw gateway restart
```

### 3. 브랜치 전략

```bash
# 기능 개발
git checkout -b feature/audio-tools

# 버그 수정
git checkout -b fix/connection-timeout

# 문서
git checkout -b docs/korean-translation
```

---

## 코드 기여

### 예제 1: 새 도구 추가 (`animation.play`)

#### Step 1: 이슈 확인/생성

```markdown
## Feature Request: animation.play tool

### 설명
AnimationPlayer 노드를 제어하는 도구

### 사용 사례
- AI가 캐릭터 애니메이션 테스트
- 시네마틱 시퀀스 미리보기

### 제안 API
animation.play {path: "Player/AnimationPlayer", animation: "walk"}
animation.stop {path: "Player/AnimationPlayer"}
animation.list {path: "Player/AnimationPlayer"}
```

#### Step 2: 구현

`addons/openclaw/tools.gd`:

```gdscript
# TOOLS 배열에 추가
var TOOLS = [
    # ... 기존 도구 ...
    
    {
        "name": "animation.play",
        "description": "Play an animation on AnimationPlayer",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "Path to AnimationPlayer node"},
                "animation": {"type": "string", "description": "Animation name to play"},
                "speed": {"type": "number", "description": "Playback speed (default: 1.0)"}
            },
            "required": ["path", "animation"]
        }
    },
    {
        "name": "animation.stop",
        "description": "Stop animation on AnimationPlayer",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "Path to AnimationPlayer node"}
            },
            "required": ["path"]
        }
    },
    {
        "name": "animation.list",
        "description": "List available animations",
        "inputSchema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "Path to AnimationPlayer node"}
            },
            "required": ["path"]
        }
    }
]

# execute 함수에 핸들러 추가
func execute(tool_name: String, args: Dictionary) -> Dictionary:
    match tool_name:
        # ... 기존 케이스 ...
        "animation.play": return _animation_play(args)
        "animation.stop": return _animation_stop(args)
        "animation.list": return _animation_list(args)

# 구현
func _animation_play(args: Dictionary) -> Dictionary:
    var path = args.get("path", "")
    var animation = args.get("animation", "")
    var speed = args.get("speed", 1.0)
    
    var node = _find_node_by_path(path)
    if node == null:
        return {"success": false, "error": "Node not found: " + path}
    
    if not node is AnimationPlayer:
        return {"success": false, "error": "Node is not AnimationPlayer: " + path}
    
    var player = node as AnimationPlayer
    
    if not player.has_animation(animation):
        return {"success": false, "error": "Animation not found: " + animation}
    
    player.speed_scale = speed
    player.play(animation)
    
    return {
        "success": true,
        "animation": animation,
        "duration": player.get_animation(animation).length,
        "speed": speed
    }

func _animation_stop(args: Dictionary) -> Dictionary:
    var path = args.get("path", "")
    
    var node = _find_node_by_path(path)
    if node == null:
        return {"success": false, "error": "Node not found: " + path}
    
    if not node is AnimationPlayer:
        return {"success": false, "error": "Node is not AnimationPlayer"}
    
    (node as AnimationPlayer).stop()
    
    return {"success": true}

func _animation_list(args: Dictionary) -> Dictionary:
    var path = args.get("path", "")
    
    var node = _find_node_by_path(path)
    if node == null:
        return {"success": false, "error": "Node not found: " + path}
    
    if not node is AnimationPlayer:
        return {"success": false, "error": "Node is not AnimationPlayer"}
    
    var player = node as AnimationPlayer
    var animations = []
    
    for anim_name in player.get_animation_list():
        var anim = player.get_animation(anim_name)
        animations.append({
            "name": anim_name,
            "duration": anim.length,
            "loop": anim.loop_mode != Animation.LOOP_NONE
        })
    
    return {
        "success": true,
        "animations": animations,
        "current": player.current_animation
    }
```

#### Step 3: 테스트 작성

```gdscript
# test_tools.gd에 추가
func _test_animation_tools():
    _section("Animation Tools")
    
    # 테스트 씬 준비
    tools.execute("scene.create", {"rootType": "Node2D", "name": "AnimTest"})
    
    # AnimationPlayer 생성 (수동으로 해야 함)
    # 또는 기존 프로젝트의 AnimationPlayer 사용
    
    # animation.list
    var list = tools.execute("animation.list", {
        "path": "AnimationPlayer"  # 실제 경로로 변경
    })
    # _assert(list.success, "animation.list works")
    
    # animation.play
    # animation.stop
```

#### Step 4: 문서 업데이트

`README.md`에 추가:

```markdown
### Animation Tools (3) - NEW
| Tool | Description |
|------|-------------|
| `animation.play` | Play animation on AnimationPlayer |
| `animation.stop` | Stop current animation |
| `animation.list` | List available animations |
```

---

### 예제 2: 버그 수정 (연결 타임아웃)

#### 이슈 분석

```markdown
## Bug: Connection timeout after 60 seconds of inactivity

### 재현 단계
1. 플러그인 활성화
2. 60초 동안 아무 명령 없음
3. 이후 명령 실행 시 타임아웃

### 예상 동작
연결이 유지되어야 함

### 환경
- Godot 4.6
- OpenClaw 2026.2.3
```

#### 수정

`connection_manager.gd`:

```gdscript
# 문제: heartbeat 간격이 너무 김
const HEARTBEAT_INTERVAL = 60.0  # 60초 (너무 김)

# 수정: 30초로 단축
const HEARTBEAT_INTERVAL = 30.0  # 30초

# 추가: 재연결 로직 개선
func _on_heartbeat_timeout():
    if not is_connected_flag:
        # 재연결 시도
        _reconnect()
        return
    
    _send_heartbeat()

func _reconnect():
    print("[OpenClaw] Attempting to reconnect...")
    _register()
```

#### 테스트

```bash
# 70초 대기 후 명령 실행
sleep 70
openclaw godot execute editor.getState
# 성공해야 함
```

---

## Pull Request 가이드

### PR 템플릿

```markdown
## 변경 사항

<!-- 무엇을 변경했는지 설명 -->
AnimationPlayer를 제어하는 3개의 새 도구 추가

## 관련 이슈

Fixes #42

## 변경 유형

- [x] 새 기능 (New feature)
- [ ] 버그 수정 (Bug fix)
- [ ] 문서 (Documentation)
- [ ] 리팩토링 (Refactoring)

## 테스트

- [x] Godot 4.6에서 테스트 완료
- [x] 기존 도구 동작 확인
- [x] 새 도구 정상 작동 확인

## 체크리스트

- [x] 코드 스타일 준수
- [x] 문서 업데이트
- [x] 테스트 추가/업데이트
- [ ] Breaking change 없음

## 스크린샷 (해당 시)

<!-- UI 변경 시 스크린샷 첨부 -->
```

### 좋은 커밋 메시지

```bash
# 기능 추가
feat(tools): add animation.play, animation.stop, animation.list tools

# 버그 수정
fix(connection): reduce heartbeat interval to 30s to prevent timeout

# 문서
docs(readme): add animation tools to feature list

# 리팩토링
refactor(tools): extract common node finding logic

# 스타일/포맷
style(tools): apply consistent indentation
```

### Conventional Commits 형식

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 이슈 리포팅

### 버그 리포트

```markdown
## 버그 설명

<!-- 무엇이 잘못되었는지 명확하게 설명 -->

## 재현 단계

1. '...' 이동
2. '...' 클릭
3. '...' 스크롤
4. 오류 발생

## 예상 동작

<!-- 정상적으로 어떻게 동작해야 하는지 -->

## 실제 동작

<!-- 실제로 어떻게 동작하는지 -->

## 환경

- OS: macOS 15.3
- Godot: 4.6-stable
- OpenClaw: 2026.2.3
- Plugin version: 1.1.0

## 로그

```
[OpenClaw] Error: ...
```

## 스크린샷

<!-- 해당 시 첨부 -->
```

### 기능 요청

```markdown
## 기능 설명

<!-- 원하는 기능 설명 -->

## 사용 사례

<!-- 이 기능이 필요한 이유 -->

## 제안 API

<!-- 가능하다면 API 형태 제안 -->
```gdscript
animation.play {path: "...", animation: "walk"}
```

## 대안

<!-- 현재 어떻게 해결하고 있는지 -->
```

---

## 코드 리뷰 프로세스

### 리뷰어 체크리스트

- [ ] 코드가 목적에 맞게 동작하는가?
- [ ] 테스트가 충분한가?
- [ ] 문서가 업데이트되었는가?
- [ ] 코드 스타일이 일관적인가?
- [ ] 에러 처리가 적절한가?
- [ ] 성능 문제가 없는가?
- [ ] 보안 문제가 없는가?

### 리뷰 코멘트 예시

```markdown
# 긍정적
✅ LGTM! 깔끔한 구현입니다.

# 제안
💡 여기서 `is` 대신 `is_instance_of()`를 사용하면 더 안전합니다.

# 요청
⚠️ 이 경우 null 체크가 필요합니다.

# 질문
❓ 이 상수값의 근거가 있나요?
```

---

## 커뮤니티 가이드라인

### 행동 강령

- 🤝 존중하는 태도로 소통
- 🌍 다양한 배경과 경험 존중
- 📚 건설적인 피드백 제공
- 🚫 차별, 괴롭힘 금지

### 소통 채널

- **GitHub Issues**: 버그, 기능 요청
- **GitHub Discussions**: 질문, 아이디어
- **Discord**: [OpenClaw Community](https://discord.com/invite/clawd)

### 응답 시간

- 이슈: 1-3일 내 응답
- PR: 1주일 내 첫 리뷰
- 긴급 버그: 가능한 빨리

---

## 라이선스

기여하신 코드는 MIT 라이선스 하에 배포됩니다.

---

## 감사합니다! 🙏

모든 기여에 감사드립니다. 작은 오타 수정도 큰 도움이 됩니다!

질문이 있으시면 언제든 이슈를 열어주세요.

---

*문서 업데이트: 2026-02-08*
