FROM maven:3-jdk-8

ADD src/ /app
COPY pom.xml /app

RUN mvn dependency:go-offline -T 4C -f /app/pom.xml -B
