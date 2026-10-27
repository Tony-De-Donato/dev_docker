FROM node:22.11-alpine

WORKDIR /app

ENV NODE_ENV=production

EXPOSE 3000

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force

COPY --chown=node:node . .

USER node

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["node", "-e", "fetch('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health').then((r) => process.exit(r.ok ? 0 : 1), () => process.exit(1))"]

CMD ["node", "server.js"]