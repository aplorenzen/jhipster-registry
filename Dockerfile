FROM openjdk:8 as builder
ADD . /code/
WORKDIR /code
RUN apt-get update
RUN apt-get install build-essential -y
RUN rm -Rf target node node_modules
RUN chmod +x /code/mvnw
RUN JHI_DISABLE_WEBPACK_LOGS=true ./mvnw package -ntp -Pprod -DskipTests
RUN mv /code/target/*.jar /jhipster-registry.jar
RUN apt-get clean
RUN rm -Rf /code/ /root/.m2 /root/.cache /tmp/* /var/lib/apt/lists/* /var/tmp/*

FROM openjdk:8-jre-alpine
ENV SPRING_OUTPUT_ANSI_ENABLED=ALWAYS \
    JAVA_OPTS="" \
    SPRING_PROFILES_ACTIVE=prod
EXPOSE 8761
RUN apk add --no-cache curl && \
    mkdir /target && \
    chmod g+rwx /target
CMD java \
        ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom \
        -jar /jhipster-registry.jar

COPY --from=builder /jhipster-registry.jar .
