#!/bin/bash

dbicdump -ISyntactic-Practice/lib \
         -o dump_directory=./Syntactic-Practice/lib \
         -o preserve_case=1 \
         Syntactic::Practice::Schema \
         dbi:mysql:database=grammar grammaruser nunya '{ quote_char => "`" }'
