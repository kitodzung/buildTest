#tải jdk từ docker registry
FROM eclipse-temurin:17-jdk-alpine as builder
#khi docker chạy sẽ coppy toàn bộ thư mục vào app
WORKDIR /app
#coppy thư mục .mvn vào trong thư mục app
COPY .mvn/ .mvn
#coppy thư mục mvnw pom.xml vào trong thư mục app
COPY mvnw pom.xml ./
#cấp quyền thực thi cho file mvnw
RUN chmod 777 -R ./mvnw
#cài thư viện của dependency có trong maven
RUN ./mvnw dependency:go-offline
#coppy thư mục souce code src vào trong thư mục app
COPY ./src ./src
#build ra file jar
RUN ./mvnw clean install -DskipTests

# cả câu lệnh tên để để build file jar

#lệnh dưới là coppy file jar từ thư mục build ban đầu để chạy
#tên images eclipse-temurin:17-jre-alpine là khuôn mẫu
FROM eclipse-temurin:17-jre-alpine
#thư mục làm việc
WORKDIR /app
#expose cổng image ra bên ngoài theo port của project
EXPOSE 8080
#coppy file jar từ builder
COPY --from=builder /app/target/*.jar build_test.jar
#câu lệnh để chạy images,dùng để run server
ENTRYPOINT ["sh", "-c", "java -jar build_test.jar"]


#docker build -t build_test        . để build docker image