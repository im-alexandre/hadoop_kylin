
#JAVA
export JAVA_HOME=/opt/java
export JRE_HOME=/opt/java/jre 
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin

# HADOOP
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

#ZOOKEEPER
export ZOOKEEPER_HOME=/opt/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin

#HBASE
export HBASE_HOME=/opt/hbase
export PATH=$PATH:$HBASE_HOME/bin
export CLASSPATH=$HBASE_HOME/lib/*:.

#KAFKA_HOME
export KAFKA_HOME=/opt/kafka
export PATH=$PATH:$KAFKA_HOME/bin

#HIVE_HOME
export HIVE_HOME=/opt/hive
export PATH=$PATH:$HIVE_HOME/bin
export CLASSPATH=$CLASSPATH:$HADOOP_HOME/lib/*:.
export CLASSPATH=$HIVE_HOME/lib/*:.

# Spark
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_HOME=/opt/kylin/spark
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:\$LD_LIBRARY_PATH
export PATH=$PATH:$SPARK_HOME/bin

# Aqui é o pulo do gato! Configurar o pyspark com o python 3 e para abrir direto com o jupyter lab
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab --no-browser --port=8899'

# KYLIN
export KYLIN_HOME=/opt/kylin
export PATH=$PATH:$KYLIN_HOME/bin
