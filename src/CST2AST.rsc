module CST2AST

import Syntax;
import AST;

import IO;

import ParseTree;
import String;
import Boolean;

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
  return form(id("<f.formName>", src=f.formName@\loc), cst2ast(f.formBody), src=f@\loc);
}

AQuestion cst2ast(Question q) {
  switch(q) {
  	case(Question) `<Str qText> <Id identifier> : <Type qType>`: return question("<qText>", cst2ast(identifier), cst2ast(qType), src=q@\loc);
  	
  	default: throw "Unhandled question: <q>";
  }
}

AQuestion cst2ast(ComputedQuestion q) {
  switch(q) {
  	case(ComputedQuestion) `<Question quest>`: return cst2ast(quest);
  	case(ComputedQuestion) `<Question quest> = <Expr computedExpr>`: {
  		qAst = cst2ast(quest);
  		return computedQuestion("<qAst.qText>", qAst.name, qAst.qType, cst2ast(computedExpr), src=q@\loc);
  	}
  	
  	default: throw "Unhandled question: <q>";
  }
}

ABlock cst2ast(Block b) {
  expressions = [cst2ast(e) | (BlockElement) `<Expr e>` <- b.elements];
  questions = [cst2ast(cq) | (BlockElement) `<ComputedQuestion cq>` <- b.elements];
  ifThens = [cst2ast(ite) | (BlockElement) `<IfThenElse ite>` <- b.elements];
  
  return block(expressions, questions, ifThens, src=b@\loc);
}

AIfThen cst2ast(IfThenElse ite) {
  switch(ite) {
    case(IfThenElse) `<IfThen mainPart>`: return cst2ast(mainPart);
    case(IfThenElse) `<IfThen mainPart> else <Block elseBody>`: {
      iteAst = cst2ast(mainPart);
      return ifThenElse(iteAst.guard, iteAst.thenBody, cst2ast(elseBody), src=ite@\loc);
    }
  
    default: throw "Unhandled ifThenElse: <ite>";
  }
}

AIfThen cst2ast(IfThen ift) {
  switch(ift) {
  	case(IfThen) `if ( <Expr guard> ) <Block thenBody>`: return ifThen(cst2ast(guard), cst2ast(thenBody), src=ift@\loc);
  
  	default: throw "Unhandled ifThen: <ift>";
  }
}

AExpr cst2ast(Expr e) {
  switch(e) {
    case(Expr) `<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    case(Expr) `<Str literal>`: return string("<literal>", src=literal@\loc);
    case(Expr) `<Bool literal>`: return boolean(fromString("<literal>"), src=literal@\loc);
    case(Expr) `<Int literal>`: return integer(toInt("<literal>"), src=literal@\loc);
    case(Expr) `( <Expr ex> )`: return cst2ast(ex);
    case(Expr) `! <Expr ex>`: return neg(cst2ast(ex), src=e@\loc);
    case(Expr) `<Expr lhs> * <Expr rhs>`: return mul(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> / <Expr rhs>`: return div(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> % <Expr rhs>`: return modu(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> + <Expr rhs>`: return add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> - <Expr rhs>`: return subtr(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> \> <Expr rhs>`: return greater(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> \< <Expr rhs>`: return less(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> \>= <Expr rhs>`: return geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> \<= <Expr rhs>`: return leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> == <Expr rhs>`: return equals(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> != <Expr rhs>`: return neg(equals(cst2ast(lhs), cst2ast(rhs), src=e@\loc), src=e@\loc);
    case(Expr) `<Expr lhs> && <Expr rhs>`: return land(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case(Expr) `<Expr lhs> || <Expr rhs>`: return lor(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  switch(t) {
  	case(Type) `<Type t>`: return typ("<t>", src=t@\loc);
  	
  	default: throw "Unhandled type: <t>";
  	}
}

AId cst2ast(Id i) {
	return id("<i>", src=i@\loc);
}
