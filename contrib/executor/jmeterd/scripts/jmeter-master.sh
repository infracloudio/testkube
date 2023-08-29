#!/bin/bash

echo "********************************************************"
echo "*              Installing JMeter Plugins               *"
echo "********************************************************"
echo



if [ -d $JMETER_CUSTOM_PLUGINS_FOLDER ]
then
  echo "Installing custom plugins from ${JMETER_CUSTOM_PLUGINS_FOLDER}"
  for plugin in ${JMETER_CUSTOM_PLUGINS_FOLDER}/*.jar; do
      echo "Copying plugin $plugin to ${JMETER_HOME}/lib/ext/${plugin}"
      cp $plugin ${JMETER_HOME}/lib/ext
  done;
else
  echo "No custom plugins found in ${JMETER_CUSTOM_PLUGINS_FOLDER}"
fi
echo

if [ -d $JMETER_USER_PLUGINS_FOLDER ]
then
  echo "Installing custom plugins from ${JMETER_USER_PLUGINS_FOLDER}"
  for plugin in ${JMETER_USER_PLUGINS_FOLDER}/*.jar; do
      echo "Copying plugin $plugin to ${JMETER_HOME}/lib/ext/${plugin}"
      cp $plugin ${JMETER_HOME}/lib/ext
  done;
else
  echo "No custom plugins found in ${JMETER_USER_PLUGINS_FOLDER}"
fi
echo


echo "********************************************************"
echo "*            Initializing JMeter Master                *"
echo "********************************************************"
echo

freeMem=$(awk '/MemAvailable/ { print int($2/1024) }' /proc/meminfo)

[[ -z ${JVM_XMN} ]] && JVM_XMN=$(($freeMem*2/10))
[[ -z ${JVM_XMS} ]] && JVM_XMS=$(($freeMem*8/10))
[[ -z ${JVM_XMX} ]] && JVM_XMX=$(($freeMem*8/10))

echo "Setting default JVM_ARGS=-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m"
export JVM_ARGS="-Xmn${JVM_XMN}m -Xms${JVM_XMS}m -Xmx${JVM_XMX}m"

if [ -n "$MASTER_OVERRIDE_JVM_ARGS" ]; then
  echo "Overriding JVM_ARGS=${MASTER_OVERRIDE_JVM_ARGS}"
  export JVM_ARGS="${MASTER_OVERRIDE_JVM_ARGS}"
fi

if [ -n "$MASTER_ADDITIONAL_JVM_ARGS" ]; then
  echo "Appending additional JVM args: ${MASTER_ADDITIONAL_JVM_ARGS}"
  export JVM_ARGS="${JVM_ARGS} ${MASTER_ADDITIONAL_JVM_ARGS}"
fi

echo "Available memory: ${freeMem} MB"
echo "Configured JVM_ARGS=${JVM_ARGS}"
echo

echo "********************************************************"
echo "*           Preparing JMeter Test Execution            *"
echo "********************************************************"
echo

# Keep entrypoint simple: we must pass the standard JMeter arguments
EXTRA_ARGS=-Dlog4j2.formatMsgNoLookups=true


echo "********************************************************"
echo "*                Executing JMeter tests                *"
echo "********************************************************"
echo

if [ -z "$SSL_DISABLED" ]; then
    SSL_DISABLED=true
fi

CONN_ARGS="-Jserver.rmi.ssl.disable=${SSL_DISABLED}"
echo "Executing command: jmeter $@ ${CONN_ARGS} "
echo
echo "Started CMD"
jmeter $@ ${CONN_ARGS}

echo "END Finished JMeter test on $(date) for test ${file}"
echo

echo "********************************************************"
echo "*           JMeter test executions finished            *"
echo "********************************************************"
echo
