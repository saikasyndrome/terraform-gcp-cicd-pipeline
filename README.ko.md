# SRE 온보딩 과제 (클라우드 리프트 편)

이 리포지토리는 SRE(Site Reliability Engineering) 온보딩 과제 학습을 위해 작성되었습니다.
본 과제에서는 Google Cloud Platform (GCP) 상에서 인프라스트럭처를 구축하는 방법을 학습합니다.

## 목적

이 리포지토리의 목적은 다음 스킬을 습득하는 것입니다:

- Terraform을 사용한 인프라스트럭처의 코드화
- GCP 리소스 관리와 배포
- 건전한 클라우드 환경의 구축과 관리

## 디렉토리 구성

리포지토리 내의 디렉토리 구성은 다음과 같습니다:

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

## 코드 실행 방법
다음 순서에 따라 이 리포지토리의 코드를 실행합니다:

GCP 프로젝트 설정 후

## Terraform 설치

Terraform을 설치합니다.
리포지토리 클론

이 리포지토리를 로컬 머신에 클론합니다.
```zsh
git clone https://github.com/saikasyndrome/terraform-gcp-cicd-pipeline
cd your-repo-name
```
    
## Terraform 초기화

Terraform을 초기화하고 필요한 프로바이더를 다운로드합니다.
```zsh
terraform init
```
## Terraform 워크스페이스 선택
Terraform 워크스페이스를 선택합니다. dev 또는 prd 워크스페이스를 선택함으로써 환경별로 다른 설정을 적용할 수 있습니다.

```zsh
terraform workspace select dev
```

### 또는

```zsh
terraform workspace select prd
```

## 환경별 설정

dev 워크스페이스: 개발 환경에 대응하는 리소스가 생성됩니다.
prd 워크스페이스: 운영 환경에 대응하는 리소스가 생성됩니다.

## Terraform 플랜 생성

실행 플랜을 생성하고 리소스가 어떻게 생성될지 확인합니다.

```zsh
terraform plan
```
    
## Terraform 적용

실행 플랜을 적용하여 리소스를 생성합니다.

```zsh
terraform apply
```
    
## 정리

생성한 리소스를 삭제하는 경우 다음 명령어를 실행합니다.

```zsh
terraform destroy
```
    
## 주의사항
GCP 프로젝트의 리소스 생성에는 비용이 발생할 수 있습니다. 리소스의 생성과 삭제를 적절히 관리해 주세요.
IAM 권한이 부족한 경우 적절한 권한을 가진 계정으로 실행해 주세요.
