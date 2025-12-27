#!/bin/bash

# ============================================
# Armbian 镜像自定义脚本
# 在 rootfs 构建阶段执行，用于安装额外的驱动和配置
# ============================================

# 参数说明:
# $1 = RELEASE (例如: trixie, bookworm)
# $2 = LINUXFAMILY (例如: meson)
# $3 = BOARD (例如: onecloud)
# $4 = BUILD_DESKTOP (yes/no)

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

echo ">>> Customizing image for ${BOARD} (${RELEASE}, ${LINUXFAMILY})"

# ============================================
# 安装 RTL8851BU USB WiFi 驱动
# ============================================
install_rtl8851bu_driver() {
    echo ">>> Installing RTL8851BU USB WiFi driver..."
    
    # 安装编译依赖
    apt-get update
    apt-get install -y build-essential dkms git bc

    # 克隆驱动源码
    local DRIVER_DIR="/usr/src/rtl8851bu-1.0"
    git clone --depth=1 https://github.com/heesn/rtl8831.git "${DRIVER_DIR}"
    
    # 修改 Makefile 适配 ARM 架构
    cd "${DRIVER_DIR}"
    sed -i 's/^CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
    sed -i 's/^CONFIG_PLATFORM_ARM_SUNxI = n/CONFIG_PLATFORM_ARM_SUNxI = y/' Makefile
    sed -i 's/^CONFIG_PLATFORM_ARM64_PC = n/CONFIG_PLATFORM_ARM64_PC = y/' Makefile
    
    # 创建 DKMS 配置文件
    cat > dkms.conf << 'EOF'
PACKAGE_NAME="rtl8851bu"
PACKAGE_VERSION="1.0"
BUILT_MODULE_NAME[0]="8851bu"
DEST_MODULE_LOCATION[0]="/kernel/drivers/net/wireless"
AUTOINSTALL="yes"
MAKE[0]="make KVER=${kernelver}"
CLEAN="make clean"
EOF

    # 使用 DKMS 安装驱动
    dkms add -m rtl8851bu -v 1.0
    dkms build -m rtl8851bu -v 1.0
    dkms install -m rtl8851bu -v 1.0

    echo ">>> RTL8851BU driver installed successfully"
}

# ============================================
# 安装 USB 模式切换工具
# ============================================
install_usb_modeswitch() {
    echo ">>> Installing usb-modeswitch..."
    apt-get install -y usb-modeswitch usb-modeswitch-data
    echo ">>> usb-modeswitch installed successfully"
}

# ============================================
# 主流程
# ============================================
main() {
    # 仅为 onecloud 设备安装驱动
    if [ "${BOARD}" = "onecloud" ]; then
        install_rtl8851bu_driver
        install_usb_modeswitch
    fi
    
    echo ">>> Image customization completed"
}

main