FROM node:18-alpine AS development

# Çalışma dizinini ayarla
WORKDIR /usr/src/app

# Bağımlılıkları kopyala ve yükle
COPY package*.json ./
RUN npm install

# Kaynak dosyaları kopyala
COPY . .

# Build et
RUN npm run build

# Mediasoup için gerekli araçları yükle
RUN apk add --no-cache python3 make g++ linux-headers

# Üretim için daha küçük bir imaj oluştur
FROM node:18-alpine AS production

# Node_ENV'yi production olarak ayarla
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Çalışma dizinini ayarla
WORKDIR /usr/src/app

# Bağımlılıkları kopyala ve sadece production bağımlılıklarını yükle
COPY package*.json ./
RUN npm ci --only=production

# Mediasoup için gerekli araçları yükle
RUN apk add --no-cache python3 make g++ linux-headers

# Derlenen uygulamayı development aşamasından kopyala
COPY --from=development /usr/src/app/dist ./dist

# Gerekli port aralıklarını aç (HTTP ve MediaSoup RTC)
EXPOSE 3000
EXPOSE 10000-59999/udp
EXPOSE 10000-59999/tcp

# Uygulamayı çalıştır
CMD ["node", "dist/main"] 