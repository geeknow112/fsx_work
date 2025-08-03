#!/bin/bash

# FSx パフォーマンス監視スクリプト
# 使用方法: ./fsx_performance_monitor.sh <filesystem-id> [profile] [region] [days]

if [ $# -lt 1 ]; then
    echo "使用方法: $0 <filesystem-id> [profile] [region] [days]"
    echo "例: $0 fs-xxxxxxxxx your-profile ap-northeast-1 7"
    exit 1
fi

FILESYSTEM_ID=$1
PROFILE=${2:-your-profile}
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

# スループット使用率
echo "--- ネットワークスループット使用率 (時間別) ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "NetworkThroughputUtilization" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 3600 \
    --statistics Average,Maximum \
    --query 'Datapoints[*].{Time:Timestamp,AvgThroughput:Average,MaxThroughput:Maximum}' \
    --output table

echo ""

# IOPS使用率
echo "--- IOPS使用率 (時間別) ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "DiskIopsUtilization" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 3600 \
    --statistics Average,Maximum \
    --query 'Datapoints[*].{Time:Timestamp,AvgIOPS:Average,MaxIOPS:Maximum}' \
    --output table

echo ""

# ストレージ使用率
echo "--- ストレージ使用率 ---"
aws cloudwatch get-metric-statistics \
    --profile "$PROFILE" \
    --region "$REGION" \
    --namespace "AWS/FSx" \
    --metric-name "StorageCapacityUtilization" \
    --dimensions Name=FileSystemId,Value="$FILESYSTEM_ID" \
    --start-time "$START_DATE" \
    --end-time "$END_DATE" \
    --period 86400 \
    --statistics Average \
    --query 'Datapoints[*].{Date:Timestamp,StorageUsage:Average}' \
    --output table
