# copystagram-manifest
copystagram 배포에 필요한 명세들

## 필요 서버 사양
- 메모리 4G 이상
    - 카프카 1G
    - 카프카 커넥트 1.5G
    - copystagram 프론트엔드 및 백엔드, 운영체제 1.5G

## 전반적인 작업 설명
- copystagram 이미지 빌드
    - 설명
        - copystagram 프론트엔드 및 백엔드 소스코드와   
          리버스 프록시 용 nginx를 담은 리눅스 이미지를 생성한다.
        - 메모리가 부족하므로 한 이미지에 묶어 메모리 사용을 최소화한다.
        - 이미지를 생성할 때 next.js(프론트엔드)와 gradle(백엔드) 빌드를 진행한다.
        - mongoDB는 atlas 클라우드를 사용한다고 가정한다.
    - 빌드 시 사용할 설정 파일
        - ```bash
            # frontend
            /copystagram-manifest/.env.production

            # backend
            /copystagram-manifest/application.properties
            /copystagram-manifest/copystagram.properties
            ```
    - 빌드 시 사용할 java 관련 파일
        - 설명
            - 빌드 시 다운로드하면 시간이 오래 걸리므로  
              미리 받아둔다.
        - ```bash
            # jdk21 다운로드
            # jdk21 압축 파일 경로: /copystagram-manifest/openjdk-21.0.2_linux-x64_bin.tar.gz
            curl -O https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
            
            # gradle 8.7 다운로드
            # jdk21 압축 파일 경로: /copystagram-manifest/gradle-8.7-bin.zip
            curl --location --show-error -O --url "https://services.gradle.org/distributions/gradle-8.7-bin.zip"
            ```
- docker 컨테이너 실행
    - 설명
        - 카프카, 카프카 커넥트, copystagram의 컨테이너를 생성한다.
        - /copystagram-manifest/docker-compose.yml를 기반으로 생성한다.
    - 명령
        - ```bash
            # 컨테이너 생성
            sudo docker compose -f /copystagram-manifest/docker-compose.yml up

            # 컨테이너 중지 및 삭제
            sudo docker compose -f /copystagram-manifest/docker-compose.yml down
            ```
    - 카프카 공유 볼륨
        - 구조
            - ```bash
                ㄴkafka
                    ㄴconfig
                        ㄴfile-input
                            ㄴserver.properties
                        ㄴsecrets
                            ㄴkafka_keystore_creds
                            ㄴkafka_ssl_key_creds
                            ㄴkafka_truststore_creds
                            ㄴkafka.truststore.jks
                            ㄴkafka01.keystore.jks
                    ㄴdata
                ```
        - 설명
            - server.properties
                - 카프카 설정이 담긴 파일이다.
                - advertised.listeners은 브로커 서버 ip를 명시하는 부분인데  
                  현재는 싱글 노드이므로 브로커 컨테이너 명을 적어주었다.
                - log.dirs는 카프카 토픽 데이터가 저장되는 곳이다.
            - data
                - log.dirs에 해당하는 경로와 연결되는 디렉토리이다.
                - 컨테이너를 재실행해도 카프카 데이터가 보존된다.
    - 카프카 커넥트 공유 볼륨
        - 구조
            - ```bash
                ㄴkafka-connect
                    ㄴjars
                        ㄴmongo-kafka-connect-1.11.2-all.jar
                        ㄴObjectIdPostProcessor.jar
                ```
        - 설명
            - mongo-kafka-connect-1.11.2-all.jar
                - confluent에서 제공하는 카프카 커넥터 파일이다.
                - [다운로드 링크](https://central.sonatype.com/artifact/org.mongodb.kafka/mongo-kafka-connect)
            - ObjectIdPostProcessor.jar
                - string을 objectId로 바꿔주는 후처리 파일이다.
                - [다운로드 링크](https://github.com/a3magic3pocket/copystagram-backend-post-processor/blob/main/ObjectIdPostProcessor-0.0.1.jar)
            - 카프카 커넥트는 http 명령으로 설정해야 하기 때문에  
              작업 편의성을 위하여 8083 포트를 열어두었다.  
              보안을 위하여 클라우드 보안 그룹에서 8083 아이피를   
              작업자 PC IP만 접근 할 수 있도록 설정한다.
            - 메모리 1.5G 기준으로 완전히 로드될때까지 3분 정도 소요된다.  
              curl http://localhost:8083/connectors 요청 시  
              []가 리턴될 때까지 대기한다.  
    - copystagram 공유 볼륨
        - 구조
            - ```bash
                # nginx 설정파일
                nginx.conf

                # 카프카 콘솔 파일
                kafka_2.13-3.7.0

                # 이미지 디렉토리
                static
                ```
        - 설명
            - nginx.conf
                - nginx 설정 파일이다.
                - nginx.conf를 수정한 경우 copystagram 컨테이너를 재실행해야 적용된다.
            - kafka_2.13-3.7.0
                - 카프카 콘솔 파일이다.
                - 카프카 토픽을 생성할때 사용한다.
            - static
                - spring에서 이미지를 저장하는 디렉토리와 연결된 디렉토리이다.
                - 웹에서 이미지를 호출하면 nginx에서 이 디렉토리에서 파일 읽는다.
                - copystagram을 재실행해도 이미지 파일은 보존된다.

# 작업
- ```bash
    ## clone submodules
    git submodule init
    git submodule --recursive init


    ## 설정파일을 본인 환경에 맞게 수정한다.
    # frontend
    vim /copystagram-manifest/.env.production

    # backend
    vim /copystagram-manifest/application.properties
    vim /copystagram-manifest/copystagram.properties

    # kafka
    vim /copystagram-manifest/kafka/config/file-input/server.properties


    ## copystagram 빌드
    sudo docker build --progress=plain -t copystagram .


    ## 컨테이너 생성
    # - kafka-connect까지 완전히 로드될때까지 대기한다.
    sudo docker compose -f ./docker-compose.yml up


    ## copystagrma 쉘 접속
    # - copystagram 이미지 빌드 시 shell script로 아래 명령을 묶은 뒤 
    # CMD나 ENTRYPOINT로 shell script를 실행하면 아래 작업을 자동화할 수 있다.
    sudo docker exec -it copystagram bash


    ## 카프카 토픽 생성
    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic post-creation --create

    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic noti-creation --create

    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post --create

    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-result --create

    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-list --create

    /copystagram/kafka_2.13-3.7.0/bin/kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-list-result --create


    ## backend 및 frontend 소스코드 실행
    #backend
    nohup /copystagram/gradle/gradle-8.7/bin/gradle bootRun -p /copystagram/copystagram-backend/copystagram &> /copystagram/logs/backend.log &

    # frontend
    cd /copystagram/copystagram-frontend/ && nohup npm run start &> /copystagram/logs/frontend.log &


    ## nginx 실행
    rm /etc/nginx/sites-available/*
    rm /etc/nginx/sites-enabled/*

    # nginx 설정 확인, ok가 떠야함
    nginx -t

    # nginx 시작
    service nginx start
    ```

## 카프카 커넥트 생성
- 설명
    - kafka-connect 컨테이너가 성공적으로 로드되었다면  
      작업자 pc에서 http 명령을 요청하여 sink connector를 생성한다.
    - kafka-connect-config 하위의 shell script를 실행하면 된다.
    - mongoDB 계정정보와 같은 민감정보는 본인 환경에 맞게 수정해야 한다.

