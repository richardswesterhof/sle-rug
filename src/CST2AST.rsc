module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("", [], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  throw "Not yet implemented";
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case (Expr)`<Integer i>`: switch(i) {
    	case (Integer)`<Int literal>`: return integer(literal, src=literal@\loc);
    	case (Integer)`<Id identifier>`: return intVar(cst2ast(identifier), src=identifier@\loc);
    }
    
    case (Expr)`<Boolean b>`: switch(i) {
    	case (Boolean)`<Bool literal>`: return boolean(literal, src=literal@\loc);
    	case (Integer)`<Id identifier>`: return boolVar(cst2ast(identifier), src=identifier@\loc);
    }
    
    
        // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

AId cst2ast(Id i) {
	return ref(id("<i>"));
}

AType cst2ast(Type t) {
  throw "Not yet implemented";
}
