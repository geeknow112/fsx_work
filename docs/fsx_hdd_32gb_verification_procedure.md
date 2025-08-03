# FSx 32GB HDD検証手順書

## 検証概要
- **目的**: HDDのパフォーマンス劣化を実際に体感・評価
- **方式**: 32GB HDD → 問題なければ7.2TBに拡張
- **利点**: データ移行不要、低コスト検証、業務停止時間ほぼゼロ

## Phase 1: 32GB HDD検証環境構築

### 1-1. 事前確認
```bash
# 現在の環境確認
./scripts/fsx_describe.sh your-profile ap-northeast-1

# 使用量確認
./scripts/fsx_performance_monitor.sh fs-0b2d61a3f2654a9a3 your-profile ap-northeast-1 7
```

### 1-2. 32GB HDD作成（承認取得後）
```bash
# テンプレート内容確認
cat ./templates/fsx_hdd_32gb_verification.json

# 32GB HDD FSx作成
./scripts/fsx_create.sh ./templates/fsx_hdd_32gb_verification.json your-profile ap-northeast-1
```

### 1-3. 作成状況監視
```bash
# 作成状況確認（20-40分）
watch -n 300 'aws fsx describe-file-systems --region ap-northeast-1 --profile your-profile --query "FileSystems[?Tags[?Key==\`Name\` && Value==\`FSx-HDD-32GB-Verification\`]].[FileSystemId,Lifecycle,StorageType,StorageCapacity]" --output table'
```

## Phase 2: HDDパフォーマンス検証

### 2-1. 基本接続確認
```bash
# 新HDD FSxのID取得
NEW_HDD_FSX_ID=$(aws fsx describe-file-systems --region ap-northeast-1 --profile your-profile --query 'FileSystems[?Tags[?Key==`Name` && Value==`FSx-HDD-32GB-Verification`] && Lifecycle==`AVAILABLE`].FileSystemId' --output text)

echo "検証用HDD FSx ID: $NEW_HDD_FSX_ID"

# DNS名確認
aws fsx describe-file-systems --file-system-ids $NEW_HDD_FSX_ID --region ap-northeast-1 --profile your-profile --query 'FileSystems[0].DNSName' --output text

# Active Directory参加確認
aws fsx describe-file-systems --file-system-ids $NEW_HDD_FSX_ID --region ap-northeast-1 --profile your-profile --query 'FileSystems[0].WindowsConfiguration.ActiveDirectoryId' --output text
```

### 2-2. パフォーマンステスト
```bash
# 基本性能監視開始
./scripts/fsx_performance_monitor.sh $NEW_HDD_FSX_ID your-profile ap-northeast-1 1

# 比較用：既存SSD FSxの性能
./scripts/fsx_performance_monitor.sh fs-0b2d61a3f2654a9a3 your-profile ap-northeast-1 1
```

### 2-3. 体感テスト項目
- [ ] **ファイル読み取り速度**（小ファイル・大ファイル）
- [ ] **ファイル書き込み速度**（小ファイル・大ファイル）
- [ ] **フォルダ一覧表示速度**
- [ ] **アプリケーション起動時間**
- [ ] **ユーザー体感での遅延感**

### 2-4. 性能比較記録
| 項目 | SSD (既存) | HDD (32GB) | 体感差 | 許容可否 |
|------|------------|------------|--------|----------|
| 小ファイル読み取り | - | - | - | - |
| 大ファイル読み取り | - | - | - | - |
| 小ファイル書き込み | - | - | - | - |
| 大ファイル書き込み | - | - | - | - |
| フォルダ一覧表示 | - | - | - | - |

## Phase 3: 判定・決定

### 3-1. 判定基準
- **許容可能**: 7.2TBに拡張して本格移行
- **許容不可**: SSD Single-AZへの移行検討
- **要追加検証**: 検証期間延長

### 3-2. 許容可能な場合の次ステップ
```bash
# 32GB → 7.2TB拡張
./scripts/fsx_expand_storage.sh $NEW_HDD_FSX_ID 7200 your-profile ap-northeast-1

# 拡張状況監視
watch -n 300 'aws fsx describe-file-systems --file-system-ids '$NEW_HDD_FSX_ID' --profile your-profile --region ap-northeast-1 --query "FileSystems[0].{StorageCapacity:StorageCapacity,AdminActions:AdministrativeActions[0].Status}" --output table'
```

## Phase 4: 本格移行（7.2TB拡張完了後）

### 4-1. データ移行
```bash
# DataSync設定（承認取得後）
# ソース: fs-0b2d61a3f2654a9a3 (既存SSD)
# ターゲット: $NEW_HDD_FSX_ID (新HDD 7.2TB)

# 移行開始時刻記録
echo "データ移行開始: $(date)" >> migration_log.txt
```

### 4-2. 並行稼働・監視
```bash
# 日次性能チェック
./scripts/fsx_performance_monitor.sh $NEW_HDD_FSX_ID your-profile ap-northeast-1 1

# 移行進捗確認
# DataSync進捗確認コマンド（設定後に追加）
```

### 4-3. 最終切り替え
```bash
# 業務時間外での最終差分同期
# DNS設定変更
# 接続先をHDD FSxに変更

echo "接続先変更完了: $(date)" >> migration_log.txt
```

### 4-4. 旧システム削除
```bash
# 3-5日間の安定稼働確認後
# 最終バックアップ作成
aws fsx create-backup \
  --file-system-id fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile \
  --tags Key=Purpose,Value=FinalBackupBeforeDeletion

# 旧SSD FSx削除（注意: 取り消し不可）
aws fsx delete-file-system \
  --file-system-id fs-0b2d61a3f2654a9a3 \
  --region ap-northeast-1 \
  --profile your-profile
```

## 緊急時対応

### ロールバック手順
```bash
# HDD検証で問題発生時
# 1. 既存SSD FSxへの接続継続
# 2. 検証用HDD FSxの削除
aws fsx delete-file-system --file-system-id $NEW_HDD_FSX_ID --profile your-profile --region ap-northeast-1
```

### 切り替えオプション
- **HDD不可の場合**: SSD Single-AZ移行（年額190万円削減）
- **部分的問題**: 重要データのみSSD、その他HDD

## 期待される効果

### コスト削減
- **32GB検証期間**: 約800円/月（極めて低コスト）
- **7.2TB本格運用**: 月額122,040円削減
- **年額削減効果**: 1,464,480円

### リスク軽減
- **段階的検証**: 実際の体感で判断
- **データ移行不要**: 容量拡張のみ
- **業務停止時間**: ほぼゼロ

## チェックリスト

### Phase 1完了
- [ ] 32GB HDD FSx作成完了
- [ ] 基本接続確認完了
- [ ] Active Directory参加確認

### Phase 2完了
- [ ] パフォーマンステスト実施
- [ ] 体感テスト完了
- [ ] 性能比較記録作成
- [ ] 判定結果決定

### Phase 3完了
- [ ] 7.2TB拡張実行（許容可能な場合）
- [ ] 拡張完了確認
- [ ] データ移行計画確定

### Phase 4完了
- [ ] データ移行完了
- [ ] 並行稼働期間完了
- [ ] 最終切り替え完了
- [ ] 旧システム削除完了

---
**重要**: 各段階で問題が発生した場合は、無理に進めず一旦停止して状況を整理すること。32GB検証の利点を活かし、リスクを最小化して進める。
