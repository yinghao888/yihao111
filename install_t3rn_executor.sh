#!/bin/bash

set -e

# -----------------------------
# 接收用户传入的私钥参数
# -----------------------------
if [ -z "$1" ]; then
  echo "❌ 错误：请在运行脚本时传入你的私钥参数"
  echo "👉 用法示例: ./install_t3rn_executor.sh YOUR_PRIVATE_KEY_HERE"
  exit 1
fi

PRIVATE_KEY=$1

# 当前执行目录（脚本运行时所在位置）
WORKDIR=$(pwd)

echo "📁 当前工作目录：$WORKDIR"
echo "🚀 开始安装 t3rn Executor..."

# 创建本地t3rn目录
mkdir -p "$WORKDIR/t3rn"
cd "$WORKDIR/t3rn"

# 获取最新版本号
VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
echo "📦 最新版本: $VERSION"

# 下载 Binary 文件
wget -O executor-linux-${VERSION}.tar.gz https://github.com/t3rn/executor-release/releases/download/${VERSION}/executor-linux-${VERSION}.tar.gz

# 解压
tar -xzf executor-linux-${VERSION}.tar.gz

# 进入执行器目录
cd executor/executor/bin

# 设置环境变量
echo "🔧 写入环境变量到 ~/.bashrc（不会影响当前目录结构）..."

cat <<EOF >> ~/.bashrc

# === t3rn Executor 环境变量 ===
export ENVIRONMENT=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false

export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true

export EXECUTOR_MAX_L3_GAS_PRICE=3000

export PRIVATE_KEY_LOCAL=${PRIVATE_KEY}

export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn'

export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
}'

export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
# === t3rn Executor 环境变量 END ===
EOF

# 加载环境变量
source ~/.bashrc

# 安装 screen 工具
sudo apt update && sudo apt install screen -y

echo "✅ 安装完成！你可以使用以下命令启动 Executor："
echo ""
echo "cd $WORKDIR/t3rn/executor/executor/bin"
echo "./executor"
echo ""
echo "💡 推荐使用 screen 后台运行："
echo "screen -S t3rn-executor ./executor"
