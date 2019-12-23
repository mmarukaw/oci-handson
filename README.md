# oci-handson
OCIのハンズオン用の環境を作成するための Terraform テンプレートです。
特定のコンパートメントの下に、ユーザー数分のコンパートメントを作成し、そのコンパートメントの管理権限を持つユーザーと、付随するグループ、ポリシーを作成します。
リージョンを指定すると、そのリージョンにのみリソースが作成できるユーザーを分散して作成します。
(例) ハンズオン環境を6つに指定して、リージョンに"nrt", "iad", "phx"の3つを指定すると、各リージョンに2つずつのユーザーを作成します

# 前提条件
- Terraform 0.12以上
- OCI Terraform Provider

# 使い方
1. Terraformを利用して、OCIのリソースが作成できるようにします
    - https://community.oracle.com/docs/DOC-1024538
2. environment.auto.tfvars.sample ファイルを開き、必要な情報を編集して environment.auto.tfvars という名前で保存します
3. labinfo.auto.tfvars ファイルを開き、必要な情報を入力して保存します
    - ハンズオン用コンパートメントを作成する親コンパートメント
    - 作成するハンズオン環境の数
    - 環境の作成に使用するリージョン
4. Tereraformを実行します
    - terraform init / terraform plan / terraform apply

