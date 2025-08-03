#!/bin/bash

# FSx ストレージ容量拡張スクリプト
# 使用方法: ./fsx_expand_storage.sh <file-system-id> <target-capacity-gb> [profile] [region]

if [ $# -lt 2 ]; then
    echo "使用方法: $0 <file-system-id> <target-capacity-gb> [profile] [region]"
    echo "例: $0 fs-xxxxxxxxx 7200 lober-system ap-northeast-1"
    echo ""
    echo "注意事項:"
    echo "- 容量は現在の容量より大きい値を指定してください"
    echo "- 容量拡張は一方向のみ（減少不可）"
    echo "- 拡張中は他の変更操作はできません"
    exit 1
fi

FILE_SYSTEM_ID=$1
TARGET_CAPACITY=$2
PROFILE=${3:-lober-system}
REGION=${4:-ap-northeast-1}

echo "=== FSx ストレージ容量拡張 ==="
echo "ファイルシステムID: $FILE_SYSTEM_ID"
echo "目標容量: ${TARGET_CAPACITY}GB"
echo "Profile: $PROFILE"
echo "Region: $REGION"
echo "================================"

# 現在の状況確認
echo "--- 現在の構成確認 ---"
CURRENT_INFO=$(aws fsx describe-file-systems \
    --file-system-ids "$FILE_SYSTEM_ID" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --query 'FileSystems[0].{StorageCapacity:StorageCapacity,StorageType:StorageType,Lifecycle:Lifecycle}' \
    --output table)

if [ $? -ne 0 ]; then
    echo "エラー: ファイルシステム情報の取得に失敗しました"
    exit 1
fi

echo "$CURRENT_INFO"

# 現在の容量を取得
CURRENT_CAPACITY=$(aws fsx describe-file-systems \
    --file-system-ids "$FILE_SYSTEM_ID" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --query 'FileSystems[0].StorageCapacity' \
    --output text)

echo ""
echo "現在の容量: ${CURRENT_CAPACITY}GB"
echo "目標容量: ${TARGET_CAPACITY}GB"

# 容量チェック
if [ "$TARGET_CAPACITY" -le "$CURRENT_CAPACITY" ]; then
    echo "エラー: 目標容量は現在の容量（${CURRENT_CAPACITY}GB）より大きい値を指定してください"
    exit 1
fi

# 進行中の操作確認
ADMIN_ACTIONS=$(aws fsx describe-file-systems \
    --file-system-ids "$FILE_SYSTEM_ID" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --query 'FileSystems[0].AdministrativeActions[?Status==`IN_PROGRESS`]' \
    --output text)

if [ -n "$ADMIN_ACTIONS" ] && [ "$ADMIN_ACTIONS" != "None" ]; then
    echo "警告: 進行中の管理操作があります"
    echo "進行中の操作が完了してから実行してください"
    exit 1
fi

echo ""
echo "拡張予定:"
echo "- 容量増加: $((TARGET_CAPACITY - CURRENT_CAPACITY))GB"
echo "- 拡張後の月額料金概算: 約$((TARGET_CAPACITY * 24))円（HDD料金）"
echo ""

read -p "この設定でストレージ容量を拡張しますか？ (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "拡張をキャンセルしました"
    exit 0
fi

# 容量拡張実行
echo "ストレージ容量を拡張中..."
aws fsx update-file-system \
    --file-system-id "$FILE_SYSTEM_ID" \
    --storage-capacity "$TARGET_CAPACITY" \
    --profile "$PROFILE" \
    --region "$REGION"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ストレージ容量拡張リクエストが送信されました"
    echo ""
    echo "📋 次のステップ:"
    echo "1. 拡張状況の監視（通常30分-2時間）"
    echo "2. 拡張完了後のストレージ最適化プロセス"
    echo "3. 性能テストの実施"
    echo ""
    echo "🔍 進捗確認コマンド:"
    echo "aws fsx describe-file-systems --file-system-ids $FILE_SYSTEM_ID --profile $PROFILE --region $REGION --query 'FileSystems[0].AdministrativeActions'"
    echo ""
    echo "📊 監視用スクリプト:"
    echo "./scripts/fsx_performance_monitor.sh $FILE_SYSTEM_ID $PROFILE $REGION 1"
else
    echo "❌ エラー: ストレージ容量拡張に失敗しました"
    exit 1
fi
