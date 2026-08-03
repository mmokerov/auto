FROM node:18-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Собираем фронтенд
RUN npm run build

# Финальный образ с nginx и json-server
FROM nginx:alpine

# Копируем собранное приложение
COPY --from=build /app/dist /usr/share/nginx/html

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Копируем базу данных
COPY db.json /db.json

# Устанавливаем Node.js для json-server
RUN apk add --no-cache nodejs npm && \
    npm install -g json-server

EXPOSE 80

# Запускаем nginx и json-server
CMD sh -c "json-server --watch /db.json --host 0.0.0.0 --port 3000 & nginx -g 'daemon off;'"
