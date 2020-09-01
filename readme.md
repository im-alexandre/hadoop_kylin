# Instalação do cluster Single Node

## 1) IMPORTANTE
---
:point_right: Foi testado apenas no CentOS 7 com ac configuração padrão (minimal)  
:point_right: Utilizar o usuário "hadoop" com permissão de sudo
---
Redirecionamento de portas (Máquinas virtuais)  
hadoop              -   9870  
kylin               -   7070  
pyspark(Notebook)   -   8899  
ssh                 -   2222  
yarn                -   8088  
---
---

### 2) Copiar a pasta com os scripts e arquivos de dependências para a máquina host
```sh
# Os arquivos devem ser copiados para a pasta "home" da máquina host
$ scp <pasta com os arquivos>/* <nome da maquina>/home/hadoop
```
### 3) Executar o script install_hadoop.sh
```sh
$ chmod +x install_hadoop
$ ./install_hadoop.sh
```

### 4) Ele irá montar e configurar os recursos necessários:
+ hadoop==2.10
+ hbase==1.6
+ kafka==1.1.1 (scala 2.11)
+ hive==1.2.2
+ kylin==2.6.6(hbase1.x hadoop 2)
+ spark==2.3.2

### 5) Antes de operar o cluster, modificar as configurações do postgresql:
***Editar o arquivo pg_hba.conf***
```sh
$ sudo vim /var/lib/pgsql/data/pg_hba.conf
```
***As configurações devem ficar assim :point_down:***
````
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
host        all         all        0.0.0.0/0             md5
host              hive  hiveuser   0.0.0.0/0             ident
# IPv4 local connections:
host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 md5
````

***Editar o arquivo postgresql.conf***
```sh
$ sudo vim /var/lib/pgsql/data/postgresql.conf
````
***incluir a linha:***
````
listen_addresses = '*'
````
***reiniciar o postgresql***
```sh
$ sudo systemctl restart postgresql

````
***Após a configuração do postgresql, realizar a migração do metastore:***
```sh
$ schematool -dbType postgres -initSchema
```

## Testando o hdfs:
***Comandos para incluir o dataset "pima-indians-diabetes" para utilizar no spark***
```sh
start-dfs.sh && start-yarn.sh 
hdfs dfs -mkdir -p /user/hadoop/datasets
hdfs dfs -put pima-indians-diabetes.data.csv "datasets/diabetes.csv"
```
### Testando o pyspark:
***No terminal, execute:***
```sh
$ pyspark
```
:point_right: Clique no link iniciado com 127.0.0.1  
:point_right: Execute o Notebook "hello-spark.ipynb"

### Para iniciar o cluster:
```sh
$ start-dfs.sh && start-yarn.sh
###### INICIAR O SERVIDOR DO MAP REDUCE!!!!!!
$ mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR
$ start-hbase.sh
$ nohup hive --service hiveserver2 &
$ kylin.sh start
```

### Para parar o cluster:
```sh
$ kylin.sh stop
$ stop-hbase 
$ stop-yarn.sh 
$ stop-dfs.sh
$ kill `jps | awk '{ print $1 }'`
```
