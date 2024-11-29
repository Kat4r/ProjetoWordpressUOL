# Projeto Wordpress (Compass UOL)

### 

## Índice

- [Descrição](#descrição)
- [Ferramentas](#ferramentas)
- [Configuração do Ambiente na AWS](#configuração-do-ambiente-na-aws)
  - [1. Criação da Instância EC2](#1-criação-da-instância-ec2)
  - [2. Configuração do EFS](#2-configuração-do-efs)
  - [3. Configuração do RDS MySQL](#3-configuração-do-rds-mysql)
- [Deploy da Aplicação](#deploy-da-aplicação)
  - [1. Clonar o Repositório](#1-clonar-o-repositório)
  - [2. Configurar Variáveis de Ambiente](#2-configurar-variáveis-de-ambiente)
  - [3. Executar o Docker Compose](#3-executar-o-docker-compose)
  - [4.  Automação com user_data.sh](#4-automação-com-user_data.sh)
- [Verificar logs](#verificar-logs)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Descrição

Este projeto implementa uma aplicação WordPress utilizando contêineres Docker na AWS. Utiliza o Amazon EFS para armazenamento persistente dos arquivos estáticos e Amazon RDS para o banco de dados MySQL.

## Ferramentas
  - Git
  - Docker
  - Docker Compose

## Configuração do Ambiente na AWS

### 1. Criação da Instância EC2

1. **Acesse o Console da AWS** e navegue até o serviço EC2.
2. **Clique em "Launch Instance"** e configure:
   - **AMI:** Ubuntu Server 24.04 LTS (ou outra de sua preferência).
   - **Tipo de Instância:** t2.micro (para testes) ou conforme a necessidade.
   - **Configurações de Rede:** Certifique-se de que a instância está na mesma VPC que o EFS e o RDS.
   - **Grupos de Segurança:** 
     - Permitir tráfego HTTP (porta 80) e SSH (porta 22) para acesso.
     - Permitir tráfego na porta 2049 para o EFS.
3. **Configurar User Data:**
   - Insira o script `user_data.sh` (ver [Deploy da Aplicação](#deploy-da-aplicação)).
4. **Lançar a Instância** e aguardar a inicialização.

### 2. Configuração do EFS

1. **Acesse o Console da AWS** e navegue até o serviço EFS.
2. **Clique em "Create file system"** e configure:
   - **VPC:** Selecione a mesma VPC da sua instância EC2.
   - **Configurações de Segurança:** Configure os grupos de segurança para permitir tráfego na porta TCP 2049 da instância EC2.
3. **Criar o Sistema de Arquivos** e anotar o ID do EFS (por exemplo, `fs-xxxxxxxxx`).

### 3. Configuração do RDS MySQL

1. **Acesse o Console da AWS** e navegue até o serviço RDS.
2. **Clique em "Create database"** e selecione **MySQL**.
3. **Configurações de Instância:**
   - **Tipo de Instância:**  conforme a necessidade.
   - **Armazenamento:** Conforme a necessidade. (20Gb usados por default)
   - **VPC:** Mesma VPC da instância EC2 e EFS.
   - **Grupos de Segurança:** Permitir tráfego na porta 3306 apenas da instância EC2.
4. **Configurar Banco de Dados:**
   - **Nome do Banco:** `<nome-do-banco>`
   - **Usuário Master:** `<usuário>`
   - **Senha Master:** `<senha-de-acesso>`
5. **Criar o Banco de Dados** e anotar o endpoint.


## Deploy da Aplicação

### 1. Clonar o Repositório

Na sua máquina local ou na instância EC2, clone o repositório Git:

```bash
git clone https://seu-repositorio-git.git
cd seu-repositorio-git
```

### 2. Configurar Variáveis de Ambiente
```
touch .env
```
Edite o `.env` com as seguintes variáveis (substitua pelos valores reais):
```
WORDPRESS_DB_HOST=seu-endpoint-rds:3306
WORDPRESS_DB_USER=admin
WORDPRESS_DB_PASSWORD=sua-senha-secreta
WORDPRESS_DB_NAME=wordpress
```
### 3. Executar o Docker Compose
1. Iniciar os Contêineres:
```
docker-compose up -d
```
2. Verificar os Contêineres em Execução:
```
docker ps
```
3. Verificar Logs (Opcional):
```
docker-compose logs -f
```
4. Acessar o WordPress:
- Abra o navegador e acesse o seu ip público (por exemplo: `http://seu-ip-pulico:porta-para-conexão`).
- Você deve ver a tela de instalação do WordPress.

### 4. Automação com user_data.sh
1. Exemplo de arquivo para o `docker-compose.yaml` 
```
version: '3.8'

services:
  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
    volumes:
      - /efs/wp-content:/var/www/html
```

2. Arquivo `user_data.sh`
 - Por ser um arquivo longo, vou apenas deixar a menção ao mesmo no repositório [AQUI](https://github.com/Kat4r/ProjetoWordpressUOL/blob/main/user_data.sh)


## Verificar logs

 **1.** Após a inicialização da instância, verifique os logs do User Data para garantir que não houve erros durante a execução do script.
```
cd /var/log/
cat cloud-init-output.log

```

**2.** Certifique-se de que o EFS está montado corretamente:
```
df -h | grep /efs
```
**3.** Verificar Contêineres Docker
```
docker ps
docker logs <id-do-conteiner>
```




