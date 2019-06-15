---
title: "Debezium Kafka Connect on Kubernetes"
date: 2019-06-15T18:53:01+07:00
tags: ['kafka-connect', 'debezium', 'kubernetes', 'mysql-cdc']
commentid: 3
draft: false
---

In recent projects we had an usecase about streaming data from MySQL to
Kafka, and from that it can go wherever we want. We choose [Debezium][1]
as a MySQL source connector for [Kafka Connect][2].

From Debezium website, we could easily find out what it does:

> Debezium's MySQL Connector can monitor and record all of the row-level
> changes in the databases on a MySQL server or HA MySQL cluster. The
> first time it connects to a MySQL server/cluster, it reads a consistent
> snapshot of all of the databases. When that snapshot is complete, the
> connector continuously reads the changes that were committed to MySQL
> and generates corresponding insert, update and delete events. All of
> the events for each table are recorded in a separate Kafka topic, where
> they can be easily consumed by applications and services.

Now to deploy Debezium connector to Kubernetes, there are 3 things we need to
keep in mind:

- 1) Kafka Connect container must join your Kafka cluster to do the work.

- 2) We can pre-build Debezium connector in Kafka Connect image (or vice
versa), but we have to manually create new Kafka Connect source using REST
API.

- 3) We can do the 2nd thing automatically when deploying to K8s.

Let't get started!

This is the Dockerfile for Kafka Connect with Debezium MySQL connector:


```
FROM debezium/connect-base:0.9

ENV DEBEZIUM_VERSION="0.9.5.Final" \
    MAVEN_REPO_CORE="https://repo1.maven.org/maven2" \
    MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    MYSQL_MD5=720b1396358fbdc59bce953f47d3c53f

RUN docker-maven-download debezium mysql "$DEBEZIUM_VERSION" "$MYSQL_MD5"
```

If you want to use connector with other databases such as MongoDB, Postgresql,
Sqlserver, Oracle,... find the Dockerfile in [Debezium docker images repo][3].

Now a sample MySQL source configuration file:

```
# File: mysql-source.json
{
  "name": "inventory-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "192.168.99.100",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "dbz",
    "database.server.id": "184054",
    "database.server.name": "fullfillment",
    "database.whitelist": "inventory",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "dbhistory.fullfillment",
    "include.schema.changes": "true"
  }
}
```

To automatically create a new source after starting new K8s pod, we must add
a new init script to our docker image which will wait for our Kafka Connect
service go online before excecuting a `curl` request to create a new source:

```
# File: init.sh
echo "Wait for kafka connect..."
until $(curl --output /dev/null --silent --head --fail http://172.17.0.1:8083); do
    printf '.'
    sleep 5
done

echo "Install connector..."
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://172.17.0.1:8083/connectors/ -d @/kafka/init/mysql-source.json
```

Here, `172.17.0.1` is default localhost IP address for Docker guest container,
`8083` is the listening port of Kafka Connect.

We create a new entry point file for our image to run the `init.sh` script in
the background and waiting for Kafka Connect to go online.

```
# File: entrypoint.sh
/kafka/init/init.sh &
exec /docker-entrypoint.sh start
```

`/docker-entrypoint.sh` is the default entrypoint of Debezium connect image.

Now all are good, we have the final Dockerfile

```
FROM debezium/connect-base:0.9

ENV DEBEZIUM_VERSION="0.9.5.Final" \
    MAVEN_REPO_CORE="https://repo1.maven.org/maven2" \
    MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    MYSQL_MD5=720b1396358fbdc59bce953f47d3c53f

RUN docker-maven-download debezium mysql "$DEBEZIUM_VERSION" "$MYSQL_MD5"

# Init script to create mysql source after starting container
RUN mkdir -p /kafka/init
COPY init.sh /kafka/init/
COPY mysql-source.json /kafka/init/

ENTRYPOINT ["/kafka/init/entrypoint.sh"]
```

That's it. Write up your k8s config and deploy the Kafka Connect pod to your
cluster!


[1]: https://debezium.io/docs/connectors/mysql/
[2]: https://docs.confluent.io/current/connect/index.html
[3]: https://github.com/debezium/docker-images/blob/master/connect/0.9/Dockerfile
