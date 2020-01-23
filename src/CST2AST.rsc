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
  switch(f) {
  	case(Form) `"form" <Id formName> <Block formBody>`: return form(formName, cst2ast(formBody), src=f@\loc);
  
  	default: throw "Unhandled form <f>";
  }
}

AQuestion cst2ast(ComputedQuestion q) {
  switch(q) {
  	case(ComputedQuestion) `<Question q>`: return cst2ast(q);
  	case(ComputedQuestion) `<Question q> "=" <Expr computedExpr>`: {
  		qAst = cast2ast(q);
  		return computedQuestion(q.qText, q.name, cst2ast(q.qType), cst2ast(computedExpr), src=q@\loc);
  	}
  	
  	default: throw "Unhandled question: <q>";
  }
}

AQuestion cst2ast(Question q) {
  switch(q) {
  	case(Question) `<Str qText> <Id identifier> ":" <Type qType>`: return question(qText, identifier, cst2ast(qType), src=q@\loc);
  	
  	default: throw "Unhandled question: <q>";
  }
}

AExpr cst2ast(Expr e) {
  switch(e) {
    case(Expr) `<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case(Expr) `<Str literal>`: return string(literal, src=literal@\loc);
    case(Expr) `<Bool literal>`: return boolean(literal, src=literal@\loc);
    case(Expr) `<Int literal>`: return integer(literal, src=literal@\loc);
    case(Expr) `"(" <Expr ex> ")"`: return cst2ast(ex);
    case(Expr) `"!" <Expr ex>`: return neg(cst2ast(ex), src=e@\loc);
    case(Expr) `<Expr lhs> "*" <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "/" <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "%" <Expr rhs>`: return modu(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "+" <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "-" <Expr rhs>`: return subtr(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "\>" <Expr rhs>`: return greater(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "\<" <Expr rhs>`: return less(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "\>=" <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "\<=" <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "==" <Expr rhs>`: return equals(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "!=" <Expr rhs>`: return neg(equals(cst2ast(lhs), cst2ast(rhs), src=e@\loc), src=e@\loc);
    case(Expr) `<Expr lhs> "&&" <Expr rhs>`: return land(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> "||" <Expr rhs>`: return lor(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    
    default: throw "Unhandled expression: <e>";
  }
}

AId cst2ast(Id i) {
	return ref(id("<i>"));
}

AType cst2ast(Type t) {
  switch(t) {
  	case(Type) `<Type t>`: return typ(t);
  	
  	default: throw "Unhandled type: <t>";
  	}
}
