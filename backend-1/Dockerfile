# backend-1/Dockerfile
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# copy the jar built by ./gradlew bootJar
COPY build/libs/demo.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]