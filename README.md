# AMI-Builder
DevSecOps Architecture for a Virtual Enterprise – AMI Builder Repo

# 📦 DevSecOps Hardened AMI Project

이 프로젝트는 중소기업(약 200명 규모, 보안팀 5명)의 운영 환경에 적합한 **보안 Hardened AMI**를 자동으로 생성하기 위해 **Packer + Ansible + GitHub Actions (OIDC 기반)** 을 활용합니다.  
생성된 AMI는 DevOps 팀뿐만 아니라 SecOps 팀의 요구를 충족하며, **운영 계정(Operation Account)에서 생성 후 Cross-Account로 공유**하여 여러 환경에서 재사용이 가능합니다.

---

## ⚙️ 적용 기술 및 구성 요소

### ✅ Packer
- Amazon Linux 2023을 기반으로 EC2 인스턴스를 프로비저닝
- VPC/Subnet/SG 등 운영 환경에 맞는 인프라 파라미터 삽입 (현재 github actions secrets 사용 중, 추후 ssm parameter store 활용)

### ✅ Ansible
- `playbook.yml`에 따라 역할(Role) 기반으로 설정 수행
- **공통 보안 작업**: 패키지 업데이트, 불필요 서비스 제거, 로깅 강화
- **Docker 설치**: 개발 팀에서 활용 가능한 컨테이너 실행 환경 구성
- **CIS Minimal**: 필요 최소한의 보안 규칙을 자동화 적용

---

## 🛡️ 보안적 의의

- **ISMS-P의 기본 보안 요구사항**(예: 계정 관리, 패키지 업데이트, 로깅 설정 등)을 자동화된 방식으로 충족
- **코드 기반 인프라 보안** 구현을 통해 사람이 실수하기 쉬운 보안 설정을 방지
- **packer validate / lint / ansible-lint**를 통해 코드 수준의 정적 보안 분석 수행

---

## 🚀 DevSecOps 활용 시나리오

### 💼 운영 계정(Operation Account)에서 생성
- Hardened AMI는 운영 계정(Operation Account)에서 주기적으로 갱신 및 생성됨
- 생성된 AMI는 **Cross-Account 공유**를 통해 개발 계정(dev), 보안 계정(security) 등 다양한 환경에서 사용 가능

---

- **Infrastructure as Code (IaC)** 기반으로 이미지 보안 설정을 코드화
- **GitHub Actions + OIDC + AssumeRole** 조합으로 키리스(keyless)한 AMI 빌드 자동화
- **Ansible Role 기반 구성**으로 유지보수 및 역할별 책임 분리
- **CIS Benchmark 기반 최소 보안 적용** → 과한 Hardening을 지양하고 현실적인 적용 범위 유지

---
### 👥 활용 대상 팀

| 팀         | 활용 방식 |
|------------|-----------|
| **Dev 팀** | CI/CD에서 base image로 활용, 컨테이너 배포 이전 환경 통합 |
| **Security 팀** | 보안 테스트 환경 구성 시 안전한 기본 이미지로 사용 |
| **Infra 운영팀** | 신규 EC2 인스턴스 롤아웃 시 기본 AMI로 사용하여 초기 보안 작업 최소화 |

## 📌 향후 확장 포인트

- Packer template에 pre-check script 삽입 (예: yum lock check 등)
- SSM Parameter Store 사용하여 프로비저닝 하기 
- Ansible role에 SSM, CloudWatch Agent 구성 추가
- Terraform과 연동해 AMI 변경 → 신규 서버 롤아웃까지 자동화

---

## 📝 참고

- Base AMI: `Amazon Linux 2023 (ami-05377cf8cfef186c2)`
- 권장 인스턴스 타입: 
- 테스트 리전: `ap-northeast-2` (서울)
