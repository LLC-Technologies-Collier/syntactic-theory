#!/bin/bash

# Copyright 2015, 2016 Collier Technologies LLC
# Copyright 2019, Google LLC

# sudo apt-get install mariadb-client mariadb-server

BASEDIR=$CWD

cd sql
sudo mysql -u root -f < create-database.sql
sudo mysql -u root -f < create-user.sql > /dev/null 2>&1
sudo mysql -u root -f < grant-user.sql > /dev/null 2>&1
sudo mysql -u root -f grammar < grammar-create.sql
mysql -u grammaradm --password=password grammar -f < lexicon-create.sql

mysql -u grammaradm --password=password -f grammar < grammar-insert.sql
mysql -u grammaradm --password=password -f grammar < lexicon-insert.sql
