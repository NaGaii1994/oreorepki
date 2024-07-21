FROM nginx:1.27.0-alpine3.19

COPY compose/server/nginx.conf /etc/nginx
COPY .keys/server_chain.crt /etc/nginx/ssl/server_chain.crt
COPY .keys/server.key /etc/nginx/ssl/server.key