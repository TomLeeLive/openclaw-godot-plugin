# 🦞 OpenClaw Godot 플러그인

> **한줄요약:** 이제 집밖에서도 원격으로 바이브코딩으로 게임 개발 가능합니다! 🎮

Godot 4.x를 [OpenClaw](https://github.com/openclaw/openclaw) AI 어시스턴트에 HTTP로 연결하세요. Play를 누르지 않고도 **에디터 모드**에서 작동합니다!

[![Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine)](https://godotengine.org)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.2.3+-green)](https://github.com/openclaw/openclaw)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?logo=buy-me-a-coffee)](https://buymeacoffee.com/tomleelive)

## ⚠️ 면책 조항

이 소프트웨어는 **베타** 버전입니다. 사용에 따른 위험은 본인이 감수해야 합니다.

- 사용 전 항상 프로젝트를 백업하세요
- 별도의 테스트 프로젝트에서 먼저 테스트하세요
- 데이터 손실이나 프로젝트 손상에 대해 저자는 책임지지 않습니다

전체 조건은 [LICENSE](LICENSE)를 참조하세요.

## 🔀 하이브리드 아키텍처

이 플러그인은 **두 가지 연결 모드**를 지원합니다 - 워크플로우에 맞는 것을 사용하세요:

### 모드 A: OpenClaw Gateway (원격 접근)
```
Telegram/Discord/Web → OpenClaw Gateway → Godot 플러그인
```
- ✅ 어디서든 원격 접근
- ✅ 채팅 통합 (Telegram, Discord 등)
- ✅ 크론 작업, 자동화, 멀티 디바이스
- ⚠️ OpenClaw Gateway 실행 필요

### 모드 B: MCP Direct (로컬 개발)
```
Claude Code/Desktop → MCP 서버 → Godot 플러그인
```
- ✅ 미들웨어 없이 직접 연결
- ✅ Claude Code, Cursor 등과 작동
- ✅ 로컬 개발을 위한 낮은 지연 시간
- ⚠️ 로컬 전용 (127.0.0.1)

### 빠른 설정

| 모드 | 설정 |
|------|------|
| **OpenClaw** | 플러그인 + Gateway extension 설치, 자동 연결 |
| **MCP** | 플러그인 설치 + Claude에 MCP 서버 등록 |

📖 **[Setup Guide](Documentation~/SETUP_GUIDE.md)** | **[셋업 가이드](Documentation~/SETUP_GUIDE_KO.md)**

## ✨ 주요 기능

- 🎮 **에디터 & Play 모드에서 작동** - AI 도구 사용에 Play를 누를 필요 없음
- 🔌 **자동 연결** - Godot 시작 시 연결, 모드 변경 시에도 연결 유지
- 🎬 **씬 관리** - 씬 생성, 열기, 저장, 검사
- 🔧 **노드 조작** - 노드 생성, 찾기, 수정, 삭제 (80개 이상 타입)
- 📸 **디버그 도구** - 스크린샷, 씬 트리 뷰, 콘솔 로그
- 🎮 **입력 시뮬레이션** - 게임 테스트를 위한 키보드, 마우스, 액션 입력
- 🎯 **에디터 제어** - 원격으로 씬 실행, 중지, 일시정지
- 📜 **스크립트 접근** - GDScript 파일 목록 및 읽기
- 🔄 **Play 모드 안정성** - Play 모드 중에도 연결 유지

## 요구 사항

| 컴포넌트 | 버전 |
|----------|------|
| **Godot** | 4.x |
| **OpenClaw** | 2026.2.3+ |

> ⚠️ **Godot 4.6-stable에서만 테스트됨.**
> 
> Godot 4.x용으로 설계되었지만, Godot 4.6-stable에서만 테스트되었습니다.
> 다른 Godot 버전에서 문제가 발생하면:
> - 🐛 Godot 버전과 오류 상세 정보를 포함하여 [Issue 열기](https://github.com/TomLeeLive/openclaw-godot-plugin/issues)
> - 🔧 수정 사항이 있다면 [Pull Request 제출](https://github.com/TomLeeLive/openclaw-godot-plugin/pulls)
> 
> 여러분의 기여가 이 플러그인을 모든 Godot 버전에서 작동하게 합니다!

## 설치

### 옵션 1: Git Clone (권장)

```bash
# 저장소 클론
git clone https://github.com/TomLeeLive/openclaw-godot-plugin.git

# 애드온을 프로젝트에 복사
cp -r openclaw-godot-plugin/addons/openclaw your-project/addons/
```

### 옵션 2: ZIP 다운로드

1. [Releases](https://github.com/TomLeeLive/openclaw-godot-plugin/releases)에서 다운로드
2. `addons/openclaw`을 프로젝트의 `addons/` 디렉토리에 압축 해제

## 빠른 시작

### 1. OpenClaw Gateway Extension 설치 (필수)

Gateway extension 파일을 OpenClaw에 복사:

```bash
# extension 파일 복사
cp -r OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# extension 로드를 위해 gateway 재시작
openclaw gateway restart

# 확인
openclaw godot status
```

> **참고:** `OpenClawPlugin~`에는 `godot_execute`와 `godot_sessions` 도구를 활성화하는 gateway extension이 포함되어 있습니다. OpenClaw가 Godot과 통신하려면 필수입니다.

### 2. Godot 플러그인 설치

1. `addons/openclaw` 폴더를 프로젝트의 `addons/` 디렉토리에 복사
2. 플러그인 활성화: `Project → Project Settings → Plugins → OpenClaw → Enable`
3. Godot 시작 시 자동 연결
4. Output 패널에서 `[OpenClaw] Connected to Gateway` 확인

### 3. OpenClaw와 대화

OpenClaw에게 씬 검사, 노드 생성, 문제 디버깅을 요청하세요 - 모두 Play 모드 진입 없이!

### 4. OpenClaw Skill 설치 (선택)

동반 스킬은 AI를 위한 워크플로우 패턴과 도구 참조를 제공합니다:

```bash
# OpenClaw 워크스페이스에 skill 클론
git clone https://github.com/TomLeeLive/openclaw-godot-skill.git ~/.openclaw/workspace/skills/godot-plugin
```

스킬이 제공하는 것:
- 모든 30개 도구의 빠른 참조
- 일반적인 워크플로우 패턴 (씬 생성, 테스트 등)
- 상세한 파라미터 문서
- 문제 해결 가이드

> **참고:** 스킬은 gateway extension과 별개입니다. Extension은 도구를 활성화하고, 스킬은 AI가 그것을 효과적으로 사용하는 방법을 가르칩니다.

## 사용 가능한 도구 (30개 도구, 80개 이상 노드 타입)

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
| `node.create` | 새 노드 생성 (80개 이상 타입 지원) |
| `node.delete` | 노드 삭제 |
| `node.getData` | 노드 정보와 자식 가져오기 |
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
| `editor.play` | 현재 또는 커스텀 씬 실행 |
| `editor.stop` | 실행 중지 |
| `editor.pause` | 일시정지 토글 |
| `editor.getState` | 에디터 상태 가져오기 |

### Debug 도구 (3개)
| 도구 | 설명 |
|------|------|
| `debug.screenshot` | 뷰포트 스크린샷 캡처 |
| `debug.tree` | 씬 트리를 텍스트로 가져오기 |
| `debug.log` | 출력에 프린트 |

### Console 도구 (2개)
| 도구 | 설명 |
|------|------|
| `console.getLogs` | Godot 로그 파일에서 로그 가져오기 |
| `console.clear` | 로그 마커 클리어 (플레이스홀더) |

### Input 도구 (7개)
| 도구 | 설명 |
|------|------|
| `input.keyPress` | 키 누르고 떼기 |
| `input.keyDown` | 키 누르고 유지 |
| `input.keyUp` | 키 떼기 |
| `input.mouseClick` | 위치에서 클릭 (left/right/middle) |
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
[scene.create {rootType: "Node2D", name: "Level1"} 실행]
[node.create {type: "CharacterBody2D", name: "Player"} 실행]
[node.create {type: "Camera2D", name: "Camera", parent: "Player"} 실행]
[transform.setPosition {path: "Player", x: 100, y: 200} 실행]

완료! Player와 Camera가 있는 Level1 씬을 생성했습니다.
```

### 입력으로 게임 테스트
```
You: 플레이어 이동 테스트해줘

OpenClaw:
[editor.play 실행]
[input.keyDown {key: "W"} 실행]  # 위로 이동
[input.keyUp {key: "W"} 실행]
[input.actionPress {action: "jump"} 실행]
[debug.screenshot 실행]
[editor.stop 실행]

플레이어 이동을 테스트했습니다. 스크린샷 첨부합니다.
```

## 문서

- 📖 **[Setup Guide](Documentation~/SETUP_GUIDE.md)** | **[셋업 가이드](Documentation~/SETUP_GUIDE_KO.md)**
- 🔧 **[Development](Documentation~/DEVELOPMENT.md)** | **[개발 가이드](Documentation~/DEVELOPMENT_KO.md)**
- 🧪 **[Testing](Documentation~/TESTING.md)** | **[테스팅](Documentation~/TESTING_KO.md)**
- 🤝 **[Contributing](Documentation~/CONTRIBUTING.md)** | **[기여 가이드](Documentation~/CONTRIBUTING_KO.md)**

## 변경 로그

버전 히스토리는 [CHANGELOG.md](CHANGELOG.md)를 참조하세요.

## 라이선스

MIT 라이선스 - 상세 내용은 [LICENSE](LICENSE)를 참조하세요.

---

🦞 OpenClaw 커뮤니티가 만들었습니다
