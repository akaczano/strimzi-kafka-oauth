#!/bin/bash

declare -A props

to_property_name() {
  key=$1
  echo ${key:6} | tr _ . | tr [:upper:] [:lower:]
}

pop_value() {
  key=$1
  fallback=$2

  if [ -z ${props[$key]+x} ] ; then
    echo $fallback
  else
    echo ${props[$key]}
  fi
  unset props[$key]
}

unset IFS
for var in $(compgen -e); do
  if [[ $var == KAFKA_* ]]; then

    case $var in
      KAFKA_DEBUG|KAFKA_OPTS|KAFKA_VERSION|KAFKA_HOME|KAFKA_CHECKSUM|KAFKA_LOG4J_OPTS|KAFKA_HEAP_OPTS|KAFKA_JVM_PERFORMANCE_OPTS|KAFKA_GC_LOG_OPTS|KAFKA_JMX_OPTS) ;;
      *)
        props[`to_property_name $var`]=${!var}
      ;;
    esac
  fi
done

#
# Generate output
#
echo "#"
echo "# strimzi.properties"
echo "#"

echo broker.id=`pop_value broker.id 0`
echo num.network.threads=`pop_value num.network.threads 3`
echo num.io.threads=`pop_value num.io.threads 8`
echo socket.send.buffer.bytes=`pop_value socket.send.buffer.bytes 102400`
echo socket.receive.buffer.bytes=`pop_value socket.receive.buffer.bytes 102400`
echo socket.request.max.bytes=`pop_value socket.request.max.bytes 104857600`
echo log.dirs=`pop_value log.dirs /tmp/kafka-logs`
echo num.partitions=`pop_value num.partitions 1`
echo num.recovery.threads.per.data.dir=`pop_value num.recovery.threads.per.data.dir 1`
echo offsets.topic.replication.factor=`pop_value offsets.topic.replication.factor 1`
echo transaction.state.log.replication.factor=`pop_value transaction.state.log.replication.factor 1`
echo transaction.state.log.min.isr=`pop_value transaction.state.log.min.isr 1`
echo log.retention.hours=`pop_value log.retention.hours 168`
echo log.segment.bytes=`pop_value log.segment.bytes 1073741824`
echo log.retention.check.interval.ms=`pop_value log.retention.check.interval.ms 300000`
echo zookeeper.connect=`pop_value zookeeper.connect localhost:2181`
echo zookeeper.connection.timeout.ms=`pop_value zookeeper.connection.timeout.ms 6000`
echo group.initial.rebalance.delay.ms=`pop_value group.initial.rebalance.delay.ms 0`

#
# Add what remains of KAFKA_* env vars
#
for K in "${!props[@]}"
do
  echo $K=`pop_value $K`
done

echo