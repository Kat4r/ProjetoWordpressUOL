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

![Arquitetura do Projeto](imagens/image.png)

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

   - **AMI:** Sistema linux de sua preferência
   - **Tipo de Instância:** t2.micro (ou conforme a necessidade)
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
     - **Username:** `Seu usuário`
     - **Password:** `Sua senha segura`
   - **VPC:** `MinhaVPC`
   - **Subnet Group:** Subnets privadas
   - **Public Accessibility:** No
   - **Security Group:** `SG-RDS`

2. **Configurar o Banco de Dados:**

   - **Database Name:** `NOME DO BANCO DE DADOS`

3. **Conceder Acesso ao Usuário:**

   - Usando o cliente MySQL, crie o banco de dados e conceda privilégios.

   ```sql
   CREATE DATABASE wordpressdb DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
   CREATE USER 'vini'@'%' IDENTIFIED BY 'sua_senha_segura';
   GRANT ALL PRIVILEGES ON wordpressdb.* TO 'vini'@'%';
   FLUSH PRIVILEGES;
   ```

## 9. Configuração do Load Balancer Clássico

1. **Criar o Classic Load Balancer**:
   - Nome: `MeuCLB`
   - VPC: `MinhaVPC`
   - **Listeners**:
     - Load Balancer Protocol: HTTP, Port 80
     - Instance Protocol: HTTP, Port 80
   - **Subnets**: `Subnet-Publica`
   - **Security Group**: `SG-LoadBalancer`

2. **Configurar o Health Check**:
   - Ping Protocol: HTTP
   - Ping Port: 80
   - Ping Path: `/healthcheck.html`

3. **Registrar Instâncias**:
   - Adicione a instância EC2 privada.
     
## 10. Implantação do WordPress com Docker

### 1. Instalar Docker e Docker Compose na Instância EC2:

```bash
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
### 2. Criar o arquivo ```docker-compose.yaml```
```version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: wordpressdb.c3u8iiyg6cb.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: vini
      WORDPRESS_DB_PASSWORD: sua_senha_segura
      WORDPRESS_DB_NAME: wordpressdb
    volumes:
      - ./wp-content:/var/www/html
```

### 3. Implementar Wordpress
```
mkdir ~/wordpress && cd ~/wordpress
nano docker-compose.yml  # Cole o conteúdo acima
docker-compose up -d
```

### 4. Criar o Arquivo ```healthcheck.html```
```
sudo touch healthcheck.html
echo "OK" > /healthcheck.html
```

### 5. Verificar logs e status

```
docker ps
docker logs <id-do-conteiner>
```

## 11. Testes e Validação

1. **Verificar o Status do Load Balancer**:
   - Certifique-se de que a instância está `InService`.

2. **Acessar o WordPress via Navegador**:
   - Acesse: `http://<DNS-do-Load-Balancer>`.

3. **Concluir a Instalação do WordPress**:
   - Siga as instruções na tela para configurar o WordPress.

---

## Considerações de Segurança

- **Proteção de Credenciais**:
  - Evite expor senhas em arquivos públicos.
  - Considere o uso de variáveis de ambiente seguras ou AWS Secrets Manager.

- **Security Groups Restritivos**:
  - Mantenha as regras dos Security Groups tão restritivas quanto possível.

- **Atualizações e Patches**:
  - Mantenha o WordPress e os plugins atualizados.

- **Backups**:
  - Implemente soluções de backup para o banco de dados RDS e para os dados do WordPress.

---

## Próximos Passos

- **Implementar HTTPS**:
  - Configure certificados SSL para o Load Balancer usando o AWS Certificate Manager.

- **Escalabilidade**:
  - Considere adicionar Auto Scaling Groups para a instância EC2.

- **Monitoramento**:
  - Configure logs e métricas usando o AWS CloudWatch.

- **Automatização**:
  - Use ferramentas como AWS CloudFormation ou Terraform para automatizar a infraestrutura.

## Referências

- [Documentação AWS VPC](https://aws.amazon.com/vpc/)
- [Documentação AWS EC2](https://aws.amazon.com/ec2/)
- [Documentação AWS RDS](https://aws.amazon.com/rds/)
- [Documentação Docker](https://docs.docker.com/)
- [Documentação WordPress](https://wordpress.org/support/)

---

## Estrutura do Repositório

- `README.md`: Documentação detalhada do projeto (este arquivo).
- `docker-compose.yml`: Arquivo de configuração do Docker Compose.
- `scripts/`: (Opcional) Scripts auxiliares.
- `diagrams/`: (Opcional) Diagramas da arquitetura.

---


