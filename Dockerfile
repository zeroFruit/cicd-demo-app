FROM adoptopenjdk/openjdk8-openj9:alpine-slim
ADD build/libs/demo-0.0.1-SNAPSHOT.jar demo-app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar","/demo-app.jar"]