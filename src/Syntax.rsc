module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id "{" Question* "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = Str Id ":" Type; 

syntax ComputedQuestion = ;

syntax Block = ;

syntax IfThenElse = ;

syntax IfThen = ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr = Str 
	| Bool 
	| Int
	| right "!" Expr
	> left (Expr "*" Expr
	| Expr "/" Expr)
	> left (Expr "+" Expr
	| Expr "-" Expr)
	> left (Expr "\>" Expr
	| Expr "\<" Expr
	| Expr "\<=" Expr
	| Expr "\>=" Expr)
	> left (Expr "==" Expr
	| Expr "!=" Expr)
	> left Expr "&&" Expr
	> left Expr "||" Expr
	> Id \ "true" \ "false" // true/false are reserved keywords
	;
  
syntax Type = "integer" 
	| "boolean";  
  
lexical Str = "\"" [a-z, A-Z, 0-9] "\"";

lexical Int = [0-9]+;

lexical Bool = "true" | "false";



