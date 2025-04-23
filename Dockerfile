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
