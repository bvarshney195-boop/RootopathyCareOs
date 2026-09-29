FROM node:24.15.0-alpine@sha256:d1b3b4da11eefd5941e7f0b9cf17783fc99d9c6fc34884a665f40a06dbdfc94f AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG VITE_API_BASE_URL=/api
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN npm run build

FROM nginx:1.30.4-alpine3.24-slim@sha256:77da26c31397bf6694b4bf93275f5b40b0b120ba1b8f114264b603e592c561d6
RUN mkdir -p /etc/careos /tmp/nginx-conf \
    && chown nginx:nginx /tmp/nginx-conf
COPY nginx-main.conf /etc/nginx/nginx.conf
COPY nginx.conf /etc/careos/default.conf.template
COPY start-nginx.sh /usr/local/bin/start-careos-nginx
COPY --from=build --chown=nginx:nginx /app/dist /usr/share/nginx/html
RUN chmod 0555 /usr/local/bin/start-careos-nginx
USER nginx
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1
CMD ["/usr/local/bin/start-careos-nginx"]
