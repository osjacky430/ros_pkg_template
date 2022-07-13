#!/usr/bin/env bash
set -eou pipefail

LLVM_VERSION=$1
USE_IWYU=$2

if [ "$USE_IWYU" = "1" ]; then
  if ! [ -x "$(command -v clang++$LLVM_VERSION)" ]; then
    ./install-llvm.sh ${LLVM_VERSION}
    apt-get install -y --no-install-recommends libclang-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev
  fi

  mkdir -p /home/iwyu/build
  git clone --branch clang_${LLVM_VERSION} https://github.com/include-what-you-use/include-what-you-use.git /home/iwyu/include-what-you-use
  CC=clang-${LLVM_VERSION} CXX=clang++-${LLVM_VERSION} cmake -S /home/iwyu/include-what-you-use -B /home/iwyu/build -G "Unix Makefiles" -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}
  cmake --build /home/iwyu/build -j
  cmake --install /home/iwyu/build

  mkdir -p $(include-what-you-use -print-resource-dir 2>/dev/null)
  ln -s $(readlink -f /usr/lib/clang/${LLVM_VERSION}/include) \
    $(include-what-you-use -print-resource-dir 2>/dev/null)/include
fi

apt-get update -qq && apt-get install -y --no-install-recommends \
  lldb-${LLVM_VERSION} clangd-${LLVM_VERSION} clang-tidy-${LLVM_VERSION} clang-format-${LLVM_VERSION}

update-alternatives --install /usr/bin/clang-format clang-format $(which clang-format-${LLVM_VERSION}) 1
update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VERSION}) 1
