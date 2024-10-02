# Step 1: Run SonarQube scan (assuming SonarQube is required and running locally)
FROM sonarsource/sonar-scanner-cli:latest AS sonarqube-scan

WORKDIR /app
COPY . .

ENV SONAR_HOST_URL=http://localhost:9000
ENV SONAR_LOGIN=squ_ec5b9297072e2a6cc8e285c6dcd6f5e06b90ac39

RUN sonar-scanner -Dsonar.projectKey=my_project_key -Dsonar.sources=. -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=${SONAR_LOGIN} || echo "SonarQube analysis finished with issues"

# Step 2: Build the Maven project using Maven Wrapper (mvnw)
FROM openjdk:17-jdk-slim AS build

# Set the working directory for the application
WORKDIR /app

# Copy the application source code into the Docker image
COPY . .

# Ensure the Maven wrapper script has execute permissions
RUN chmod +x ./mvnw

# Install curl to check connectivity and perform health checks
RUN apt-get update && apt-get install -y curl && curl -I https://repo.maven.apache.org/maven2/

# Run Maven Wrapper to build the package
RUN ./mvnw -X clean package

# Step 3: Create the final image with Java 17 and use the JAR file
FROM openjdk:17-jdk-alpine
WORKDIR /code

# Copy the artifact from the Maven build (Step 2)
COPY --from=build /app/target/*.jar /code/

# Run the built JAR file
CMD ["java", "-jar", "/code/*.jar"]
