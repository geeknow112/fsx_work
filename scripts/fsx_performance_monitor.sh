#!/bin/bash

# FSx パフォーマンス監視スクリプト
# 使用方法: ./fsx_performance_monitor.sh <filesystem-id> [profile] [region] [days]

if [ $# -lt 1 ]; then
    echo "使用方法: $0 <filesystem-id> [profile] [region] [days]"
    echo "例: $0 fs-xxxxxxxxx default ap-northeast-1 7"
    exit 1
fi

FILESYSTEM_ID=$1
PROFILE=${2:-default}
REGION=${3:-ap-northeast-1}
DAYS=${4:-7}

# 日付計算
START_DATE=$(date -u -d "$DAYS days ago" '+%Y-%m-%dT%H:%M:%SZ')
END_DATE=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

echo "=== FSx パフォーマンス監視 ==="
echo "ファイルシステムID: $FILESYSTEM_ID"
echo "期間: $START_DATE から $END_DATE"
echo "================================"

# データ読み取り量
echo "--- データ読み取り量 (日別) ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "DataReadBytes" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 86400 \
    --statistics Sum \
    --query 'Datapoints[*].{Date:Timestamp,ReadBytes:Sum}' \
    --output table

echo ""

# データ書き込み量
echo "--- データ書き込み量 (日別) ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "DataWriteBytes" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 86400 \
    --statistics Sum \
    --query 'Datapoints[*].{Date:Timestamp,WriteBytes:Sum}' \
    --output table

echo ""

# I/O時間
echo "--- I/O応答時間 (時間別平均) ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "TotalIOTime" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 3600 \
    --statistics Average,Maximum \
    --query 'Datapoints[*].{Time:Timestamp,AvgIOTime:Average,MaxIOTime:Maximum}' \
    --output table
