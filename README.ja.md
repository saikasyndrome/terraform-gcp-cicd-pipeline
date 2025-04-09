# SRE オンボーディング課題（クラウドリフト編）

このリポジトリは、SRE（Site Reliability Engineering）のオンボーディング課題に取り組み勉強のために作成されました。
本課題では、クGoogle Cloud Platform (GCP) 上でインフラストラクチャを構築する方法を学びます。

## 目的

このリポジトリの目的は、以下のスキルを習得することです：

- Terraform を使用したインフラストラクチャのコード化
- GCP リソースの管理とデプロイ
- 健全なクラウド環境の構築と管理

## ディレクトリ構成

リポジトリ内のディレクトリ構成は以下の通りです：

```plaintext
.
├── README.md
├── cloud_build
│   ├── apply.yaml
│   └── pr-plan.yaml
├── config
├── terraform
│   ├── backend.tf
│   ├── cloud_armor.tf
│   ├── firewall.tf
│   ├── instance_group.tf
│   ├── instance_template.tf
│   ├── load_balancer.tf
│   ├── network.tf
│   ├── secrets.tf
│   ├── service_account.tf
│   ├── sql.tf
│   └── versions.tf
```

## コードを実行する方法
以下の手順に従って、このリポジトリのコードを実行します：

GCP プロジェクトの設定後

## Terraform のインストール

Terraform をインストールします。
リポジトリのクローン

このリポジトリをローカルマシンにクローンします。
```zsh
git clone https://github.com/saikasyndrome/terraform-gcp-cicd-pipeline
cd your-repo-name
```
    
## Terraform の初期化

Terraform を初期化して、必要なプロバイダーをダウンロードします。
```zsh
terraform init
```
##Terraform ワークスペースの選択
Terraform ワークスペースを選択します。dev または prd ワークスペースを選択することで、環境ごとに異なる設定を適用できます。

```zsh
terraform workspace select dev
```

### または

```zsh
terraform workspace select prd
```

## 環境ごとの設定

dev ワークスペース: 開発環境に対応するリソースが作成されます。
prd ワークスペース: 本番環境に対応するリソースが作成されます。

## Terraform プランの作成

実行プランを作成し、リソースがどのように作成されるかを確認します。
```zsh
terraform plan
```
    
## Terraform の適用

実行プランを適用して、リソースを作成します。
```zsh
terraform apply
```
    
## クリーンアップ

作成したリソースを削除する場合は、以下のコマンドを実行します。

```zsh
terraform destroy
```
    
## 注意事項
GCP プロジェクトのリソース作成には料金が発生する場合があります。リソースの作成と削除を適切に管理してください。
IAM 権限が不足している場合、適切な権限を持つアカウントで実行してください。
