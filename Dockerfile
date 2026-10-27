# =========================================================================
# Stage 1: Build da aplicação com Node.js Alpine (Multi-stage build)
# =========================================================================
FROM node:22-alpine AS builder

WORKDIR /app

# Variável de build para configurar a URL da API no Vite
ARG VITE_API_URL=http://localhost:3000
ENV VITE_API_URL=$VITE_API_URL

# Copia apenas os manifestos de dependências para otimizar o cache de camadas
COPY package.json package-lock.json ./

# Instalação limpa e reproduzível das dependências
RUN npm ci

# Copia todo o código-fonte restante (respeitando o .dockerignore)
COPY . .

# Executa a compilação do TypeScript e empacotamento do Vite
RUN npm run build

# =========================================================================
# Stage 2: Servidor Web ultraleve com Nginx Alpine (~25MB)
# =========================================================================
FROM nginx:alpine

# Remove a configuração padrão do Nginx
RUN rm -rf /etc/nginx/conf.d/*

# Copia a configuração customizada do Nginx com suporte a SPA e Gzip
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia apenas os artefatos estáticos compilados na etapa anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Expõe a porta padrão HTTP
EXPOSE 80

# Health check para monitoramento do contêiner
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/healthz || exit 1

# Inicializa o Nginx em primeiro plano
CMD ["nginx", "-g", "daemon off;"]
