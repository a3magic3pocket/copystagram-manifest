curl --location 'http://your-server-ip:8083/connectors' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "mongo-sink-meta-post",
    "config": {
        "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
        "connection.uri": "mongodb+srv://your-mongodb-id:your-mongodb-pw@your-mongodb-atlas-domain/",
        "tasks.max": "1",
        "topics": "meta-post-result",
        "database": "copystagram",
        "collection": "metaPost",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": false,
        "value.converter.schemas.enable": false,
        "document.id.strategy.overwrite.existing": true,
        "document.id.strategy": "com.mongodb.kafka.connect.sink.processor.id.strategy.FullKeyStrategy",
        "writemodel.strategy": "com.mongodb.kafka.connect.sink.writemodel.strategy.ReplaceOneBusinessKeyStrategy",
        "post.processor.chain": "sinkPostProcessor.ObjectIdPostProcessor",
        "value.projection.list": "postId,hookPostId"
    }
}
'