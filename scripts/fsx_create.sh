#!/bin/bash

# FSx ファイルシステム作成スクリプト
# 使用方法: ./fsx_create.sh <template-file> [profile] [region]

if [ $# -lt 1 ]; then
    echo "使用方法: $0 <template-file> [profile] [region]"
    echo "例: $0 ../templates/fsx_windows_template.json default ap-northeast-1"
    exit 1
fi

TEMPLATE_FILE=$1
PROFILE=${2:-default}
REGION=${3:-ap-northeast-1}

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "エラー: テンプレートファイル '$TEMPLATE_FILE' が見つかりません"
    exit 1
fi

echo "=== FSx ファイルシステム作成 ==="
echo "テンプレート: $TEMPLATE_FILE"
echo "Profile: $PROFILE"
echo "Region: $REGION"
echo "================================"

# テンプレートの内容を表示
echo "--- 作成設定 ---"
cat "$TEMPLATE_FILE" | jq .

echo ""
read -p "この設定でファイルシステムを作成しますか？ (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "作成をキャンセルしました"
    exit 0
fi

# ファイルシステム作成
echo "ファイルシステムを作成中..."
aws fsx create-file-system \
    --profile "$PROFILE" \
    --region "$REGION" \
    --cli-input-json file://"$TEMPLATE_FILE"

if [ $? -eq 0 ]; then
    echo "ファイルシステムの作成リクエストが送信されました"
    echo "作成状況を確認するには以下のコマンドを実行してください:"
    echo "aws fsx describe-file-systems --profile $PROFILE --region $REGION"
else
    echo "エラー: ファイルシステムの作成に失敗しました"
    exit 1
fi
