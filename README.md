# MenuCal

MenuCal 是一个使用 SwiftUI 开发的 macOS 菜单栏日历。点击菜单栏图标即可查看日历、农历、节气和日期详情，并可自定义菜单栏显示内容。

<p align="center">
  <img src="MenuCal/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" width="128" alt="MenuCal 图标">
</p>

## 功能

- 菜单栏快速查看日历
- 显示农历和二十四节气
- 支持星期日或星期一作为每周第一天
- 快速返回当前月份
- 按年份和月份跳转
- 自定义菜单栏显示内容及排列顺序
  - 图标
  - 年份
  - 农历年
  - 农历日
  - 日期
  - 星期
  - 时间
- 支持 12/24 小时制和秒钟显示
- 支持登录时自动启动
- 通过 Sparkle 检查和安装更新

## 系统要求

- macOS 15.0 或更高版本
- Apple Silicon 或 Intel Mac。发布包建议构建为 Universal，以同时包含 `arm64` 和 `x86_64` 架构

## 下载

前往 [Releases](https://github.com/gp0119/MenuCal/releases) 下载最新版本。

MenuCal 当前未使用 Apple Developer ID 签名和公证。请只从本仓库下载应用。

## 安装

1. 下载并打开 DMG，或解压 ZIP。
2. 将 `MenuCal.app` 移动到“应用程序”文件夹。
3. 打开终端并执行：

```bash
sudo xattr -rd com.apple.quarantine "/Applications/MenuCal.app"
```

这条命令会移除 macOS 为互联网下载文件添加的隔离属性。执行前请确认应用来自本仓库。

## 使用

点击菜单栏中的 MenuCal 图标打开日历。

右上角菜单提供：

- 设置
- 检查更新
- 关于
- 退出 MenuCal

设置窗口包含：

- **通用**：登录时启动、时间格式
- **菜单栏**：显示内容、顺序、图标样式和秒钟
- **日历**：农历、节气和每周开始日期
