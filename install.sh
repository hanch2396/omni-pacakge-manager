#!/bin/bash

echo "🚀 dpm (Distrobox Package Manager) Installer"

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
                sudo apt update && sudo apt install -y podman distrobox
                ;;
            fedora)
                sudo dnf install -y podman distrobox
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm podman distrobox
                ;;
            *)
                echo "⚠️  Unsupported OS. Please install 'podman' and 'distrobox' manually."
                exit 1
                ;;
        esac
    fi
}

# 메인 로직
if ! check_dependency "podman" || ! check_dependency "distrobox"; then
    read -p "Dependencies are missing. Install them now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dependencies
    else
        echo "Please install podman and distrobox manually."
        exit 1
    fi
fi

# 3. dpm 스크립트 설치
echo "📥 Installing dpm to /usr/local/bin..."
sudo curl -fsSL https://raw.githubusercontent.com/hanch2396/dpm/main/dpm -o /usr/local/bin/dpm
sudo chmod +x /usr/local/bin/dpm

# 4. 초기화 안내
echo "🎉 Installation complete!"
echo "Running 'dpm init'"
dpm init
