module Syntax

extend lang::std::Layout;
extend lang::std::Id;


/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id formName Block formBody; 

syntax Question = Str qText Id identifier ":" Type qType;

syntax ComputedQuestion = Question question ("=" Expr computedExpr)?; 

syntax Block = @Foldable "{" BlockElement* elements "}";

syntax BlockElement 
	= Expr e 
	| ComputedQuestion cq 
	| IfThenElse ite
	;

syntax IfThen = "if" "(" Expr guard ")" Block thenBody;

syntax IfThenElse = IfThen mainPart ("else" Block else)?;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr = expression:
	"(" Expr ")"
	> right "!" Expr
	> left (Expr lhs "*" Expr rhs
	| Expr lhs "/" Expr rhs
	| Expr lhs "%" Expr rhs)
	> left (Expr lhs "+" Expr rhs
	| Expr lhs "-" Expr rhs)
	> left (Expr lhs "\>" Expr rhs
	| Expr lhs "\<" Expr rhs
	| Expr lhs "\>=" Expr rhs
	| Expr lhs "\<=" Expr rhs)
	> left (Expr lhs "==" Expr rhs
	| Expr lhs "!=" Expr rhs)
	> left Expr lhs "&&" Expr rhs
	> left Expr lhs "||" Expr rhs
	> Str literal
	| Bool literal
	| Int literal
	> Id id \ Reserved;
  
syntax Type = 
	"integer" 
	| "boolean";  
  
lexical Str = "\"" ![\n]* "\"";

lexical Int = "-"?[0-9]+;

lexical Bool = "true" | "false";

keyword Reserved = "true" 
	| "false" 
	| "form" 
	| "if"
	| "else"
	| "boolean" 
	| "integer";


