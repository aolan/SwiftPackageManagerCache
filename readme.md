
# 一、SPM 脚本工具使用

1、当我们要通过 `Swift package manager` 去引入 `github` 上的一个三方库时，国内由于访问 `github` 存在稳定性问题，`swift package resolve` 和 `swift package reset` 经常会出现问题，当我们依赖的仓库较多时，就会非常浪费时间。

2、 我们只需要借助 `spm` 来提高 `resolve` 和 `reset` 成功率。

## 配置 SPM 脚本

1、执行项目根目录的 `./build.sh` 脚本，就会完成项目的编译，并将 `spm` 脚本工具安装好。

2、在控制台任意路径下，执行 `spm -h`，如果能看到如下输出，说明安装完成了。

```
OVERVIEW: swift package manager 镜像工具

工具原理：
1、将 `github` 远程仓库克隆一份镜像到开发者电脑中，默认存在 `~/Library/Caches/com.lawn.spm.tool/repos_mirror` 目录下
2、修改当前项目的 `git` 配置，在 `.git/config` 文件中，使用 `insteadOf` 将远程仓库替换成本地镜像
3、然后在项目中执行 `swift package resolve` 和 `swift package reset` 拉取的都是本地镜像的仓库。经过测试，非常稳定，无网也可以

USAGE:     spm list
           spm add <url>
           spm remove <url>
           spm update <url>
           spm xcode
           spm xcode <version.app>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list                    查看已缓存的镜像仓库列表
  add                     缓存指定的镜像仓库
  remove                  移除指定的已缓存镜像仓库
  update                  更新指定的镜像仓库
  xcode                   查看mac电脑上安装的xcode版本列表
  xcode-select            设置默认使用的xcode版本

  See 'spm help <subcommand>' for detailed help.
```


## 添加引用

`spm add https://github.com/SnapKit/SnapKit.git`

执行以上命令后，远程仓库就会被添加到用户缓存目录，后续在 `xcode` 中添加引用时，速度就快了。

## 查看缓存

`spm list`

通过以上命令，我们可以看到用户缓存目录中都有哪些镜像，效果如下：

```
已缓存镜像列表：
/Users/lawn/Library/Caches/com.lawn.spm.tool/repos_mirror/nvzqz/FileKit.git
/Users/lawn/Library/Caches/com.lawn.spm.tool/repos_mirror/Alamofire/Alamofire.git
/Users/lawn/Library/Caches/com.lawn.spm.tool/repos_mirror/SnapKit/SnapKit.git

```

## 删除缓存

`spm remove /Users/lawn/Library/Caches/com.lawn.spm.tool/repos_mirror/nvzqz/FileKit.git`
 
 注意，我们这里删除的是本地缓存，所以输入的参数是 `spm list` 中查出来的其中一项
 
 
## 更新缓存

`spm update https://github.com/SnapKit/SnapKit.git`

以上命令，我们会先删除本地镜像，然后重新拉取镜像。

## 查看mac电脑上安装的xcode版本

`spm xcode`

## 设置默认使用的xcode版本

`spm xcode-select Xcode_15.4.app`


# 二、SPM 脚本工具编写

只有当我们需要更新脚本时，才会涉及到这一部分。

1、 可直接双击 `package.swift`，通过 xcode 来进行编写

2、 编写完毕后，执行 `./build.sh` 来编译成可执行文件，可执行文件路径为 `.build/x86_64-apple-macosx/release/spm`，会被移动到 `/usr/local/bin/spm`，这样就可以全局调用了
