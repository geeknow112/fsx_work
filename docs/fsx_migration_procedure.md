# FSx SSD→HDD移行 詳細作業手順書

## 作業概要
- **対象**: fs-0b2d61a3f2654a9a3 (SV-FILE)
- **移行方式**: SSD Multi-AZ → HDD Multi-AZ
- **データ移行**: オンライン移行（業務継続）
- **想定作業時間**: 2-3日間

## Phase 1: 事前準備（実施1週間前）

### 1-1. 環境確認
```bash
# 現在の状況確認
./scripts/fsx_describe.sh your-profile ap-northeast-1

# 使用量確認
./scripts/fsx_performance_monitor.sh fs-0b2d61a3f2654a9a3 your-profile ap-northeast-1 7

# バックアップ状況確認
aws fsx describe-backups --region ap-northeast-1 --profile your-profile
```

### 1-2. バックアップ強化
```bash
# 移行前完全バックアップ作成
aws fsx create-backup \
  --file-system-id fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile \
  --tags Key=Purpose,Value=PreMigrationBackup Key=Date,Value=2025-08-XX

# バックアップ完了確認（30-60分後）
aws fsx describe-backups --region ap-northeast-1 --profile your-profile
```

### 1-3. テンプレート準備
```bash
# HDD用テンプレート作成（要作成）
# templates/fsx_hdd_template.json

# 切り替え用テンプレート作成（要作成）
# templates/fsx_ssd_single_az_template.json
```

### 1-4. 監視設定強化
```bash
# CloudWatch アラーム設定
aws cloudwatch put-metric-alarm \
  --alarm-name "FSx-Migration-ThroughputHigh" \
  --alarm-description "FSx throughput usage > 80% during migration" \
  --metric-name ThroughputUtilization \
  --namespace AWS/FSx \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FileSystemId,Value=fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile
```

## Phase 2: HDD FSx構築（実施日 Day 1）

### 2-1. 新HDD FSx作成
```bash
# 注意: 実際の作成前に必ず承認を得る
./scripts/fsx_create.sh templates/fsx_hdd_template.json your-profile ap-northeast-1

# 作成状況監視（20-40分）
watch -n 300 'aws fsx describe-file-systems --region ap-northeast-1 --profile your-profile | grep -A 10 -B 5 "CREATING\|AVAILABLE"'
```

### 2-2. 新システム初期設定
```bash
# 作成完了後のファイルシステムID取得
NEW_FSX_ID=$(aws fsx describe-file-systems --region ap-northeast-1 --profile your-profile --query 'FileSystems[?Lifecycle==`AVAILABLE` && StorageType==`HDD`].FileSystemId' --output text)

echo "新HDD FSx ID: $NEW_FSX_ID"

# Active Directory参加確認
aws fsx describe-file-systems --file-system-ids $NEW_FSX_ID --region ap-northeast-1 --profile your-profile
```

### 2-3. 接続テスト
```bash
# 新システムへの基本接続確認
# DNS名の確認
# セキュリティグループ設定確認
```

## Phase 3: データ移行実行（Day 1-2）

### 3-1. DataSync設定・実行
```bash
# 注意: DataSync作成前に必ず承認を得る
# ソース: 既存SSD FSx (fs-0b2d61a3f2654a9a3)
# ターゲット: 新HDD FSx ($NEW_FSX_ID)

# 移行開始時刻記録
echo "データ移行開始: $(date)" >> migration_log.txt

# 移行進捗監視
./scripts/fsx_performance_monitor.sh $NEW_FSX_ID your-profile ap-northeast-1 1
```

### 3-2. 移行監視・最適化
```bash
# 移行進捗確認（1時間毎）
while true; do
  echo "$(date): 移行状況確認中..."
  # DataSync進捗確認コマンド
  sleep 3600
done

# 推定完了時間: 8-12時間
```

### 3-3. 差分同期準備
```bash
# 初回移行完了後、差分同期実行
# 既存FSxを読み取り専用モードに変更（業務時間外）
echo "差分同期開始: $(date)" >> migration_log.txt
```

## Phase 4: 切り替え実行（Day 2-3, 業務時間外）

### 4-1. 最終差分同期
```bash
# 業務停止後の最終差分同期
# 推定時間: 30分-2時間

# 同期完了確認
echo "最終同期完了: $(date)" >> migration_log.txt
```

### 4-2. 接続先変更
```bash
# DNS設定変更
# アプリケーション設定変更
# 接続先をHDD FSxに変更

# 変更完了時刻記録
echo "接続先変更完了: $(date)" >> migration_log.txt
```

### 4-3. 動作確認
```bash
# 新HDD FSxでの基本動作確認
./scripts/fsx_describe.sh your-profile ap-northeast-1

# 性能テスト
./scripts/fsx_performance_monitor.sh $NEW_FSX_ID your-profile ap-northeast-1 1

# ユーザー接続テスト
# ファイルアクセステスト
```

## Phase 5: 並行稼働・監視（Day 3-5）

### 5-1. 性能監視
```bash
# 日次性能チェック
./scripts/fsx_performance_monitor.sh $NEW_FSX_ID your-profile ap-northeast-1 1

# ユーザー体感確認
# 業務アプリケーション動作確認
```

### 5-2. 問題発生時の切り替え判断
```bash
# 切り替え基準
# - ユーザーからの苦情多発
# - 業務に重大な影響
# - 性能が許容範囲を超えて悪化

# 切り替え実行（必要時）
./scripts/fsx_create.sh templates/fsx_ssd_single_az_template.json your-profile ap-northeast-1
```

## Phase 6: 旧システム削除（Day 5-7）

### 6-1. 最終確認
```bash
# 新システムの安定稼働確認（3日以上）
# 全ユーザーの動作確認完了
# 性能問題なし
# データ整合性確認完了
```

### 6-2. 最終バックアップ・削除
```bash
# 最終バックアップ作成
aws fsx create-backup \
  --file-system-id fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile \
  --tags Key=Purpose,Value=FinalBackupBeforeDeletion

# 削除実行（注意: 取り消し不可）
aws fsx delete-file-system \
  --file-system-id fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile

echo "旧FSx削除完了: $(date)" >> migration_log.txt
```

### 6-3. 最適化実行
```bash
# スループット最適化（32MB/s → 16MB/s）
aws fsx modify-file-system \
  --file-system-id $NEW_FSX_ID \
  --windows-configuration ThroughputCapacity=16 \
  --region ap-northeast-1 \
  --profile your-profile
```

## 緊急時対応手順

### ロールバック手順
```bash
# 新HDD FSxで問題発生時
# 1. 既存SSD FSxへの接続復旧
# 2. 新HDD FSxの一時停止
# 3. 問題分析・対策検討
```

### エスカレーション基準
- データ損失の可能性
- 業務停止が2時間以上継続
- 復旧見込みが立たない場合

## 作業完了チェックリスト

### 技術的確認
- [ ] 新HDD FSxの正常稼働
- [ ] 全データの移行完了
- [ ] 性能が許容範囲内
- [ ] バックアップ設定完了
- [ ] 旧FSx削除完了

### 業務的確認
- [ ] 全ユーザーの動作確認
- [ ] 業務アプリケーション正常稼働
- [ ] 性能に関する苦情なし
- [ ] 関係者への完了報告

### コスト確認
- [ ] 月額料金削減効果の確認
- [ ] 一時的追加コストの精算
- [ ] 年間削減効果の試算更新

---
**重要**: 各段階で問題が発生した場合は、無理に進めず一旦停止して状況を整理すること。切り替えオプション（SSD Single-AZ）も準備済みのため、柔軟な対応が可能。
