module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  Use uses = {};
  visit(f) {
    case ref(AId i): uses += {<i.src, i.name>};
  }
  
  return uses;
}

Def defs(AForm f) {
  Def defs = {};
  visit(f) {
    case question(str qText, AId name, AType typ): defs += {<name.name, name.src>};
    case computedQuestion(str qText, AId name, AType typ, AExpr computedExpr): defs += {<name.name, name.src>};
  } 
  
  return defs;
}