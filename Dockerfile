FROM maven:latest as build
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src src
RUN mvn -Dmaven.test.skip=true package
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM openjdk:12
ARG DEPENDENCY=/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENV TZ=Europe/Ulyanovsk
ENTRYPOINT ["java","-cp","app:app/lib/*","com.nordclan.hello.HelloApplication"]

