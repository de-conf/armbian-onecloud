# Userpatches 目录说明

本目录包含 Armbian 构建系统的用户自定义补丁和配置。

## 目录结构

```
userpatches/
├── overlay/                    # Rootfs overlay 文件（会复制到根文件系统）
│   └── etc/
│       └── modules-load.d/
│           └── rtl8851bu.conf  # WiFi 驱动自动加载配置
├── customize-image.sh          # 镜像自定义脚本（安装驱动等）
└── README.md
```

## RTL8851BU WiFi 驱动

### 驱动来源
- 仓库: https://github.com/heesn/rtl8831
- 支持芯片: RTL8851BU / RTL8831BU
- 适用设备: USB AX900 WiFi 6 设备（如 Comfast AX900 CF-943F）

### 安装方式
驱动通过 **DKMS** (Dynamic Kernel Module Support) 方式安装：
- 在 Armbian 镜像构建时，`customize-image.sh` 脚本会自动下载并安装驱动
- DKMS 确保驱动与当前内核版本兼容
- 内核更新时，DKMS 会自动重新编译驱动

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

# 查看 DKMS 状态
dkms status
```

### USB 模式切换
某些 USB WiFi 设备默认处于 CDROM 模式，需要切换到 WiFi 模式：

```bash
# 查找设备 ID（查看是否显示为 CDROM 模式）
lsusb
# 示例输出: Bus 002 Device 003: ID 0bda:1a2b Realtek ... (Driver CDROM Mode)

# 切换模式 (替换 0bda 和 1a2b 为实际的 Vendor ID 和 Product ID)
sudo usb_modeswitch -K -v 0bda -p 1a2b

# 重新加载驱动
sudo modprobe -r 8851bu && sudo modprobe 8851bu
```

> **提示**: `usb-modeswitch` 已预装在镜像中。

### 故障排查

```bash
# 查看内核日志中的驱动信息
dmesg | grep -i 8851

# 查看网络接口
ip addr

# 扫描 WiFi 网络
sudo iwlist wlan0 scan
```