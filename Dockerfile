# ---- Build stage: compile the WAR ----
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q clean package -DskipTests

# ---- Run stage: Tomcat 11 (Java 17) serving the WAR ----
FROM tomcat:11.0-jdk17-temurin
# Replace the default apps; deploy MediQueue at /mediqueue
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/mediqueue.war /usr/local/tomcat/webapps/mediqueue.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
