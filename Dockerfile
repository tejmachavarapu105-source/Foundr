# ---------- Build Stage ----------
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./

# Prisma schema must exist before npm ci
COPY prisma ./prisma

RUN npm install

COPY . .

RUN npm run build


# ---------- Production Stage ----------
FROM node:22-alpine

RUN apk add --no-cache openssl1.1

WORKDIR /app

ENV NODE_ENV=production

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY package*.json ./

EXPOSE 3000

CMD ["node", "dist/main.js"]