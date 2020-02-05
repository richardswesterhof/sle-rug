module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import ParseTree;
import Relation;
import Set;
import IO;
 
AForm flatten(AForm f) {
  return form(f.name, flatten(f.formBody), src=f.src); 
}

ABlock flatten(ABlock b){
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
	
	for(AIfThen ifs <- thenbody.ifThens) flatIfs += ifThenElse(land(ifs.guard, ifthn.guard), ifs.thenBody, ifs.elseBody, src=ifs.src);
	for(AIfThen ifs <- elsebody.ifThens) flatIfs += ifThenElse(land(ifs.guard, neg(ifthn.guard)), ifs.thenBody, ifs.elseBody, src=ifs.src);	
	return flatIfs;
}

AIfThen flatten(AQuestion q){
	return ifThenElse(cst2ast(parse(#Expr, "true")), block([], [q], [], src=q.src), block([], [], [], src=q.src), src=q.src);
}
 
start[Form] rename(start[Form] f, loc useOrDef, str newName) {
	AForm form = cst2ast(f);
	
	r = resolve(form);
	
	//get all strings of location
	g = r.uses[useOrDef] + invert(r.defs)[useOrDef];
	
	//get all loc's of defs and uses SORTED and reversed
	//we want to change from the bottom so the location before don't change
	locs = reverse(sort(r.defs[g] + invert(r.uses)[g]));
	
	for(loc l <- locs) writeFile(l,newName);
	
	  return f; 
} 
 
str replace(loc l, str newName){
	visit(l){
		default: writeFile(l,newName);
	}
	

	return;
}