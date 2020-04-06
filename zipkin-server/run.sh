#!/bin/sh
JAR_NAME=zipkin.jar
LOG_FILE=zipkin.log
start() {
    echo "start process...";
    rm -rf ./logs
    nohup java -Xmx128m -Xms128m \
    -jar ${JAR_NAME} \
    --server.port=9411 \
    --zipkin.collector.rabbitmq.enabled=true \
    --zipkin.collector.rabbitmq.addresses=192.168.223.136:5672 \
    --zipkin.collector.rabbitmq.username=admin \
    --zipkin.collector.rabbitmq.password=admin \
    --zipkin.storage.type=elasticsearch \
    --zipkin.storage.elasticsearch.hosts=http://192.168.223.136:9200 \
    --zipkin.storage.elasticsearch.index=zipkin \
    --zipkin.storage.elasticsearch.timeout=10000 \
    > ${LOG_FILE} 2>&1 &
}

# 启动后的访问地址是http://${服务器ip}:{server.port}

stop() {
    while true
    do
        process=`ps aux | grep ${JAR_NAME} | grep -v grep`;
        if [ "$process" = "" ]; then
            echo "no process";
            break;
        else
            echo "kill process...";
            ps -ef | grep ${JAR_NAME} | grep -v grep | awk '{print $2}' | xargs kill -15
            sleep 3
        fi
    done

}

restart() {
    stop;
    start;
}

status() {
    ps -ef | grep ${JAR_NAME}
}

case "$1" in
    'start')
        start
        ;;
    'stop')
        stop
        ;;
    'status')
        status
        ;;
    'restart')
        restart
        ;;
    *)
    echo "usage: $0 {start|stop|restart|status}"
    exit 1
        ;;
    esac
