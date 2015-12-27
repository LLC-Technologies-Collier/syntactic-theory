/* Copyright 2015 Collier Technologies LLC */

CREATE DATABASE IF NOT EXISTS grammar;

CREATE USER 'grammaradm'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON grammar.* TO 'grammaradm'@'localhost';
