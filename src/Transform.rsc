module Transform

import Syntax;
import Resolve;
import AST;
import CST2AST;
import ParseTree;
import Relation;
import Set;
import IO;

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
  return form(f.name, flatten(f.formBody), src=f.src); 
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
	
	for(AIfThen ifs <- thenbody.ifThens) flatIfs += ifThenElse(land(ifs.guard, ifthn.guard), ifs.thenBody, ifs.elseBody, src=ifs.src);
	for(AIfThen ifs <- elsebody.ifThens) flatIfs += ifThenElse(land(ifs.guard, neg(ifthn.guard)), ifs.thenBody, ifs.elseBody, src=ifs.src);	
	return flatIfs;
}

AIfThen flatten(AQuestion q){
	return ifThenElse(cst2ast(parse(#Expr, "true")), block([], [q], [], src=q.src), block([], [], [], src=q.src), src=q.src);
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName/*, UseDef useDef*/) {
 	AForm form = cst2ast(f);
 	
 	r = resolve(form);
 	//ds = resolve(form).defs;
 	
 	//text = "";
 	//get all def strings of location
 	//invert(r.defs)[l]
 	
 	//get all use strings of location
 	//r.uses[l]
 	
 	//get all strings of location
 	g = r.uses[useOrDef] + invert(r.defs)[useOrDef];
 	
 	//get all uses with string
 	//invert(r.uses)[g]
 	
 	//get all defs with string
 	//r.defs[g]
 	
 	//get all loc's of defs and uses SORTED and reversed
 	//we want to change from the bottom so the location before don't change
 	//locs = ;
 	locs = reverse(sort(r.defs[g] + invert(r.uses)[g]));
 	
 	for(loc l <- locs) writeFile(l,newName);
 	
 	/*
 	contents = sort(
      contents, 
      bool(OrderedNode a, OrderedNode b) {
        if (a.src.begin.line < b.src.begin.line) return true;
        else if(a.src.begin.line == b.src.begin.line) return a.src.begin.column < b.src.begin.column; 
        else return false;
      });
 	
 	*/
 	
 	//invert(r.uses)[r.uses[|project://QL/examples/custom.myql|(168,12,<9,8>,<9,20>)]];
 	
 	//for(Use u <- us) if(u.use == useOrDef) text = u.name;
 	
 	//for(Use u <- uses) print(u.name);
 
 	//useDef = reverse(useDef);
 	
 	//for(Use u <- useDef) print("in us"); 	
 	
   return f; 
 }
 
 list[loc] testt(start[Form] f, loc useOrDef, str newName/*, UseDef useDef*/) {
 	AForm form = cst2ast(f);
 	
 	r = resolve(form);
 	//get all strings of location
 	g = r.uses[useOrDef] + invert(r.defs)[useOrDef];
 	
 	//get all loc's of defs and uses SORTED and reversed
 	//we want to change from the bottom so the location before don't change
 	locs = reverse(sort(r.defs[g] + invert(r.uses)[g]));
 	
 		
 	//invert(r.uses)[r.uses[|project://QL/examples/custom.myql|(168,12,<9,8>,<9,20>)]];
 	
 	//for(Use u <- us) if(u.use == useOrDef) text = u.name;
 	
 	//for(Use u <- uses) print(u.name);
 
 	//useDef = reverse(useDef);
 	
 	//for(Use u <- useDef) print("in us"); 	
 	
   return locs; 
 }
 
 
 str replace(loc l, str newName){
 	visit(l){
 		default: writeFile(l,newName);
 	}
 	
 
 	return;
 }
 
 
 
 
 