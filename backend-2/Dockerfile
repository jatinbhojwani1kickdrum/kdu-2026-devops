FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY build/libs/demo.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java","-jar","/app/app.jar"]