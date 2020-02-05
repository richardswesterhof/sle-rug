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

syntax IfThenElse = IfThen mainPart ("else" Block elseBody)?;

syntax Expr 
  = "(" Expr ")"
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
  
syntax Type 
  = "integer" 
  | "boolean"
  | "string";  
  
lexical Str = "\"" ![\"]* "\"";

lexical Int = "-"?[0-9]+;

lexical Bool = "true" | "false";

keyword Reserved = "true" 
  | "false" 
  | "form" 
  | "if"
  | "else"
  | "boolean" 
  | "integer"
  | "string"
  ;


