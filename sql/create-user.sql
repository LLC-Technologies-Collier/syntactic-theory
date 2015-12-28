/* Copyright 2015 Collier Technologies LLC */

CREATE USER 'grammaradm'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON grammar.* TO 'grammaradm'@'localhost';

CREATE USER 'grammaruser'@'localhost' IDENTIFIED BY 'nunya';
GRANT SELECT ON grammar.lexeme                TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.lexical_category      TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.phrasal_category      TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.phrase_structure_rule TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.rule_node             TO 'grammaruser'@'localhost';
