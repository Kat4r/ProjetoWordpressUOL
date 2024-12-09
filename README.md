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

## **Passo-a-Passo para a configuração**

### **1. Configuração da VPC**

1. **No Console da AWS:**

   - Acesse o serviço **VPC**.
   - Selecione **Your VPCs** e clique em **Create VPC**.
   - Utilize a opção: **Create VPC and more**

2. **Criar uma VPC:**

   - **Nome:** `MinhaVPC`
   - **Bloco CIDR IPv4:** `x.x.x.x/16`
   


### **2. Configuração das Subnets**

1. **No Console da AWS:**

   - Acesse **Subnets** dentro do serviço VPC.

2. **Atualizar Subnet Pública:**

   - **Nome:** `Subnet-Publica`
   - **Bloco CIDR:** `x.x.x.x/24`
   - **Zona de Disponibilidade:** `AZ de acordo com a necessidade`

3. **Atualizar Subnet Privada:**

   - **Nome:** `Subnet-Privada`
   - **Bloco CIDR:** `x.x.x.x/24`
   - **Zona de Disponibilidade:** `AZ de acordo com a necessidade`



### **3. Configuração do Internet Gateway**

1. **Associar IGW ao VPC:**

   - Acesse **Internet Gateways** no serviço VPC.
   - Crie o IGW e associe-o **(Attach/Anexar)** à VPC criada.



### **4. Configuração do NAT Gateway**

1. **Criar o NAT Gateway:**
   - Acesse a guia NAT Getaway e selecione **Create NAT Getaway**
   - **Subnet:** `Subnet-Publica`
   - **Conectivade:** Public
   - **Elastic IP:** Alocar um novo Elastic IP


### **5. Configuração das Tabelas de Roteamento**

1. **Acessar tabelas**
   - Acesse **Route Tables** no serviço VPC.

2. **Acesse "Edit Routes" em cada rota na tabela de roteamento e siga a configuração:**
    - Tabela de Roteamento da Subnet Pública:
    
        - **Rota:** `x.x.x.x/y` via **Internet Gateway** (`MeuIGW`)
    
    - Tabela de Roteamento da Subnet Privada:
    
        - **Rota:** `x.x.x.x/y` via **NAT Gateway** (`MeuNATGateway`)

3. **Observação:**

   - Atualize as tabelas de roteamento conforme sua necessidade, não mantenha as rotas abertas.

### **6. Configuração dos Security Groups**

2. **Security Group para o Load Balancer (`SG-LoadBalancer`):**

   - **Regras de Entrada:**
     - **Type:** HTTP
     - **Port Range:** 80
     - **Source:** `x.x.x.x/y`

1. **Security Group para a Instância EC2 Privada (`SG-Privado`):**

   - **Regras de Entrada:**
     - **Type:** HTTP
     - **Port Range:** 80
     - **Source:** `SG-LoadBalancer`
     - **Type:** SSH (opcional, apenas se usar Bastion Host)
     - **Port Range:** 22
     - **Source:** `SG-Bastion`



3. **Security Group para o RDS (`SG-RDS`):**

   - **Regras de Entrada:**
     - **Type:** MySQL/Aurora
     - **Port Range:** 3306
     - **Source:** `SG-Privado`

### **7. Lançamento da Instância EC2 Privada**

1. **Instanciamento:**

   - Acesse o serviço **EC2**.
   - Execute uma nova instância ou crie-a a partir de um modelo (template)

2. **Configurações da Instância:**

   - **AMI:** Sistema linux de sua preferência
   - **Tipo de Instância:** t2.micro (ou conforme a necessidade)
   - **Subnet:** `Subnet-Privada`
   - **Auto-assign Public IP:** Desabilitado
   - **Security Group:** `SG-Privado`


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
   - Ping Path: `/` ou `/wp-admin/install.php`

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
      WORDPRESS_DB_HOST: <seu endpoint rds>
      WORDPRESS_DB_USER: <seu usuário>
      WORDPRESS_DB_PASSWORD: <sua senha>
      WORDPRESS_DB_NAME: <nome da database>
    volumes:
      - ./wp-content:/var/www/html
```

### 3. Implementar Wordpress
```
mkdir ~/wp && cd ~/wp
sudo vim docker-compose.yml  # Cole o conteúdo acima
docker-compose up -d
```


### 4. Verificar logs e status

```
docker ps
docker logs <id-do-conteiner>
cat /var/log/cloud-init-output.log
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
  - Evite expor suas senhas e credenciais em arquivos públicos.
  - Considere o uso de variáveis de ambiente seguras.

- **Security Groups Restritivos**:
  - Mantenha as regras dos Security Groups tão restritivas quanto possível.

- **Atualizações e Patches**:
  - Mantenha o WordPress e os plugins atualizados.

- **Backups**:
  - Implemente soluções de backup para o banco de dados RDS e para os dados do WordPress.

---


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
- `user_data.sh`: Arquivo de configuração da instância.
- `imagens/`: Diagrama da arquitetura.

---


