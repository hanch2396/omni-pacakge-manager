#!/usr/bin/env bash

echo "🚀 om (Omni Package Manager) Installer"

# 1. 의존성 확인 함수
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 could not be found."
        return 1
    else
        echo "✅ $1 is installed."
        return 0
    fi
}

# 2. 의존성 설치 시도 (간소화된 버전)
install_dependencies() {
    echo "📦 Attempting to install dependencies..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                sudo apt update && sudo apt install -y podman
                ;;
            fedora)
                sudo dnf install -y podman
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm podman
                ;;
            *)
                echo "⚠️  Unsupported OS. Please install 'podman' manually."
                exit 1
                ;;
        esac
    fi
}

# 메인 로직
if ! check_dependency "podman"; then
    read -p "Dependencies are missing. Install them now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dependencies
    else
        echo "Please install podman manually."
        exit 1
    fi
fi

# distrobox는 모든 시스템의 통일성을 위해 직접 설치
# nixos의 경우는 컨테이너 실행 오류로 인해 사용자가 직접 설치 필요
if [ -f /etc/os-release ]; then
    # 파일을 로드하여 변수들을 가져옵니다
    . /etc/os-release

    PKG="distrobox"
    
    if [ "$ID" == "nixos" ]; then
        if ! command -v $PKG &> /dev/null; then
            echo "❌ $PKG could not be found."
            echo "⚠️  Please install 'distrobox' manually."
            exit 1
        else
            echo "✅ $PKG is installed."
        fi
    else
        echo "📥 Installing distrobox"
        curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
    fi
fi

# 3. dpm 스크립트 설치
echo "📥 Installing om to ${HOME}/.local/bin..."
mkdir -p ${HOME}/.local/bin  # 폴더가 없을 경우 대비
curl -fsSL https://raw.githubusercontent.com/hanch2396/omni-pacakge-manager/main/om -o ${HOME}/.local/bin/om
chmod +x ${HOME}/.local/bin/om

# --- PATH 추가 로직 시작 ---
echo "🔧 Configuring PATH..."
export PATH="$HOME/.local/bin:$PATH"  # 현재 스크립트 세션에 PATH 적용

# 사용하는 쉘 설정 파일 감지 및 영구 등록
SHELL_CONFIG=""
case "$SHELL" in
  */zsh) SHELL_CONFIG="$HOME/.zshrc" ;;
  */bash) SHELL_CONFIG="$HOME/.bashrc" ;;
  *) 
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    ;;
esac

if [ -n "$SHELL_CONFIG" ]; then
    # 파일 내에 이미 PATH 설정이 있는지 확인 후 없으면 추가
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_CONFIG"; then
        echo '' >> "$SHELL_CONFIG"
        echo '# Add local bin to PATH' >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        echo "✅ Added ~/.local/bin to $SHELL_CONFIG"
    else
        echo "✅ PATH is already configured in $SHELL_CONFIG"
    fi
else
    echo "⚠️  Could not detect shell config file. Please add ~/.local/bin to your PATH manually."
fi
# --- PATH 추가 로직 끝 ---

# 4. 초기화 안내
echo "🎉 Installation complete!"
echo "Running 'om init'"
om init
