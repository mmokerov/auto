FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5174 3000

CMD ["sh", "-c", "npm run server & npm run dev -- --host 0.0.0.0"]
