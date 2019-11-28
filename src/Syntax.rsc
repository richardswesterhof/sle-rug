module Syntax


extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id "{" Question* "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Question = Str Id ":" Type t; 

syntax ComputedQuestion = Str Id ":" "boolean" "=" Boolean
	| Str Id ":" "integer" "=" Integer;

syntax Block = "{" Question* "}";

syntax IfThenElse = IfThen "else" Block;

syntax IfThen = "if" "(" Boolean ")" Block;

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
	"(" Integer ")"
	> left (Integer "*" Integer
	| Integer "/" Integer)
	> left (Integer "+" Integer
	| Integer "-" Integer)
	> Int;
	
syntax Boolean = 
	"(" Boolean ")"
	> right "!" Boolean
	> left (Integer "==" Integer
	| Integer "!=" Integer
	| Boolean "==" Boolean
	| Boolean "!=" Boolean
	| Str "==" Str)
	> left Boolean "&&" Boolean
	> left Boolean "||" Boolean
	> left (Integer "\>" Integer
	| Integer "\<" Integer
	| Integer "\<=" Integer
	| Integer "\>=" Integer);

lexical Int = [0-9]+;

lexical Bool = "true" | "false";