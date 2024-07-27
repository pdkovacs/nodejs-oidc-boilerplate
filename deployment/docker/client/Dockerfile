FROM nginx:1.23.3

LABEL Name="node-boilerplate-client"
LABEL Version="1.0.0"

RUN mkdir -p /opt/node-boilerplate
COPY ./assets /opt/node-boilerplate/assets/
COPY ./index.html /opt/node-boilerplate/
COPY ./nginx.conf /etc/nginx/

EXPOSE 8080
