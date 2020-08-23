#!/usr/bin/env bash

echo """
*** Instalando dedpendências ***

"""
sleep 2

sudo yum install -y \
    python3 python3-pip \
    python3-devel \
    gcc gcc-c++ \
    postgresql postgresql-server \
    wget \
    vim

echo """
    *** Iniciando Postgres e criando o metastore do HIVE ***
"""
sudo systemctl enable postgresql
sudo chown -R hadoop:hadoop /var/lib/pgsql/data
sudo cp /home/hadoop/cria_metastore.sql /var/lib/pgsql/
sudo chown -R postgres:postgres /var/lib/pgsql/data
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo -u postgres psql -f /var/lib/pgsql/cria_metastore.sql

cd /opt
echo """
*** Copiando o jdk para a pasta opt ***

"""
sudo mv /home/hadoop/jdk-8u261-linux-x64.tar.gz .
echo """
*** Baixando o hadoop para a pasta opt ***

"""
sudo wget https://downloads.apache.org/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz
echo """
*** Baixando o HBase para a pasta opt ***

"""
sudo wget https://downloads.apache.org/hbase/1.6.0/hbase-1.6.0-bin.tar.gz
echo """
*** Baixando o Kafka para a pasta opt ***

"""
sudo wget https://archive.apache.org/dist/kafka/1.1.1/kafka_2.11-1.1.1.tgz
echo """
*** Baixando o Hive para a pasta opt ***

"""
sudo wget https://downloads.apache.org/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
echo """
*** Baixando o Kylin para a pasta opt ***

"""
sudo wget https://downloads.apache.org/kylin/apache-kylin-2.6.6/apache-kylin-2.6.6-bin-hbase1x.tar.gz

for arquivo in $(ls *gz) ; do
    echo """
    *** Extraindo $arquivo ***
    """
    sudo tar -xf $arquivo
done

echo """
*** Renomeando pastas ***
"
sudo mv apache-hive-1.2.2-bin hive
sudo mv apache-kylin-2.6.6-bin-hbase1x kylin
sudo mv hadoop-2.10.0 hadoop
sudo mv hbase-1.6.0  hbase
sudo mv jdk1.8.0_261 java
sudo mv kafka_2.11-1.1.1 kafka

echo """
    *** removendo os binários ***
"""
sudo rm *gz

echo """
    *** modificando permissões de pasta ***
"""
sudo chown -R hadoop:hadoop /opt/*

echo """
    *** Instalando dependências do python e configurando o jupyter lab ***
"""
pip3 install --user -r /home/hadoop/requirements.txt
jupyter notebook --generate-config 
echo """
c.NotebookApp.allow_origin = '*'
c.NotebookApp.ip = '0.0.0.0'
""" >> /home/hadoop/.jupyter/jupyter_notebook_config.py

echo """
    *** Configurando variáveis de ambiente ***
"""
cat /home/hadoop/profile >> /home/hadoop/.bash_profile
cp hadoop-env.sh >> /opt/hadoop/etc/hadoop/hadoop-env.sh
source /home/hadoop/.bash_profile

echo """
*** Configurando o ssh ***
"""
echo """
# Descomentar as seguintes linhas
Port 22  ###
ListenAddress 0.0.0.0  ###
ListenAddress ::  ###
PubkeyAuthentication yes  ###
""" | sudo tee -a /etc/ssh/sshd_config

ssh-keygen  -P '' -f /home/hadoop/.ssh/id_rsa
cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
chmod 600 /home/hadoop/.ssh/authorized_keys

cd $HOME

echo """
    *** Copiando os arquivos de configuração ***
"""
cp /home/hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
cp /home/hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml
cp /home/hadoop/mapred-site.xml /opt/hadoop/etc/hadoop/mapred-site.xml
cp /home/hadoop/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml
cp /home/hadoop/hbase-site.xml /opt/hbase/conf/hbase-site.xml
cp /home/hadoop/hive-site.xml /opt/hive/conf/hive-site.xml
cp /home/hadoop/hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh
cp /home/hadoop/hbase-env.sh /opt/hbase/conf/hbase-env.sh

echo """
    *** Consertando o conflito da lib guava (HIVE x HADOOP) ***
"""
cp /opt/hive/lib/guava-14.0.1.jar /opt/hadoop/share/hadoop/common/lib/
cp /opt/hive/lib/guava-14.0.1.jar /opt/hbase/lib/
rm /opt/hadoop/share/hadoop/common/lib/guava-11.0.2.jar

echo """
    *** Baixando JDBC Driver e criando a metastore do hive ***
"""
cd /opt/hive/lib
wget https://jdbc.postgresql.org/download/postgresql-42.2.4.jre6.jar
cd

echo """
    *** Formatando o HDFS ***
"""
hdfs namenode -format

echo """
    *** Desabilitando o firewall ***
    *** ESTE É UM AMBIENTE DE TESTES, EM PRODUÇÃO, SEGURANÇA IMPORTA ***
"""
sudo systemctl stop firewalld
sudo systemctl disable firewalld


echo """
    *** Copiando as dependências do hbase e hive ***
"""
sudo mkdir /var/lib/zookeeper
sudo chown -R hadoop:hadoop /var/lib/zookeeper

echo """
    *** Configurando o Kafka ***
"""
echo """
advertised.listeners=PLAINTEXT://localhost:9092
listeners=PLAINTEXT://0.0.0.0:9092
""" >> $KAFKA_HOME/config/server.properties

echo """
    *** Baixando as dependências do Apache Kylin ***
"""
download-spark.sh

echo """
    *** Baixando dados de exemplo e incluindo no HDFS ***
"""

