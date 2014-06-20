#!/bin/sh

JVMFLAGS="-server -showversion -javaagent:lib/jmxagent.jar -Dsf.jmxagent.port=4888"

if [ -n "$JAVA_RMI_SERVER_HOSTNAME" ]; then
    JVMFLAGS="$JVMFLAGS -Djava.rmi.server.hostname=$JAVA_RMI_SERVER_HOSTNAME"
fi

if [ -n "$VISUALVM_DISPLAY_NAME" ]; then
    JVMFLAGS="$JVMFLAGS -Dvisualvm.display.name=$VISUALVM_DISPLAY_NAME"
fi

export JVMFLAGS="$JVMFLAGS $JAVA_OPTS"

echo $ZOOKEEPER_MYID > /var/lib/zookeeper/myid

bin/zkServer.sh start-foreground
