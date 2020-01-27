module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|) 
  = form(AId name, ABlock formBody)
  ; 
	
data AQuestion(loc src = |tmp:///|) 
  = question(str qText, AId name, AType qType) 
  | computedQuestion(str qText, AId name, AType qType, AExpr computedExpr)
  ;
	
data ABlock(loc src = |tmp:///|) 
  = block(
  	list[AExpr] expressions, 
  	list[AQuestion] questions, 
  	list[AIfThen] ifThens
  );
	
data AIfThen(loc src = |tmp:///|) 
  = ifThenElse(AExpr guard, ABlock thenBody, ABlock elseBody)
  ;

data AExpr(loc src = |tmp:///|)
	= neg(AExpr unnegated)
  | mul(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | modu(AExpr lhs, AExpr rhs)
  | add(AExpr lhs, AExpr rhs)
  | subtr(AExpr lhs, AExpr rhs)
  | greater(AExpr lhs, AExpr rhs)
  | less(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | equals(AExpr lhs, AExpr rhs)
  | land(AExpr lhs, AExpr rhs)
  | lor(AExpr lhs, AExpr rhs)
  | string(str sVal)
  | boolean(bool bVal)
  | integer(int iVal)
  | ref(AId id)
	;

data AType(loc src = |tmp:///|) 
  = typ(str typeName)
  ;
	
data AId(loc src = |tmp:///|) 
  = id(str name)
  ;

