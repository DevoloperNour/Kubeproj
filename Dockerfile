# Step 1: Run Sonarqube scan
FROM sonarsource/sonar-scanner-cli:latest AS sonarqube-scan

WORKDIR /app
COPY . .
#I have Sonarqube up and working
ENV SONAR_HOST_URL=http://localhost:9000
ENV SONAR_LOGIN=squ_ec5b9297072e2a6cc8e285c6dcd6f5e06b90ac39

RUN sonar-scanner -Dsonar.projectKey=my_project_key -Dsonar.sources=. -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_LOGIN} || echo "SonarQube analysis finished with issues"

# Step 2: Build the Maven (mvnw)
FROM openjdk:17-jdk-slim AS build


WORKDIR /app


COPY . .


RUN chmod +x ./mvnw


RUN apt-get update && apt-get install -y curl && curl -I https://repo.maven.apache.org/maven2/

# Run Maven Wrapper to build the package
RUN ./mvnw clean package -Dcheckstyle.skip=true

# Step 3: Create the final image with Java 17 and use the JAR file
FROM openjdk:17-jdk-alpine
WORKDIR /app

# Run the built JAR file
#CMD ["java", "-jar", "/code/*.jar"]

# Copy the artifact from the Maven (Step 2)
COPY --from=build /app/target/spring-petclinic*.jar /app/spring-petclinic.jar

# Set the entrypoint command to run the application
ENTRYPOINT ["java", "-jar", "/app/spring-petclinic.jar"]
