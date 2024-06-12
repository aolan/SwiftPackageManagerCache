#!/bin/bash

# 编译
swift build -c release

# 拷贝之后可以全局使用
mv .build/x86_64-apple-macosx/release/spm /usr/local/bin/spm
