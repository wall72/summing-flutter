#!/usr/bin/env bash
# Flutter Web Chrome 실행 스크립트 (고정 포트 + 고정 프로필) - Linux/WSL 용
# Windows 용은 run_chrome.ps1 참고.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

PORT=7357
CHROME_PROFILE="${XDG_DATA_HOME:-$HOME/.local/share}/summing-flutter-chrome"

# flutter 명령 확인
if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter command not found. Please add Linux Flutter SDK to PATH." >&2
  exit 1
fi
FLUTTER_BIN="$(command -v flutter)"
if [[ "$FLUTTER_BIN" == /mnt/[a-z]/* ]]; then
  echo "Windows Flutter SDK detected ($FLUTTER_BIN)." >&2
  echo "Linux/WSL에서는 리눅스용 Flutter SDK(예: ~/flutter)를 PATH 앞쪽에 두세요." >&2
  exit 1
fi

# Chrome 실행 파일 탐색 (CHROME_EXECUTABLE 우선)
find_chrome() {
  if [[ -n "${CHROME_EXECUTABLE:-}" && -x "$CHROME_EXECUTABLE" ]]; then
    echo "$CHROME_EXECUTABLE"
    return 0
  fi
  local c
  for c in google-chrome google-chrome-stable chromium chromium-browser chrome; do
    if command -v "$c" >/dev/null 2>&1; then
      command -v "$c"
      return 0
    fi
  done
  return 1
}

# Flutter Web 지원 확인 및 프로젝트 web 플랫폼 설정
if [[ ! -f "$PROJECT_ROOT/web/index.html" ]]; then
  echo "Configuring Flutter Web platform..."
  flutter create . --platforms web
fi

if CHROME="$(find_chrome)"; then
  mkdir -p "$CHROME_PROFILE"
  export CHROME_EXECUTABLE="$CHROME"

  # 동일 프로필로 실행된 Chrome만 종료 (프로필 충돌 방지)
  if pkill -f -- "--user-data-dir=$CHROME_PROFILE" 2>/dev/null; then
    echo "Stopping existing Chrome instances for profile..."
    sleep 1
  fi

  echo "Starting Flutter on Chrome ($CHROME)..."
  exec flutter run -d chrome \
    --web-hostname localhost \
    --web-port "$PORT" \
    "--web-browser-flag=--user-data-dir=$CHROME_PROFILE"
fi

# Chrome 이 없으면 (예: WSL) web-server 로 띄우고 호스트 브라우저에서 접속
echo "Chrome not found. Starting web-server device instead."
echo "Open http://localhost:$PORT in your browser."
exec flutter run -d web-server \
  --web-hostname localhost \
  --web-port "$PORT"
