FROM ubuntu:24.04

SHELL ["/bin/bash", "--login", "-i", "-c"]

# dependencies
RUN apt-get update && apt-get install
RUN apt-get install curl -y
RUN apt-get install unzip -y
RUN apt-get install nginx -y

# init
WORKDIR /copystagram
COPY . .
ENV NODE_VERSION=20
ENV BASHRC=/root/.bashrc

RUN chmod 754 /copystagram/kafka_2.13-3.7.0/bin/*.sh


# node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN source $BASHRC
RUN nvm install $NODE_VERSION

RUN mv /copystagram/.env.production /copystagram/copystagram-frontend/.env.production

WORKDIR /copystagram/copystagram-frontend
RUN npm install
RUN npm run build

# java
WORKDIR /copystagram
# RUN curl -O https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
RUN tar xvf openjdk-*_bin.tar.gz
RUN rm openjdk-*_bin.tar.gz
RUN echo "JAVA_HOME=/copystagram/jdk-21.0.2" >> $BASHRC
RUN echo "PATH=$PATH:$HOME/bin:$JAVA_HOME/bin" >> $BASHRC
RUN source $BASHRC
RUN javac --version
RUN java --version

# RUN curl --location --show-error -O --url "https://services.gradle.org/distributions/gradle-8.7-bin.zip"
RUN unzip ./gradle-8.7-bin.zip -d gradle
RUN rm ./gradle-8.7-bin.zip

RUN mv /copystagram/application.properties /copystagram/copystagram-backend/copystagram/src/main/resources/application.properties
RUN mv /copystagram/copystagram.properties /copystagram/copystagram-backend/copystagram/src/main/resources/copystagram.properties

WORKDIR /copystagram/copystagram-backend/copystagram
RUN /copystagram/gradle/gradle-8.7/bin/gradle build -x test -p /copystagram/copystagram-backend/copystagram
# /copystagram/gradle/gradle-8.7/bin/gradle bootRun -p /copystagram/copystagram-backend/copystagram

CMD ["tail", "-f", "/dev/null"]
