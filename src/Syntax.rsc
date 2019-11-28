module Syntax


extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id "{" Question* "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = Str Id ":" Type t; 

syntax ComputedQuestion = Str Id ":" "boolean" "=" Bool
	| Str Id ":" "integer" "=" Int;

syntax Block = "{" Expr* "}";

syntax IfThenElse = IfThen "else" Block;

syntax IfThen = "if" "(" Expr ")" Block;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr = Str 
	| Bool 
	| Int
	> Id \ "true" \ "false" // true/false are reserved keywords
	;
  
syntax Type = "integer" 
	| "boolean";  
  
lexical Str = "\"" ![\n]* "\"";

syntax Integer = 
	left (Int "*" Int
	| Int "/" Int)
	> left (Int "+" Int
	| Int "-" Int);
	
syntax Boolean = 
	right "!" Bool
	> left (Int "==" Int
	| Int "!=" Int
	| Bool "==" Bool
	| Bool "!= Bool"
	| Str "==" Str)
	> left Expr "&&" Expr
	> left Expr "||" Expr
	> left (Int "\>" Int
	| Int "\<" Int
	| Int "\<=" Int
	| Int "\>=" Int);

lexical Int = [0-9]+;

lexical Bool = "true" | "false";