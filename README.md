# copystagram-manifest
copystagram-manifest

# Command
- ```
    # docker run
    docker run -it --rm --volume %cd%/kafka_2.13-3.7.0:/kafka --network copystagram-backend_copystagram-net copystagram:latest /bin/bash
    ```

# Kafka
- ```
    ./kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post --create

    ./kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-result --create

    ./kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-list --create

    ./kafka-topics.sh --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --topic meta-post-list-result --create


    ./kafka-streams-application-reset.sh --bootstrap-server broker:9092 \
                                    --application-id meta-post \
                                    --input-topics meta-post \
                                    --intermediate-topics meta-post-result

    ./kafka-streams-application-reset.sh  --bootstrap-server broker:9092 \
                                    --application-id meta-post-list \
                                    --input-topics meta-post-list \
                                    --intermediate-topics meta-post-list-result
    ```

# In container
- ```
    # build backend
    /copystagram/gradle/gradle-8.7/bin/gradle build -p /copystagram/copystagram-backend/copystagram

    # run backend
    nohup /copystagram/gradle/gradle-8.7/bin/gradle bootRun -p /copystagram/copystagram-backend/copystagram &> backend.log &
    ```

