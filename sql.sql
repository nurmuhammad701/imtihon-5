-- Ma'lumotlar bazalarini yaratish
CREATE DATABASE server1_db;
CREATE DATABASE server2_db;
CREATE DATABASE server3_db;

-- Har bir ma'lumotlar bazasida postgres_fdw kengaytmasini o'rnatish
\c server1_db
CREATE EXTENSION postgres_fdw;

\c server2_db
CREATE EXTENSION postgres_fdw;

\c server3_db
CREATE EXTENSION postgres_fdw;

-- Har bir ma'lumotlar bazasida asosiy users jadvalini yaratish
\c server1_db
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

\c server2_db
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

\c server3_db
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- server1_db uchun Foreign Server'larni yaratish
\c server1_db
CREATE SERVER server2_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server2_db');
CREATE SERVER server3_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server3_db');

-- server2_db uchun Foreign Server'larni yaratish
\c server2_db
CREATE SERVER server1_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server1_db');
CREATE SERVER server3_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server3_db');

-- server3_db uchun Foreign Server'larni yaratish
\c server3_db
CREATE SERVER server1_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server1_db');
CREATE SERVER server2_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'server2_db');

-- Har bir ma'lumotlar bazasi uchun User Mapping'larni yaratish
\c server1_db
CREATE USER MAPPING FOR PUBLIC SERVER server2_fdw OPTIONS (user 'postgres', password 'your_password');
CREATE USER MAPPING FOR PUBLIC SERVER server3_fdw OPTIONS (user 'postgres', password 'your_password');

\c server2_db
CREATE USER MAPPING FOR PUBLIC SERVER server1_fdw OPTIONS (user 'postgres', password 'your_password');
CREATE USER MAPPING FOR PUBLIC SERVER server3_fdw OPTIONS (user 'postgres', password 'your_password');

\c server3_db
CREATE USER MAPPING FOR PUBLIC SERVER server1_fdw OPTIONS (user 'postgres', password 'your_password');
CREATE USER MAPPING FOR PUBLIC SERVER server2_fdw OPTIONS (user 'postgres', password 'your_password');

-- server1_db uchun Foreign Table'larni yaratish
\c server1_db
CREATE FOREIGN TABLE users_server2 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server2_fdw OPTIONS (schema_name 'public', table_name 'users');

CREATE FOREIGN TABLE users_server3 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server3_fdw OPTIONS (schema_name 'public', table_name 'users');

-- server2_db uchun Foreign Table'larni yaratish
\c server2_db
CREATE FOREIGN TABLE users_server1 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server1_fdw OPTIONS (schema_name 'public', table_name 'users');

CREATE FOREIGN TABLE users_server3 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server3_fdw OPTIONS (schema_name 'public', table_name 'users');

-- server3_db uchun Foreign Table'larni yaratish
\c server3_db
CREATE FOREIGN TABLE users_server1 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server1_fdw OPTIONS (schema_name 'public', table_name 'users');

CREATE FOREIGN TABLE users_server2 (
    id INTEGER,
    username VARCHAR(50),
    email VARCHAR(100)
) SERVER server2_fdw OPTIONS (schema_name 'public', table_name 'users');

-- Sozlamalarni tekshirish
\c server1_db
\dt
\det

\c server2_db
\dt
\det

\c server3_db
\dt
\det