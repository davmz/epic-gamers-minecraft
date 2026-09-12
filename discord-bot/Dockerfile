FROM node:20.19.0-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY src ./src

CMD ["npm", "start"]