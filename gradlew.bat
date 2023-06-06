name: Build_windows

on:
  push:
    branches:
      - dev-build-linux-amd64
  pull_request:
    branches:
      - dev-build-linux-amd64
  workflow_dispatch:

jobs:
  build:
    runs-on: windows-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Setup Java
        uses: actions/setup-java@v2
        with:
          distribution: 'adopt'
          java-version: '17'

      - name: Install Visual Studio Build Tools
        uses: ilammy/msvc-dev-cmd@v1

      - name: Install Windows SDK 10
        run: |
          choco install windows-sdk-10 -y

      - name: Set Windows SDK path
        run: |
          echo "::set-env name=WINDOWS_KITS_10::C:\Program Files (x86)\Windows Kits\10"

      - name: Build Native Image
        run: |
          # Set the path to the installed Windows SDK 10
          $env:Path += ";$env:WINDOWS_KITS_10\bin"

          # Run the nativeImage task using the installed SDK
          ./gradlew.bat nativeImage --stacktrace

          # Check if the nativeImage task failed
          if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to build native image."
            exit $LASTEXITCODE
          }

      - name: Upload Artifacts
        uses: actions/upload-artifact@v2
        with:
          name: native-image-windows-amd64
          path: build/graal/
