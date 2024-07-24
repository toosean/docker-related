FROM node:10-alpine as build
WORKDIR /src
COPY . .
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/ && npm install && npm run build:prod 

FROM nginx as final
COPY --from=build /src/dist /usr/share/nginx/html
RUN sed -i '9i\        try_files $uri $uri/ /index.html;' /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]