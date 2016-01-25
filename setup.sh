#!/bin/bash

# Copyright 2015 Collier Technologies LLC

BASEDIR=$CWD

cd sql
mysql -u root --password=password < create-database.sql
mysql -u root --password=password < create-user.sql
mysql -u grammaradm --password=password grammar < grammar-create.sql
mysql -u grammaradm --password=password grammar < grammar-insert.sql
mysql -u grammaradm --password=password grammar < lexicon-insert.sql
