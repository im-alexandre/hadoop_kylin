CREATE DATABASE metastore;
CREATE USER hiveuser WITH PASSWORD 'hivepass';
GRANT ALL PRIVILEGES ON DATABASE metastore to hiveuser;
