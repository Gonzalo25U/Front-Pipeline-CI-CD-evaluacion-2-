# ─── Stage 1: Build con Node ──────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copia package.json primero para aprovechar caché de dependencias de Docker.
# Si las dependencias no cambian, npm ci no vuelve a instalar en el siguiente build.
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ─── Stage 2: Servidor estático con Nginx ─────────────────────────────────────
# Nginx Alpine es mucho más liviano que correr Node en producción para un SPA.
FROM nginx:alpine AS runner

# Eliminar configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuración personalizada con soporte para react-router-dom
COPY nginx.conf /etc/nginx/conf.d/app.conf

# Copiar el build de Vite (output en /dist)
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]