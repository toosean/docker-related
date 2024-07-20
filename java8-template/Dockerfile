FROM swr.cn-south-1.myhuaweicloud.com/tsz/amazoncorretto:8 AS base
WORKDIR /app
EXPOSE 8080

#maven-base 这个镜像和官方的主要区别就是加了 maven 阿里的加速节点
FROM swr.cn-south-1.myhuaweicloud.com/tsz/maven-base:latest AS build
WORKDIR /src
COPY . .
RUN mvn clean package

FROM base AS final
WORKDIR /app
COPY --from=build /src/crmeb-admin/target/Crmeb-admin.jar /app/app.jar
RUN ["java", "-jar", "app.jar"]