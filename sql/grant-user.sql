/* Copyright 2015,2016 Collier Technologies LLC */

GRANT ALL ON grammar.* TO 'grammaradm'@'localhost';

/*GRANT SELECT ON grammar.lexeme                TO 'grammaruser'@'localhost';*/
GRANT SELECT ON grammar.syntactic_category    TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.lexical_category      TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.phrasal_category      TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.rule                  TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.term                  TO 'grammaruser'@'localhost';
GRANT SELECT ON grammar.factor                TO 'grammaruser'@'localhost';
