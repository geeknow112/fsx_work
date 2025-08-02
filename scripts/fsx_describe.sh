#!/bin/bash

# FSx ファイルシステム情報取得スクリプト
# 使用方法: ./fsx_describe.sh [profile] [region]

PROFILE=${1:-default}
REGION=${2:-ap-northeast-1}

echo "=== FSx ファイルシステム一覧 ==="
echo "Profile: $PROFILE"
echo "Region: $REGION"
echo "================================"

# ファイルシステム一覧取得
aws fsx describe-file-systems \
    --profile "$PROFILE" \
    --region "$REGION" \
    --query 'FileSystems[*].{
        ID:FileSystemId,
        Type:FileSystemType,
        Status:Lifecycle,
        Capacity:StorageCapacity,
        StorageType:StorageType,
        Name:Tags[?Key==`Name`].Value|[0]
    }' \
    --output table

echo ""
echo "=== 詳細情報取得 ==="

# 各ファイルシステムの詳細情報
aws fsx describe-file-systems \
    --profile "$PROFILE" \
    --region "$REGION" \
    --output json
