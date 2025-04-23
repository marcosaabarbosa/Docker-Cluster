# Cluster Local com Docker (Debian + WSL2)

Este projeto cria um **cluster local** de três nós usando containers Docker baseados em **Debian**. Ele inclui:

- Um **balanceador de carga (Nginx)** que distribui requisições HTTP entre os nós (round-robin);
- Compartilhamento de diretórios entre os nós via volume comum (`/shared`);
- Instalação automática de ferramentas essenciais como Python3, curl e net-tools;
- Tudo orquestrado via **Docker Compose**, ideal para uso em WSL2 no Windows 11.

## Componentes

- **3 containers Debian** atuando como nós do cluster
- **1 container Nginx** como load balancer (porta 8080)
- **Volume compartilhado** entre todos os nós montado em `/shared`

## Requisitos

- Windows 11 com **WSL2 habilitado**
- Docker Desktop com suporte ao WSL2
- Git Bash ou terminal WSL (Ubuntu, Debian etc)

## Estrutura de Pastas

```bash
meu-cluster-docker/
├── Dockerfile
├── docker-compose.yml
├── nginx.conf
└── shared/
```

## Dockerfile (Imagem base dos nós)

```dockerfile
FROM debian:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 curl net-tools iputils-ping \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app
EXPOSE 8000
CMD sh -c "\
  echo \"<h1>Olá, eu sou o ${NODE_NAME:-Nó}!</h1>\" > /app/index.html && \
  echo \"Arquivo criado por ${NODE_NAME:-nó}\" > /shared/${NODE_NAME:-nó}.txt && \
  exec python3 -m http.server 8000"
```

## nginx.conf (Balanceador de carga)

```nginx
events { }
http {
    upstream cluster_nodes {
        server node1:8000;
        server node2:8000;
        server node3:8000;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://cluster_nodes;
        }
    }
}
```

## docker-compose.yml

```yaml
version: '3.8'
services:
  node1:
    build: .
    container_name: node1
    environment:
      - NODE_NAME=node1
    volumes:
      - ./shared:/shared

  node2:
    build: .
    container_name: node2
    environment:
      - NODE_NAME=node2
    volumes:
      - ./shared:/shared

  node3:
    build: .
    container_name: node3
    environment:
      - NODE_NAME=node3
    volumes:
      - ./shared:/shared

  loadbalancer:
    image: nginx:latest
    container_name: loadbalancer
    depends_on:
      - node1
      - node2
      - node3
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

## Como usar

### 1. Suba o cluster:
```bash
docker-compose up -d --build
```

### 2. Acesse no navegador:
```
http://localhost:8080
```

### 3. Teste o volume compartilhado:
```bash
ls shared/
```

### 4. Teste ping/curl entre containers:
```bash
docker exec node1 ping node2
```
```bash
docker exec node1 curl node3:8000
```

## Finalização

Para encerrar o cluster:
```bash
docker-compose down
```

## Conclusão

Este projeto é uma base perfeita para simular ambientes DevOps com balanceamento de carga, compartilhamento de dados e ferramentas essenciais, tudo em containers Debian e com execução local via WSL2 + Docker Desktop.

Ideal para aprender conceitos de cluster, testes de rede e automação com Compose.
