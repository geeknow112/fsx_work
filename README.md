# FSx Management Scripts

Amazon FSx ファイルシステムを管理するためのAWS CLIスクリプト集です。

## 前提条件

- AWS CLI がインストール済み
- 適切なIAM権限が設定済み
- jq がインストール済み（一部スクリプトで使用）

## ディレクトリ構成

```
├── scripts/           # 実行スクリプト
├── templates/         # 作成用テンプレート
├── examples/          # 使用例
└── README.md         # このファイル
```

## スクリプト一覧

### 1. FSx情報取得 (`scripts/fsx_describe.sh`)

既存のFSxファイルシステム情報を取得します。

```bash
# デフォルト設定で実行
./scripts/fsx_describe.sh

# プロファイルとリージョンを指定
./scripts/fsx_describe.sh lober-system ap-northeast-1
```

### 2. パフォーマンス監視 (`scripts/fsx_performance_monitor.sh`)

FSxファイルシステムのパフォーマンスメトリクスを取得します。

```bash
# 基本的な使用方法
./scripts/fsx_performance_monitor.sh fs-xxxxxxxxx

# 詳細指定
./scripts/fsx_performance_monitor.sh fs-xxxxxxxxx lober-system ap-northeast-1 14
```

### 3. FSx作成 (`scripts/fsx_create.sh`)

テンプレートを使用してFSxファイルシステムを作成します。

```bash
# 32GB HDD検証用作成
./scripts/fsx_create.sh templates/fsx_hdd_32gb_verification.json lober-system ap-northeast-1

# Windows File Server作成
./scripts/fsx_create.sh templates/fsx_windows_template.json

# Lustre作成
./scripts/fsx_create.sh templates/fsx_lustre_template.json lober-system ap-northeast-1
```

### 4. ストレージ容量拡張 (`scripts/fsx_expand_storage.sh`) **NEW**

FSxファイルシステムのストレージ容量を拡張します。

```bash
# 32GB → 7.2TB拡張
./scripts/fsx_expand_storage.sh fs-xxxxxxxxx 7200 lober-system ap-northeast-1

# 基本的な使用方法
./scripts/fsx_expand_storage.sh <file-system-id> <target-capacity-gb> [profile] [region]
```

## テンプレート

### 32GB HDD検証用 (`templates/fsx_hdd_32gb_verification.json`) **NEW**

- Multi-AZ構成
- 32GB HDDストレージ
- 16 MB/sスループット
- Active Directory統合
- パフォーマンス検証用設定

### Windows File Server (`templates/fsx_windows_template.json`)

- Single-AZ構成
- 32GB SSDストレージ
- 8 MB/sスループット
- Active Directory統合

### Lustre (`templates/fsx_lustre_template.json`)

- Scratch 2構成
- 1.2TBストレージ
- S3統合設定

## 使用前の設定

1. テンプレートファイル内の以下の値を環境に合わせて変更してください：
   - `subnet-xxxxxxxxx` → 実際のサブネットID
   - `sg-xxxxxxxxx` → 実際のセキュリティグループID
   - `d-xxxxxxxxx` → 実際のActive Directory ID（Windows用）
   - `your-bucket-name` → 実際のS3バケット名（Lustre用）

2. スクリプトに実行権限を付与：
```bash
chmod +x scripts/*.sh
```

## 注意事項

- 本番環境での実行前に必ずテスト環境で動作確認を行ってください
- FSxの作成・変更は課金が発生します
- 企業固有の情報（実際のリソースID、IPアドレス等）は含まれていません
- 実際の使用時は環境に合わせてパラメータを調整してください

## ライセンス

MIT License
