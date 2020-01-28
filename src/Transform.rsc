module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  return form(f.name, flatten(f.formBody)); 
}

ABlock flatten(ABlock b){
	//b.ifThens = flatten;

	//ifs = b.ifThens;
	flatIfs = [];
	for(AIfThen ifs <- b.ifThens) flatIfs += flatten(ifs);
	
	for(AQuestion q <- b.questions) flatIfs += flatten(q);
	
	b.ifThens = flatIfs;
	b.questions = [];
	return b;
}

list[AIfThen] flatten(AIfThen ifthn){
	thenbody = flatten(ifthn.thenBody);
	elsebody = flatten(ifthn.elseBody);
	
	flatIfs = [];
	
	for(AIfThen ifs <- thenbody.ifThens) flatIfs += ifThenElse(land(ifs.guard, ifthn.guard),ifs.thenBody,ifs.elseBody);
	for(AIfThen ifs <- elsebody.ifThens) flatIfs += ifThenElse(land(ifs.guard, ifthn.guard),ifs.thenBody,ifs.elseBody);	
	return flatIfs;
}

AIfThen flatten(AQuestion q){
	return ifThenElse(cst2ast(parse(#Expr, "true")), block([], [q], []), block([], [], []));
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
   return f; 
 } 
 
 
 

