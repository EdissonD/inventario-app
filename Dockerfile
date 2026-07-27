# Etapa 1: dependencias y pruebas

FROM node:24-alpine AS test

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY server.js ./
COPY db.js ./
COPY server.test.js ./
COPY public ./public
COPY data ./data

RUN npm test


# Etapa 2: imagen final mínima

FROM node:24-alpine AS production

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV APP_VERSION=v1
ENV APP_COLOR=blue

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

COPY --from=test /app/server.js ./server.js
COPY --from=test /app/db.js ./db.js
COPY --from=test /app/public ./public
COPY --from=test /app/data ./data

EXPOSE 3000

CMD ["node", "server.js"]
