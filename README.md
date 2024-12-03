# **Projeto WordPress CompassUOL (AWS Cloud)**

Este projeto demonstra como implantar uma aplicação WordPress em uma instância EC2 privada na AWS, usando Docker e Docker Compose, conectando-se a um banco de dados RDS, e tornando o site acessível através de um Classic Load Balancer. A infraestrutura inclui VPC, subnets públicas e privadas, NAT Gateway, Security Groups e outras configurações essenciais.

## **Sumário**

- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Passo a Passo](#passo-a-passo)
  - [1. Configuração da VPC](#1-configuração-da-vpc)
  - [2. Configuração das Subnets](#2-configuração-das-subnets)
  - [3. Configuração do Internet Gateway](#3-configuração-do-internet-gateway)
  - [4. Configuração do NAT Gateway](#4-configuração-do-nat-gateway)
  - [5. Configuração das Tabelas de Roteamento](#5-configuração-das-tabelas-de-roteamento)
  - [6. Configuração dos Security Groups](#6-configuração-dos-security-groups)
  - [7. Lançamento da Instância EC2 Privada](#7-lançamento-da-instância-ec2-privada)
  - [8. Configuração do RDS MySQL](#8-configuração-do-rds-mysql)
  - [9. Configuração do Load Balancer Clássico](#9-configuração-do-load-balancer-clássico)
  - [10. Implantação do WordPress com Docker](#10-implantação-do-wordpress-com-docker)
  - [11. Testes e Validação](#11-testes-e-validação)
- [Considerações de Segurança](#considerações-de-segurança)
- [Próximos Passos](#próximos-passos)
- [Referências](#referências)

---

## **Arquitetura do Projeto**

![Arquitetura do Projeto](https://drive.google.com/file/d/117ltQzDs4j78o7_TgwsZxHq_613w6ECZ/view?usp=drive_link)

*Nota: Inclua um diagrama representando a arquitetura, mostrando a VPC, subnets, instância EC2, RDS, NAT Gateway e Load Balancer.*

---

## **Pré-requisitos**

- Conta na AWS com permissões adequadas.
- Chave SSH para acesso às instâncias EC2.
- Conhecimento básico em AWS, Docker e WordPress.
- AWS CLI e ferramentas de gerenciamento (opcional).

---

## **Passo a Passo**

### **1. Configuração da VPC**

1. **Criar uma VPC:**

   - **Nome:** `MinhaVPC`
   - **Bloco CIDR IPv4:** `10.0.0.0/16`

2. **No Console da AWS:**

   - Acesse o serviço **VPC**.
   - Selecione **Your VPCs** e clique em **Create VPC**.
   - Insira os detalhes acima e crie a VPC.

### **2. Configuração das Subnets**

1. **Criar Subnet Pública:**

   - **Nome:** `Subnet-Publica`
   - **Bloco CIDR:** `10.0.1.0/24`
   - **Zona de Disponibilidade:** `us-east-1a`

2. **Criar Subnet Privada:**

   - **Nome:** `Subnet-Privada`
   - **Bloco CIDR:** `10.0.2.0/24`
   - **Zona de Disponibilidade:** `us-east-1a`

3. **No Console da AWS:**

   - Acesse **Subnets** dentro do serviço VPC.
   - Crie as subnets com os detalhes acima.

### **3. Configuração do Internet Gateway**

1. **Criar e Associar o Internet Gateway:**

   - **Nome:** `MeuIGW`
   - **Associar à VPC:** `MinhaVPC`

2. **Passos:**

   - Acesse **Internet Gateways** no serviço VPC.
   - Crie o IGW e associe-o à VPC.

### **4. Configuração do NAT Gateway**

1. **Criar o NAT Gateway:**

   - **Subnet:** `Subnet-Publica`
   - **Elastic IP:** Alocar um novo Elastic IP

2. **Passos:**

   - Acesse **NAT Gateways** no serviço VPC.
   - Crie o NAT Gateway com os detalhes acima.

### **5. Configuração das Tabelas de Roteamento**

1. **Tabela de Roteamento da Subnet Pública:**

   - **Rota:** `0.0.0.0/0` via **Internet Gateway** (`MeuIGW`)

2. **Tabela de Roteamento da Subnet Privada:**

   - **Rota:** `0.0.0.0/0` via **NAT Gateway** (`MeuNATGateway`)

3. **Passos:**

   - Acesse **Route Tables** no serviço VPC.
   - Atualize as tabelas de roteamento conforme necessário.

### **6. Configuração dos Security Groups**

1. **Security Group para a Instância EC2 Privada (`SG-Privado`):**

   - **Regras de Entrada:**
     - **Type:** HTTP
     - **Port Range:** 80
     - **Source:** `SG-LoadBalancer` (será criado)
     - **Type:** SSH (opcional, apenas se usar Bastion Host)
     - **Port Range:** 22
     - **Source:** `SG-Bastion`

2. **Security Group para o Load Balancer (`SG-LoadBalancer`):**

   - **Regras de Entrada:**
     - **Type:** HTTP
     - **Port Range:** 80
     - **Source:** `0.0.0.0/0`

3. **Security Group para o RDS (`SG-RDS`):**

   - **Regras de Entrada:**
     - **Type:** MySQL/Aurora
     - **Port Range:** 3306
     - **Source:** `SG-Privado`

### **7. Lançamento da Instância EC2 Privada**

1. **Configurações da Instância:**

   - **AMI:** Amazon Linux 2
   - **Tipo de Instância:** t2.micro
   - **Subnet:** `Subnet-Privada`
   - **Auto-assign Public IP:** Desabilitado
   - **Security Group:** `SG-Privado`

2. **Passos:**

   - Acesse o serviço **EC2**.
   - Lance uma nova instância com os detalhes acima.

### **8. Configuração do RDS MySQL**

1. **Criar o Banco de Dados RDS:**

   - **Engine:** MySQL
   - **Versão:** Compatível com o WordPress
   - **Instância:** db.t2.micro
   - **Credenciais:**
     - **Username:** `vini`
     - **Password:** `sua_senha_segura`
   - **VPC:** `MinhaVPC`
   - **Subnet Group:** Subnets privadas
   - **Public Accessibility:** No
   - **Security Group:** `SG-RDS`

2. **Configurar o Banco de Dados:**

   - **Database Name:** `wordpressdb`

3. **Conceder Acesso ao Usuário:**

   - Usando o cliente MySQL, crie o banco de dados e conceda privilégios.

   ```sql
   CREATE DATABASE wordpressdb DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
   CREATE USER 'vini'@'%' IDENTIFIED BY 'sua_senha_segura';
   GRANT ALL PRIVILEGES ON wordpressdb.* TO 'vini'@'%';
   FLUSH PRIVILEGES;
