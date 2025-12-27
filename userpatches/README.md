# Userpatches 目录说明

本目录包含 Armbian 构建系统的用户自定义配置。

## 目录结构

```
userpatches/
├── overlay/                    # Rootfs overlay 文件（会复制到根文件系统）
│   └── etc/
│       └── modules-load.d/
│           └── rtl8851bu.conf  # WiFi 驱动自动加载配置
└── README.md
```

## RTL8851BU WiFi 驱动

### 驱动来源
- 仓库: https://github.com/heesn/rtl8831
- 支持芯片: RTL8851BU / RTL8831BU
- 适用设备: USB AX900 WiFi 6 设备（如 Comfast AX900 CF-943F）

### 安装方式
驱动通过 **CI 流程分阶段编译安装** 到镜像中：

**阶段 1：内核构建时 (build-debs job)**
1. 克隆驱动源码，修改 Makefile 适配 ARM 架构
2. 使用内核源码编译驱动模块 (.ko 文件)
3. 将编译好的驱动保存为 artifact

**阶段 2：镜像构建后 (build job)**
1. 下载预编译的驱动模块
2. 挂载 Armbian 镜像
3. 将驱动安装到 `/lib/modules/<kernel-version>/kernel/drivers/net/wireless/`
4. 运行 `depmod` 更新模块依赖

详细实现见 `.github/workflows/ci.yml` 中的相关步骤。

### 使用说明
驱动会在系统启动时自动加载（通过 `/etc/modules-load.d/rtl8851bu.conf`）。

如需手动操作：

```bash
# 手动加载驱动
sudo modprobe 8851bu

# 检查驱动是否加载
lsmod | grep 8851bu

# 查看 WiFi 接口
ip link show
```

### USB 模式切换
某些 USB WiFi 设备默认处于 CDROM 模式，需要切换到 WiFi 模式：

```bash
# 安装 usb-modeswitch（如果未安装）
sudo apt-get install usb-modeswitch usb-modeswitch-data

# 查找设备 ID（查看是否显示为 CDROM 模式）
lsusb
# 示例输出: Bus 002 Device 003: ID 0bda:1a2b Realtek ... (Driver CDROM Mode)

# 切换模式 (替换 0bda 和 1a2b 为实际的 Vendor ID 和 Product ID)
sudo usb_modeswitch -K -v 0bda -p 1a2b

# 重新加载驱动
sudo modprobe -r 8851bu && sudo modprobe 8851bu
```

### 故障排查

```bash
# 查看内核日志中的驱动信息
dmesg | grep -i 8851

# 查看网络接口
ip addr

# 扫描 WiFi 网络
sudo iwlist wlan0 scan

# 检查驱动是否存在
find /lib/modules/$(uname -r) -name '*8851*'
```