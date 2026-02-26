# ---- Build stage ----
FROM node:18-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
ARG REACT_APP_PUBLIC_URL
ENV REACT_APP_PUBLIC_URL=$REACT_APP_PUBLIC_URL

RUN npm run build

# ---- Run stage ----
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]