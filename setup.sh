#!/bin/bash

# Copyright 2015, 2016 Collier Technologies LLC

BASEDIR=$CWD

cd sql
mysql -u root --password=password -f < create-database.sql
mysql -u root --password=password -f < create-user.sql > /dev/null 2>&1
mysql -u root --password=password -f grammar < grammar-create.sql
mysql -u grammaradm --password=password grammar -f < lexicon-create.sql

mysql -u root --password=password -f  < grant-user.sql
mysql -u grammaradm --password=password -f grammar < grammar-insert.sql
mysql -u grammaradm --password=password -f grammar < lexicon-insert.sql
