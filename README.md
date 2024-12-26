# Wordpress e Docker na AWS

Estrutura do Wordpress com Docker no ambiente da AWS

## Introdução
O projeto a seguir orienta sobre o desenvolvimento de uma aplicação Wordpress através do Docker dentro de uma nuvem privada virtual (Virtual Private Cloud - VPC) no ambiente da AWS, utilizando recursos como instâncias, banco de dados e estruturas de rede dentro desse mesmo ambiente.

### Arquitetura proposta para o projeto

<img src="/img/arq.png" alt="arquitetura">

### Requisitos

- Conta na AWS
- Docker
- Script para Start Instance (user_data.sh)
- Wordpress
- RDS (MySQL)
- EFS (Elastic File Systema - AWS)
- Load Balancer Classic (Balanceador de Carga - AWS)
- Git

## Etapa 01

Criar VPC e suas sub-redes (seguir esquema abaixo):
- 02 públicas
- 02 privadas

<img src="/img/imagem (3).png" alt="VPC">

- associar as sub-redes em gateways

<img src="/img/nat.png" alt="NatGateway">

- criar tabelas de rotas e associar às suas respectivas sub-redes

## Etapa 02

Criar grupos de segurança

- 01 público

| Tipo | Protocolo | Porta | Origem |
|------|-----------|-------|-------- |
| SSH | TCP | 22 | 0.0.0.0/0 |
| HTTP | TCP | 80 | 0.0.0.0/0 |

<img src="/img/imagem (4).png" alt="publico">

- 01 privado

| Tipo | Protocolo | Porta | Origem |
|------|-----------|-------|-------- |
| HTTP | TCP | 80 | G. seg. público |
| SSH | TCP | 22 | 0.0.0.0/0 |
| MySQL/Aurora | TCP | 3306 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | G. seg. público |

<img src="/img/imagem (5).png" alt="privado">

## Etapa 03

Criar RSD (Banco de dados) seguindo os seguintes parâmetros:

- opções do mecanismo >> MySQL

- disponibilidade e durabilidade >> instância de banco de dados única

- gerenciamento de credenciais >> autogerenciada

- configuração da instância >> db.t3.micro

- grupo de segurança de VPC >> grupo de segurança privado

- configuração adicional >> nome do banco de dados inicial >> wordpressdb

<img src="/img/rds.png" alt="rds">

## Etapa 04

Criar EFS seguindos estes parâmetros:

- selecionar VPC criada anteriormente
- selecionar sub-redes privadas e grupo de segurança privado

<img src="/img/efs.png" alt="efs">

## Etapa 05

Criar Load Balancers seguindo estes parâmetros:

- tipo >> Classic Load Balancer

- voltado para a Internet

- IPv4

- VPC criado anteriormente e selecionar sub-redes públicas

- grupo de segurança privado

- listeners >> grupo de segurança público

- verificações de integridade >> /wp-admin/install.php

- instâncias >> EC2 criadas

## Etapa 06

Criar duas instâncias EC2 através de modelos de execução:

- imagem >> Amazon Linux 2
- tipo >> t2.micro
- selecionar VPC criada anteriormente
- selecionar sub-redes privadas criadas anteriormente
- selecionar grupo de segurança privado

## Etapa 07

Criar o script do user_data.sh

<img src="/img/imagem.png" alt="user_data">

## Etapa 08

Criar Auto Scaling
- modelo de execução >> WP-webserver (criado anteriormente)

- versão >> latest

- selecionar VPC

- selecionar apenas zonas de disponibilidade privadas

- selecionar load balancer classic criado anteriormente

- selecionar verificações de integridade do Elastic Load Balancing

- selecionar capacidade desejada >> 2

- selecionar capacidade mínima desejada >> 2

- selecionar capacidade máxima desejada >> 2

## Etapa 09 (opicional)

Acessar EC2 via SSH

- usuário >> ec2-user
- senha >> par de chaves criadas no ambiente AWS

Acessar página Wordpress

- selecionar DNS do Load Balancer
- usar no navegador o DNS >> "http://(DNS so LoadBalancer)"
