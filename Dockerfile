# Estágio de Build
FROM maven:3.9-eclipse-temurin-17 AS build
COPY . /app
WORKDIR /app
RUN mvn clean package -DskipTests

# Estágio Final
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN mkdir certs

# Gerar certificados
RUN keytool -genkeypair -alias server-alias -keyalg RSA -keysize 2048 \
    -storetype PKCS12 -keystore certs/keystore.p12 -validity 365 \
    -dname "CN=localhost" -storepass password -keypass password

RUN keytool -genkeypair -alias client-alias -keyalg RSA -keysize 2048 \
    -storetype PKCS12 -keystore certs/client.p12 -validity 365 \
    -dname "CN=client" -storepass password -keypass password

RUN keytool -exportcert -alias client-alias -file certs/client.crt -keystore certs/client.p12 -storepass password
RUN keytool -importcert -alias client-alias -file certs/client.crt -keystore certs/truststore.p12 \
    -storepass password -noprompt

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8443
ENTRYPOINT ["java", "-jar", "app.jar"]