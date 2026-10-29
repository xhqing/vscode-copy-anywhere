#!/usr/bin/env bash
# 构建可分发产物：vscode-copy-anywhere-<version>（当前平台编译二进制，供 GitHub Release 上传）
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(tr -d '[:space:]' < "$DIR/VERSION")"
OUT="$DIR/vscode-copy-anywhere-$VERSION"

swiftc -O "$DIR/vscode-copy-anywhere.swift" -o "$OUT"
echo "构建完成：$OUT"
