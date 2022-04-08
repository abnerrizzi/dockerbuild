FROM maven:3-jdk-8

ADD pom.xml /tmp/

RUN mvn dependency:go-offline -T 4C -f /tmp/pom.xml -B