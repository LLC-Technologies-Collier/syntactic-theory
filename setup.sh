#!/bin/bash

# Copyright 2015, 2016 Collier Technologies LLC

BASEDIR=$CWD

cd sql
mysql -u root --password=password < create-database.sql
mysql -u root --password=password < create-user.sql > /dev/null 2>&1
mysql -u root --password=password grammar < grammar-create.sql
mysql -u grammaradm --password=password grammar < lexicon-create.sql

mysql -u root --password=password < grant-user.sql
mysql -u grammaradm --password=password grammar < grammar-insert.sql
mysql -u grammaradm --password=password grammar < lexicon-insert.sql
