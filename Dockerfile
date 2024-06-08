# Dockerfile

# Using teacher's image which has java and gradle installed, giving it the name builder
FROM henrikbaerbak/jdk17-gradle74 AS builder

# Author of this file
LABEL maintainer="Student:Christian;Group:Alpha"

# sets the work directory
WORKDIR /root/telemed

# copies all relevant folders and files
COPY /telemed/src ./telemed/src
COPY /telemed/build.gradle ./telemed/build.gradle
COPY /telemed/gradle.properties ./telemed/gradle.properties

COPY /broker/src ./broker/src
COPY /broker/build.gradle ./broker/build.gradle

COPY build.gradle .
COPY gradlew .
COPY gradlew.bat .
COPY settings.gradle .

# Running gradle in the image - DISABLE WHEN RUNNING BITBUCKET PIPELINES
RUN gradle :telemed:jar

RUN apt-get update
RUN apt-get install -y zip
RUN zip -d telemed/build/libs/telemed.jar 'META-INF/.SF' 'META-INF/.RSA' 'META-INF/*SF'

# Using teacher's image which has java and gradle installed
FROM henrikbaerbak/jdk17-gradle74

# Auhtor of this file
LABEL maintainer="Student:Christian;Group:Alpha"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# sets the work directory
WORKDIR /root/telemed

# copy jar file from builder
COPY --from=builder /root/telemed/telemed/build/libs/telemed.jar /root/telemed/telemed.jar

# Exposing the 4567 port, remember to hook it up when creating your container
EXPOSE 4567

# This uses the default http.cpf gradle configuration when the container is started
CMD java -jar /root/telemed/telemed.jar 172.17.0.2 false false

# Usage:
# step 1: Move this file in your code repository root folder
# step 2: Build the image using > docker build -t image-dockerfile .
# step 3: Create a container with > docker run -d -p 7777:7777 --name mydaemon image-dockerfile
# optionally you can assign another cpf file running > docker run -d -p 7777:7777 --name mydaemon image-dockerfile gradle daemon -Pcpf=[cpf file name(i.e. dummy.cpf)]