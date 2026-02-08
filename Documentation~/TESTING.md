# 🧪 테스트 가이드 (Testing Guide)

OpenClaw Godot Plugin 테스트를 위한 상세 가이드입니다.

## 목차

1. [테스트 환경 설정](#테스트-환경-설정)
2. [수동 테스트](#수동-테스트)
3. [자동화 테스트](#자동화-테스트)
4. [도구별 테스트 케이스](#도구별-테스트-케이스)
5. [통합 테스트](#통합-테스트)
6. [성능 테스트](#성능-테스트)

---

## 테스트 환경 설정

### 1. 테스트 프로젝트 생성

```bash
# 테스트 전용 프로젝트
mkdir -p /Users/Shared/godot-test-project
cd /Users/Shared/godot-test-project

# 플러그인 복사
cp -r /Users/Shared/openclaw-godot-plugin/addons .

# project.godot 생성
cat > project.godot << 'EOF'
[gd_resource type="ProjectSettings" format=3]

[application]
config/name="OpenClaw Test Project"

[editor_plugins]
enabled=PackedStringArray("res://addons/openclaw/plugin.cfg")
EOF
```

### 2. Gateway 확장 설치

```bash
# 확장 설치
cp -r /Users/Shared/openclaw-godot-plugin/OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# Gateway 재시작
openclaw gateway restart

# 연결 확인
openclaw godot status
```

### 3. 테스트 씬 준비

Godot에서 테스트용 씬 생성:

**test_scene.tscn** (2D 테스트용):
```
Node2D (TestRoot)
├── Sprite2D (Player)
│   └── Camera2D (Cam)
├── Label (UI)
└── Area2D (TriggerZone)
```

**test_3d_scene.tscn** (3D 테스트용):
```
Node3D (Level)
├── CharacterBody3D (Player3D)
│   └── Camera3D (Cam3D)
├── MeshInstance3D (Ground)
└── DirectionalLight3D (Sun)
```

---

## 수동 테스트

### 연결 테스트

```bash
# 1. Gateway 상태 확인
openclaw gateway status

# 2. Godot 세션 목록
openclaw godot sessions
```

예상 출력:
```json
{
  "sessions": [
    {
      "sessionId": "godot_1234567890_abc123",
      "project": "OpenClaw Test Project",
      "version": "4.6-stable",
      "tools": 30
    }
  ]
}
```

### OpenClaw에서 직접 테스트

```
You: Godot 에디터 상태 확인해줘

OpenClaw:
[Executes editor.getState]

Godot 4.6-stable 실행 중
- 프로젝트: OpenClaw Test Project
- 현재 씬: res://test_scene.tscn
- 플레이 모드: 비활성
```

---

## 자동화 테스트

### 테스트 스크립트 (GDScript)

`addons/openclaw/tests/test_tools.gd`:

```gdscript
@tool
extends EditorScript

## OpenClaw Tools 자동 테스트
## 사용법: Script → Run (Ctrl+Shift+X)

var tools: Node
var passed = 0
var failed = 0
var results = []

func _run():
    print("\n" + "=".repeat(50))
    print("🧪 OpenClaw Tools Test Suite")
    print("=".repeat(50) + "\n")
    
    # Tools 인스턴스 생성
    var Tools = load("res://addons/openclaw/tools.gd")
    tools = Tools.new()
    tools.editor_interface = get_editor_interface()
    
    # 테스트 실행
    _test_editor_tools()
    _test_scene_tools()
    _test_node_tools()
    _test_transform_tools()
    _test_debug_tools()
    
    # 결과 출력
    _print_summary()
    
    # 정리
    tools.queue_free()

func _test_editor_tools():
    _section("Editor Tools")
    
    # editor.getState
    var state = tools.execute("editor.getState", {})
    _assert(state.success, "editor.getState returns success")
    _assert(state.has("version"), "editor.getState has version")
    _assert(state.has("isPlaying"), "editor.getState has isPlaying")

func _test_scene_tools():
    _section("Scene Tools")
    
    # scene.list
    var list = tools.execute("scene.list", {})
    _assert(list.success, "scene.list returns success")
    _assert(list.has("scenes"), "scene.list has scenes array")
    
    # scene.getCurrent
    var current = tools.execute("scene.getCurrent", {})
    _assert(current.success, "scene.getCurrent returns success")
    _assert(current.has("path"), "scene.getCurrent has path")
    
    # scene.create
    var created = tools.execute("scene.create", {
        "rootType": "Node2D",
        "name": "AutoTestScene"
    })
    _assert(created.success, "scene.create creates scene")
    _assert(created.path == "res://auto_test_scene.tscn", "scene.create correct path")
    
    # scene.save
    var saved = tools.execute("scene.save", {})
    _assert(saved.success, "scene.save saves scene")

func _test_node_tools():
    _section("Node Tools")
    
    # scene.create로 깨끗한 씬 생성
    tools.execute("scene.create", {"rootType": "Node2D", "name": "NodeTest"})
    
    # node.create
    var created = tools.execute("node.create", {
        "type": "Sprite2D",
        "name": "TestSprite"
    })
    _assert(created.success, "node.create creates node")
    _assert(created.name == "TestSprite", "node.create correct name")
    
    # node.find
    var found = tools.execute("node.find", {"name": "TestSprite"})
    _assert(found.success, "node.find finds node")
    _assert(found.nodes.size() > 0, "node.find returns results")
    
    # node.getData
    var data = tools.execute("node.getData", {"path": "TestSprite"})
    _assert(data.success, "node.getData returns data")
    _assert(data.data.type == "Sprite2D", "node.getData correct type")
    
    # node.setProperty
    var setProp = tools.execute("node.setProperty", {
        "path": "TestSprite",
        "property": "modulate",
        "value": {"r": 1.0, "g": 0.5, "b": 0.5, "a": 1.0}
    })
    _assert(setProp.success, "node.setProperty sets property")
    
    # node.getProperty
    var getProp = tools.execute("node.getProperty", {
        "path": "TestSprite",
        "property": "modulate"
    })
    _assert(getProp.success, "node.getProperty gets property")
    
    # node.delete
    var deleted = tools.execute("node.delete", {"path": "TestSprite"})
    _assert(deleted.success, "node.delete deletes node")
    
    # 삭제 확인
    var notFound = tools.execute("node.find", {"name": "TestSprite"})
    _assert(notFound.nodes.size() == 0, "node.delete confirmed")

func _test_transform_tools():
    _section("Transform Tools")
    
    # 테스트 노드 생성
    tools.execute("scene.create", {"rootType": "Node2D", "name": "TransformTest"})
    tools.execute("node.create", {"type": "Sprite2D", "name": "Mover"})
    
    # transform.setPosition
    var pos = tools.execute("transform.setPosition", {
        "path": "Mover",
        "x": 100,
        "y": 200
    })
    _assert(pos.success, "transform.setPosition works")
    
    # 위치 확인
    var data = tools.execute("node.getData", {"path": "Mover"})
    _assert(data.data.position.x == 100, "setPosition x correct")
    _assert(data.data.position.y == 200, "setPosition y correct")
    
    # transform.setRotation
    var rot = tools.execute("transform.setRotation", {
        "path": "Mover",
        "degrees": 45
    })
    _assert(rot.success, "transform.setRotation works")
    
    data = tools.execute("node.getData", {"path": "Mover"})
    _assert(abs(data.data.rotation - 45) < 0.1, "setRotation correct")
    
    # transform.setScale
    var scale = tools.execute("transform.setScale", {
        "path": "Mover",
        "x": 2.0,
        "y": 2.0
    })
    _assert(scale.success, "transform.setScale works")
    
    data = tools.execute("node.getData", {"path": "Mover"})
    _assert(data.data.scale.x == 2.0, "setScale x correct")
    _assert(data.data.scale.y == 2.0, "setScale y correct")

func _test_debug_tools():
    _section("Debug Tools")
    
    # debug.tree
    var tree = tools.execute("debug.tree", {})
    _assert(tree.success, "debug.tree returns success")
    _assert(tree.has("tree"), "debug.tree has tree string")
    
    # debug.log
    var log = tools.execute("debug.log", {"message": "Test log message"})
    _assert(log.success, "debug.log works")
    
    # debug.screenshot
    var screenshot = tools.execute("debug.screenshot", {})
    _assert(screenshot.success, "debug.screenshot works")
    _assert(screenshot.has("path"), "debug.screenshot returns path")
    
    # console.getLogs
    var logs = tools.execute("console.getLogs", {"limit": 10})
    _assert(logs.success, "console.getLogs works")
    _assert(logs.has("logs"), "console.getLogs has logs")

# 헬퍼 함수들
func _section(name: String):
    print("\n📦 %s" % name)
    print("-".repeat(40))

func _assert(condition: bool, message: String):
    if condition:
        passed += 1
        print("  ✅ %s" % message)
    else:
        failed += 1
        print("  ❌ %s" % message)
    results.append({"pass": condition, "message": message})

func _print_summary():
    print("\n" + "=".repeat(50))
    print("📊 Test Results")
    print("=".repeat(50))
    print("  Passed: %d" % passed)
    print("  Failed: %d" % failed)
    print("  Total:  %d" % (passed + failed))
    print("")
    
    if failed == 0:
        print("🎉 All tests passed!")
    else:
        print("⚠️  Some tests failed:")
        for r in results:
            if not r.pass:
                print("    - %s" % r.message)
```

### 테스트 실행

Godot에서:
1. `addons/openclaw/tests/test_tools.gd` 열기
2. **Script → Run** (Ctrl+Shift+X)

예상 출력:
```
==================================================
🧪 OpenClaw Tools Test Suite
==================================================

📦 Editor Tools
----------------------------------------
  ✅ editor.getState returns success
  ✅ editor.getState has version
  ✅ editor.getState has isPlaying

📦 Scene Tools
----------------------------------------
  ✅ scene.list returns success
  ...

==================================================
📊 Test Results
==================================================
  Passed: 28
  Failed: 0
  Total:  28

🎉 All tests passed!
```

---

## 도구별 테스트 케이스

### Scene Tools

| 도구 | 테스트 케이스 | 예상 결과 |
|------|-------------|-----------|
| `scene.getCurrent` | 씬 열린 상태에서 호출 | name, path, nodeCount 반환 |
| `scene.getCurrent` | 씬 없는 상태에서 호출 | success: false, 에러 메시지 |
| `scene.list` | 프로젝트에 씬 있을 때 | scenes 배열 반환 |
| `scene.open` | 존재하는 씬 경로 | 씬 열림, success: true |
| `scene.open` | 존재하지 않는 경로 | success: false, 에러 메시지 |
| `scene.save` | 수정된 씬 저장 | 파일 저장됨, success: true |
| `scene.create` | Node2D 루트로 생성 | 새 씬 생성, 경로 반환 |
| `scene.create` | Node3D 루트로 생성 | 3D 씬 생성 |
| `scene.create` | 중복 이름 | 덮어쓰기 또는 번호 추가 |

### Node Tools

| 도구 | 테스트 케이스 | 예상 결과 |
|------|-------------|-----------|
| `node.find` | 이름으로 검색 | 일치하는 노드 목록 |
| `node.find` | 타입으로 검색 | 해당 타입 노드 목록 |
| `node.find` | 그룹으로 검색 | 그룹 멤버 목록 |
| `node.find` | 없는 노드 검색 | 빈 배열 |
| `node.create` | Sprite2D 생성 | 노드 추가됨 |
| `node.create` | 부모 지정하여 생성 | 올바른 부모 아래 추가 |
| `node.delete` | 존재하는 노드 삭제 | 노드 제거됨 |
| `node.delete` | 루트 노드 삭제 시도 | 실패 또는 경고 |
| `node.setProperty` | Vector2 값 설정 | 딕셔너리→Vector2 변환 |
| `node.setProperty` | Color 값 설정 | RGBA 딕셔너리→Color 변환 |

### Input Tools (Play 모드)

| 도구 | 테스트 케이스 | 예상 결과 |
|------|-------------|-----------|
| `input.keyPress` | "W" 키 입력 | 키 이벤트 발생 |
| `input.keyDown` + `keyUp` | SHIFT 홀드 | 모디파이어 동작 |
| `input.mouseClick` | 좌클릭 (400, 300) | 클릭 이벤트 발생 |
| `input.mouseMove` | (0, 0) → (800, 600) | 마우스 이동 |
| `input.actionPress` | "jump" 액션 | 액션 매핑된 경우 동작 |
| `input.actionPress` | 없는 액션 | 경고 또는 무시 |

---

## 통합 테스트

### 시나리오 1: 씬 생성 워크플로우

```
1. scene.create {rootType: "Node2D", name: "Level1"}
2. node.create {type: "CharacterBody2D", name: "Player"}
3. node.create {type: "Camera2D", name: "Cam", parent: "Player"}
4. transform.setPosition {path: "Player", x: 400, y: 300}
5. scene.save
6. editor.play
7. input.keyPress {key: "W"}
8. debug.screenshot
9. editor.stop
```

예상 결과:
- Level1.tscn 생성됨
- Player → Cam 계층 구조
- 스크린샷에 (400, 300) 위치에 플레이어

### 시나리오 2: 디버깅 워크플로우

```
1. scene.open {path: "res://main.tscn"}
2. debug.tree
3. node.find {type: "Sprite2D"}
4. node.getData {path: "Player"}
5. console.getLogs {type: "error", limit: 20}
6. debug.screenshot
```

### 시나리오 3: Play 모드 안정성

```
1. editor.play
2. (30초 대기 - heartbeat 주기)
3. editor.getState  # 연결 유지 확인
4. input.keyPress {key: "ESCAPE"}
5. editor.stop
```

---

## 성능 테스트

### 연결 안정성

```bash
# 10분간 연결 유지 테스트
for i in {1..20}; do
    echo "Iteration $i"
    openclaw godot execute editor.getState
    sleep 30
done
```

### 명령 처리 속도

```gdscript
# tools.gd에 추가 (개발용)
var start_time: int

func execute(tool_name: String, args: Dictionary) -> Dictionary:
    start_time = Time.get_ticks_msec()
    
    var result = _execute_internal(tool_name, args)
    
    var elapsed = Time.get_ticks_msec() - start_time
    print("[OpenClaw] %s took %dms" % [tool_name, elapsed])
    
    return result
```

### 기대 성능

| 도구 | 예상 응답 시간 |
|------|--------------|
| editor.getState | < 10ms |
| scene.getCurrent | < 20ms |
| node.find | < 50ms (100개 노드) |
| debug.screenshot | < 200ms |
| scene.save | < 500ms |

---

## 테스트 체크리스트

### 릴리스 전 필수 테스트

- [ ] 플러그인 활성화/비활성화
- [ ] Gateway 연결/재연결
- [ ] 모든 30개 도구 기본 동작
- [ ] Play 모드 전환 시 연결 유지
- [ ] 30초+ 유휴 상태 후 명령 실행
- [ ] 에러 상황 시 적절한 메시지 반환
- [ ] 메모리 누수 없음 (장시간 실행)

### 엣지 케이스

- [ ] 빈 씬에서 node.getData
- [ ] 특수문자 포함 노드 이름
- [ ] 매우 깊은 노드 계층 (10+)
- [ ] 대용량 씬 (1000+ 노드)
- [ ] 동시 다중 명령
- [ ] Gateway 재시작 후 재연결

---

## 다음 단계

- [DEVELOPMENT.md](DEVELOPMENT.md) - 개발 가이드
- [CONTRIBUTING.md](CONTRIBUTING.md) - 기여 가이드

---

*문서 업데이트: 2026-02-08*
