# 🐾 OpenClaw Godot Plugin

Godot 4.x를 HTTP를 통해 [OpenClaw](https://github.com/openclaw/openclaw) AI 어시스턴트에 연결합니다.

[![Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine)](https://godotengine.org)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.2.3+-green)](https://github.com/openclaw/openclaw)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?logo=buy-me-a-coffee)](https://buymeacoffee.com/tomleelive)

## ✨ 기능

- 🎬 **씬 관리** - 씬 생성, 열기, 저장, 검사
- 🔧 **노드 조작** - 노드 생성, 찾기, 수정, 삭제
- 🎮 **입력 시뮬레이션** - 게임 테스트를 위한 키보드, 마우스, 액션 입력
- 📸 **디버그 도구** - 스크린샷, 씬 트리 뷰, 콘솔 로그
- 🎯 **에디터 제어** - 씬 플레이, 정지, 일시정지
- 📜 **스크립트 접근** - GDScript 파일 목록 조회 및 읽기
- 🔄 **Play 모드 안정성** - Play 모드 중 연결 유지

## 요구사항

| 컴포넌트 | 버전 |
|----------|------|
| **Godot** | 4.x |
| **OpenClaw** | 2026.2.3+ |

## 설치

### 1. OpenClaw Gateway 확장 설치 (필수)

Gateway 확장 파일을 OpenClaw에 복사:

```bash
# 확장 파일 복사
cp -r OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# 확장을 로드하기 위해 gateway 재시작
openclaw gateway restart

# 확인
openclaw godot status
```

> **참고:** `OpenClawPlugin~`에는 `godot_execute`와 `godot_sessions` 도구를 활성화하는 gateway 확장이 포함되어 있습니다.

### 2. Godot 플러그인 설치

1. `addons/openclaw` 폴더를 프로젝트의 `addons/` 디렉토리에 복사
2. 플러그인 활성화: `Project → Project Settings → Plugins → OpenClaw → Enable`
3. 플러그인이 OpenClaw Gateway에 자동 연결됩니다

### 3. OpenClaw Skill 설치 (선택)

```bash
git clone https://github.com/TomLeeLive/openclaw-godot-skill.git ~/.openclaw/workspace/skills/godot-plugin
```

## 사용 가능한 도구 (30개 도구, 80+ 노드 타입)

### Scene 도구 (5개)
| 도구 | 설명 |
|------|------|
| `scene.getCurrent` | 현재 씬 정보 가져오기 |
| `scene.list` | 프로젝트의 모든 씬 목록 |
| `scene.open` | 경로로 씬 열기 |
| `scene.save` | 현재 씬 저장 |
| `scene.create` | 새 씬 생성 (Node2D/Node3D/Control) |

### Node 도구 (6개)
| 도구 | 설명 |
|------|------|
| `node.find` | 이름, 타입, 그룹으로 노드 찾기 |
| `node.create` | 새 노드 생성 (80+ 타입 지원) |
| `node.delete` | 노드 삭제 |
| `node.getData` | 노드 정보 및 자식 가져오기 |
| `node.getProperty` | 노드 속성 값 가져오기 |
| `node.setProperty` | 노드 속성 값 설정 (Vector2/3 지원) |

### Transform 도구 (3개)
| 도구 | 설명 |
|------|------|
| `transform.setPosition` | 노드 위치 설정 |
| `transform.setRotation` | 노드 회전 설정 |
| `transform.setScale` | 노드 스케일 설정 |

### Editor 도구 (4개)
| 도구 | 설명 |
|------|------|
| `editor.play` | 현재 또는 지정 씬 플레이 |
| `editor.stop` | 플레이 중지 |
| `editor.pause` | 일시정지 토글 |
| `editor.getState` | 에디터 상태 가져오기 |

### Debug 도구 (3개)
| 도구 | 설명 |
|------|------|
| `debug.screenshot` | 뷰포트 스크린샷 캡처 |
| `debug.tree` | 씬 트리를 텍스트로 가져오기 |
| `debug.log` | 출력 패널에 출력 |

### Console 도구 (2개)
| 도구 | 설명 |
|------|------|
| `console.getLogs` | Godot 로그 파일에서 로그 가져오기 |
| `console.clear` | 로그 마커 초기화 (플레이스홀더) |

### Input 도구 (7개) - NEW
| 도구 | 설명 |
|------|------|
| `input.keyPress` | 키 누르고 떼기 |
| `input.keyDown` | 키 누르고 유지 |
| `input.keyUp` | 키 떼기 |
| `input.mouseClick` | 위치에서 클릭 (왼쪽/오른쪽/가운데) |
| `input.mouseMove` | 마우스를 위치로 이동 |
| `input.actionPress` | 입력 액션 누르기 |
| `input.actionRelease` | 입력 액션 떼기 |

### Script 도구 (2개)
| 도구 | 설명 |
|------|------|
| `script.list` | GDScript 파일 목록 |
| `script.read` | 스크립트 내용 읽기 |

### Resource 도구 (1개)
| 도구 | 설명 |
|------|------|
| `resource.list` | 확장자별 리소스 목록 |

## 사용 예시

### 씬 생성
```
You: 2D 플랫포머 씬 만들어줘

OpenClaw: 
[Executes scene.create {rootType: "Node2D", name: "Level1"}]
[Executes node.create {type: "CharacterBody2D", name: "Player"}]
[Executes node.create {type: "Camera2D", name: "Camera", parent: "Player"}]
[Executes transform.setPosition {path: "Player", x: 100, y: 200}]

완료! Player와 Camera가 있는 Level1 씬을 생성했습니다.
```

### 입력으로 게임 테스트
```
You: 플레이어 이동 테스트해줘

OpenClaw:
[Executes editor.play]
[Executes input.keyDown {key: "W"}]  # 위로 이동
[Executes input.keyUp {key: "W"}]
[Executes input.actionPress {action: "jump"}]
[Executes debug.screenshot]
[Executes editor.stop]

플레이어 이동을 테스트했습니다. 스크린샷 첨부.
```

### 로그 확인
```
You: 에러 확인해줘

OpenClaw:
[Executes console.getLogs {type: "error", limit: 10}]

2개의 에러를 발견했습니다:
- ERROR: Node not found: Player
- ERROR: Invalid resource path
```

## 설정

플러그인은 기본적으로 `http://localhost:18789` (OpenClaw Gateway)에 연결합니다.

변경하려면 `connection_manager.gd`의 `GATEWAY_URL`을 수정하세요.

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                     Godot Editor                             │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           OpenClawPlugin (EditorPlugin)                 │ │
│  │           @tool script                                  │ │
│  └──────────────────────┬─────────────────────────────────┘ │
│                         │                                    │
│                         ▼                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         ConnectionManager                               │ │
│  │         (HTTP 폴링, PROCESS_MODE_ALWAYS)                │ │
│  │                                                          │ │
│  │  • 하트비트: 30초 간격                                  │ │
│  │  • 연결 끊김 시 자동 재연결                             │ │
│  │  • Play 모드 중 연결 유지                               │ │
│  └──────────────────────┬─────────────────────────────────┘ │
│                         │                                    │
│                         ▼                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           Tools (40개 도구)                             │ │
│  │                                                          │ │
│  │  • Scene/Node/Transform 조작                            │ │
│  │  • 입력 시뮬레이션 (키보드, 마우스, 액션)              │ │
│  │  • 디버그 도구 (스크린샷, 로그)                        │ │
│  │  • 에디터 제어 (플레이, 정지)                          │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP (포트 18789)
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                   OpenClaw Gateway                            │
│                   http://localhost:18789                      │
│                                                               │
│  엔드포인트:                                                  │
│  • POST /godot/register  - Godot 세션 등록                   │
│  • POST /godot/heartbeat - 세션 유지                         │
│  • GET  /godot/poll      - 명령 폴링                         │
│  • POST /godot/result    - 도구 실행 결과 전송               │
└──────────────────────────────────────────────────────────────┘
```

## 파일 구조

### Skill vs Extension

| 경로 | 용도 |
|------|------|
| `~/.openclaw/workspace/skills/godot-plugin/` | **Skill** - AI 학습 문서 (SKILL.md), 워크플로우 패턴, 도구 사용 가이드. 배포용 extension 소스 포함. |
| `~/.openclaw/extensions/godot/` | **Extension** - Gateway가 로드하는 실제 코드. `godot_execute`, `godot_sessions` 도구 구현체. |

**요약:** Skill = AI 문서, Extension = 실행 코드

### 설치 흐름

```
Plugin (OpenClawPlugin~/)  ───복사───→  ~/.openclaw/extensions/godot/
                                └── 수동 설치

Skill (extension/)         ───복사───→  ~/.openclaw/extensions/godot/
                                └── install-extension.sh
```

두 경로 모두 동일한 extension 코드를 설치합니다. 편한 방법을 사용하세요.

## 문제 해결

### 플러그인이 로드되지 않음
- Godot 버전 확인 (4.x 필요)
- Output 패널에서 파싱 에러 확인
- addons/openclaw/에 모든 .gd 파일이 있는지 확인

### 연결 문제
- Gateway 실행 확인: `openclaw gateway status`
- URL 확인: 기본값은 `http://localhost:18789`
- Godot의 OpenClaw 독 패널에서 상태 확인

### 입력이 작동하지 않음
- 입력 시뮬레이션은 Play 모드에서만 작동
- 게임 윈도우에 포커스가 있는지 확인
- Input Map에 해당 액션이 있는지 확인

### Play 모드에서 연결 끊김
- 플러그인은 `PROCESS_MODE_ALWAYS`를 사용하여 활성 상태 유지
- 하트비트 간격은 30초
- 연결이 끊기면 플러그인이 자동 재연결

## 변경 이력

버전 히스토리는 [CHANGELOG.md](CHANGELOG.md)를 참조하세요.

## 라이선스

MIT License

---

Made with 🐾 by the OpenClaw community
