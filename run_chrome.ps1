# Flutter Web Chrome 실행 스크립트 (고정 포트 + 고정 프로필)

$ProjectRoot = $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot

# Chrome 프로필 경로 설정
$ChromeProfile = "$HOME\AppData\Local\summing-flutter-chrome"

# 프로필 디렉토리 없으면 생성
if (!(Test-Path $ChromeProfile)) {
  Write-Host "Creating Chrome profile directory..."
  New-Item -ItemType Directory -Path $ChromeProfile | Out-Null
}

# flutter 명령 확인
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "flutter command not found. Please add Flutter to PATH."
  exit 1
}

# Flutter Web 지원 확인 및 프로젝트 web 플랫폼 설정
$webIndex = Join-Path $ProjectRoot "web\index.html"
if (!(Test-Path $webIndex)) {
  Write-Host "Configuring Flutter Web platform..."
  & flutter create . --platforms web
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to configure Flutter Web platform."
    exit $LASTEXITCODE
  }
}

# 동일 프로필로 실행된 Chrome만 종료 (프로필 충돌 방지)
$profileFlag = "--user-data-dir=$ChromeProfile"
$matchingChrome = Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" |
  Where-Object { $_.CommandLine -like "*$profileFlag*" }

if ($matchingChrome) {
  Write-Host "Stopping existing Chrome instances for profile..."
  $matchingChrome | ForEach-Object {
    try {
      Stop-Process -Id $_.ProcessId -ErrorAction Stop
    } catch {
      Write-Warning "Failed to stop Chrome PID $($_.ProcessId): $($_.Exception.Message)"
    }
  }
}

# Flutter 실행 (인자는 배열로 전달해 파싱 문제 방지)
Write-Host "Starting Flutter on Chrome..."
$flutterArgs = @(
  "run"
  "-d"
  "chrome"
  "--web-hostname"
  "localhost"
  "--web-port"
  "7357"
  "--web-browser-flag=$profileFlag"
)

& flutter @flutterArgs
