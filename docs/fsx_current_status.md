# FSx 現在の利用状況

## 概要
- 調査日時: 2025-08-02
- プロファイル: your-profile
- リージョン: ap-northeast-1

## 現在のFSxファイルシステム

### SV-FILE (fs-0b2d61a3f2654a9a3)
- **タイプ**: Amazon FSx for Windows File Server
- **ステータス**: AVAILABLE
- **作成日**: 2023-10-02T15:11:50.102000+09:00
- **ストレージ容量**: 7,200 GB (7.2 TB)
- **ストレージタイプ**: SSD
- **スループット容量**: 32 MB/s
- **デプロイメントタイプ**: MULTI_AZ_1

### ネットワーク設定
- **VPC ID**: vpc-6c0ea60b
- **サブネット**: 
  - subnet-xxxxxxxxx (優先)
  - subnet-yyyyyyyyy
- **DNS名**: amznfsxzhvxsuy4.company.local
- **管理エンドポイント**: amznfsxwiqlhcih.company.local
- **優先ファイルサーバーIP**: <IP_ADDRESS>

### Active Directory設定
- **ドメイン**: company.local
- **管理者グループ**: fsx-group
- **管理者ユーザー**: fsx-admin
- **DNS IP**: 172.16.3.182

### エイリアス
- srv-file.company.local
- sv-file.company.local
- svr-file.company.local

### バックアップ設定
- **自動バックアップ開始時間**: 16:00
- **保持期間**: 30日
- **タグのコピー**: 無効

### メンテナンス設定
- **週次メンテナンス開始時間**: 木曜日 19:30 (4:19:30)

### IOPS設定
- **モード**: AUTOMATIC
- **IOPS**: 21,600

### 監査ログ
- **ファイルアクセス監査**: 無効
- **ファイル共有アクセス監査**: 無効

### 暗号化
- **KMS キー**: arn:aws:kms:ap-northeast-1:<ACCOUNT_ID>:key/0a3a4c2b-53a5-4085-a13f-718694ff69c4
