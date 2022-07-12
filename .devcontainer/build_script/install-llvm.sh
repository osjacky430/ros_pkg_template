#!/usr/bin/env bash
set -eou pipefail

OS_CODENAME=$(lsb_release -cs)
LLVM_VERSION=$1

REPO_NAME="deb http://apt.llvm.org/${OS_CODENAME}/ llvm-toolchain-${OS_CODENAME}-${LLVM_VERSION} main"

wget -nv -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
echo "$REPO_NAME" | tee -a /etc/apt/sources.list
apt-get update -qq && apt-get install -y --no-install-recommends \
  clang-${LLVM_VERSION} lldb-${LLVM_VERSION} lld-${LLVM_VERSION} clangd-${LLVM_VERSION} \
  llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-tidy-${LLVM_VERSION} clang-format-${LLVM_VERSION}

update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VERSION}) 1
update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VERSION}) 100
update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${LLVM_VERSION}) 100