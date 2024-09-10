CREATE DATABASE server1_db;
CREATE DATABASE server2_db;
CREATE DATABASE server3_db;


\c server1_db
CREATE EXTENSION postgres_fdw;

\c server2_db
CREATE EXTENSION postgres_fdw;

\c server3_db
CREATE EXTENSION postgres_fdw;

