# armbian-onecloud

[![build](https://img.shields.io/github/actions/workflow/status/hzyitc/armbian-onecloud/ci.yml)](https://github.com/hzyitc/armbian-onecloud/actions/workflows/ci.yml) [![downloads](https://img.shields.io/github/downloads/hzyitc/armbian-onecloud/total)](https://github.com/hzyitc/armbian-onecloud/releases) [![downloads@latest](https://img.shields.io/github/downloads/hzyitc/armbian-onecloud/latest/total)](https://github.com/hzyitc/armbian-onecloud/releases/latest)

[README](README.md) | [中文文档](README_zh.md)

**所有修改均已提交至[官方仓库](https://github.com/armbian/build)，您可以直接使用[官方仓库](https://github.com/armbian/build)进行编译。**

## 第一次登录

主机名: `onecloud`

账号:  `root`

密码: `1234`

## 编译参数

### `BOARD`=`onecloud`

### `BRANCH`=`current`

| BRANCH    | 内核版本 | eMMC | HDMI | VPU |
| :-:       | :-:     | :-:  | :-:  | :-: |
| `current` | `v6.12` | ✔️¹  | ✔️² | ✔️² |

> ¹: 需要补丁
>
> ²: 通过补丁支持

## 如何从`u-boot`启动？

### 从`USB`启动

```
setenv bootdev "usb 0"
usb start
fatload ${bootdev} 0x20800000 boot.scr && autoscr 0x20800000
```

### 从`eMMC`启动

```
setenv bootdev "mmc 1"
fatload ${bootdev} 0x20800000 boot.scr && autoscr 0x20800000
```

## `GPIO`

板子上面有一个预留的SDIO WiFi模块。上面有大量直连`SoC`的引脚，可用作`GPIO`。

具体定义参见`dts`(由 `patch/kernel/archive/meson-6.12/onecloud-0001-add-dts.patch` 添加)

注：`dts`中的引脚是在`V1.0的板子`上测量出来的，未在`V1.3的板子`上面验证。

## 本地构建

使用提供的脚本可以在本地构建 Armbian 镜像：

```bash
# 1. 初始化并检查依赖
chmod +x scripts/*.sh
./scripts/quick-start.sh

# 2. 一键构建
./scripts/build-all.sh

# 或分步构建：
./scripts/01-prepare-armbian.sh   # 准备 Armbian 环境
./scripts/02-build-kernel.sh      # 编译内核
./scripts/03-build-driver.sh      # 编译 RTL8851BU WiFi 驱动
./scripts/04-build-image.sh       # 构建系统镜像
./scripts/05-install-driver.sh    # 安装驱动到镜像
./scripts/06-create-burn-image.sh # 生成烧录镜像
```

更多选项：
```bash
./scripts/build-all.sh --help
```

详细文档请参阅 [scripts/README.md](scripts/README.md)。

### 系统要求

- **操作系统**: Ubuntu 22.04 / Debian 12 (推荐)
- **架构**: x86_64
- **内存**: 至少 4GB，推荐 8GB+
- **磁盘**: 至少 30GB 可用空间，推荐 50GB+

### RTL8851BU WiFi 驱动

本项目集成了 RTL8851BU USB WiFi 6 驱动，支持以下设备：
- Comfast AX900 CF-943F
- 其他使用 RTL8851BU/RTL8831BU 芯片的 USB WiFi 设备

驱动会在系统启动时自动加载。

## 本地构建

使用提供的脚本可以在本地构建 Armbian 镜像：

```bash
# 1. 初始化并检查依赖
chmod +x scripts/*.sh
./scripts/quick-start.sh

# 2. 一键构建
./scripts/build-all.sh

# 或分步执行：
./scripts/01-prepare-armbian.sh   # 准备 Armbian 环境
./scripts/02-build-kernel.sh      # 编译内核
./scripts/03-build-driver.sh      # 编译 RTL8851BU WiFi 驱动
./scripts/04-build-image.sh       # 构建系统镜像
./scripts/05-install-driver.sh    # 安装驱动到镜像
./scripts/06-create-burn-image.sh # 生成烧录镜像
```

更多选项：
```bash
./scripts/build-all.sh --help
```

详细文档请参阅 [scripts/README.md](scripts/README.md)。

### 系统要求

- **操作系统**: Ubuntu 22.04 / Debian 12 (推荐)
- **架构**: x86_64
- **内存**: 至少 4GB，推荐 8GB+
- **磁盘**: 至少 30GB 可用空间，推荐 50GB+

### RTL8851BU WiFi 驱动

本项目集成了 RTL8851BU USB WiFi 6 驱动支持：
- 驱动来源: [heesn/rtl8831](https://github.com/heesn/rtl8831)
- 支持芯片: RTL8851BU / RTL8831BU
- 适用设备: USB AX900 WiFi 6 设备

驱动会在系统启动时自动加载。

## 相关链接

[`armbian/build`](https://github.com/armbian/build) - Armbian官方仓库

[`heesn/rtl8831`](https://github.com/heesn/rtl8831) - RTL8851BU WiFi 驱动源码

[`xdarklight/linux@meson-mx-integration-5.18-20220516`](https://github.com/xdarklight/linux/commits/meson-mx-integration-5.18-20220516) - `HDMI`补丁源码

[`S805_Datasheet V0.8 20150126.pdf`](https://dn.odroid.com/S805/Datasheet/S805_Datasheet%20V0.8%2020150126.pdf) - S805数据手册
