#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev google-chrome-stable

# Install Android SDK
ANDROID_SDK_ROOT="$HOME/android-sdk"
if [ ! -d "$ANDROID_SDK_ROOT" ]; then
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  cd "$ANDROID_SDK_ROOT/cmdline-tools"
  curl -O https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
  unzip commandlinetools-linux-*.zip
  mv cmdline-tools latest
fi

# Add Android SDK to PATH
echo 'export ANDROID_SDK_ROOT=$HOME/android-sdk' >> ~/.bashrc
echo 'export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"' >> ~/.bashrc
source ~/.bashrc

# Install Android SDK components
sdkmanager --sdk_root=$ANDROID_SDK_ROOT --install "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Configure Flutter to use Android SDK
flutter config --android-sdk $ANDROID_SDK_ROOT

# Clone Flutter if not already installed
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

# Add Flutter to PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Pre-download Flutter dependencies
flutter doctor
