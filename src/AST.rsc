module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|) = 
	form(AId id, list[AQuestion] questions); 

data AQuestion(loc src = |tmp:///|) = 
	question(str questionText, AId id, AType typ);

data AExpr(loc src = |tmp:///|) = 
	ref(AId id) | boolean(ABool b) | integer(AInt i);

data AInt(loc src = |tmp:///|) = 
	integer(AInt intExpr) | literal(int val) | intVar(AId id);
	
data ABool(loc src = |tmp:///|) = 
	boolean(ABool val) | literal(bool val) | boolVar(AId id);

data AId(loc src = |tmp:///|) = 
	id(str name);

data AType(loc src = |tmp:///|) = 
	typ(str typeName);
