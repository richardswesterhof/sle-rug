module Check

import AST;
import Resolve;
import Message; // see standard library

import IO;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;
  
str integer = "Integer";
str boolean = "Boolean";
str string = "String";

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];


TEnv collect(AForm f) {
  tenv = {};  
  
  visit(f) {
    case AQuestion q: tenv += {<q.src, "<q.name.name>", q.qText, AType2Type(q.qType)>};
  }
  return tenv;
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  visit(f) {
   case T? formElement: tenv += check(formElement); 
   
   default: throw "Unknown element in form <f>";
  }
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  switch(q) {
    case question(str qText, AId name, AType qType): {
      println(TEnv[name.name]);
      msgs += {error("Variable \"<name.name>\" is already defined here: <name.src>") | TEnv[name.name] == name.name};
    }
    case computedQuestion(str qText, AId name, AType qtype, AExpr computedExpr): ;
  }
}

// Check operand compatibility with operators.
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch(e) {
    case ref(AId x):
      msgs += {error("Undeclared question", x.src) | useDef[x.src] == {}};
	case neg(Expr e): {
	  eType = typeOf(e);
	  msgs += {error("Expected Boolean, got <type2String(eType)>", e.src) | eType != tbool()};
	}
	case mul(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case div(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case modu(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case add(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case subtr(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case greater(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case less(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case geq(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case leq(Expr lhs, Expr rhs): msgs += checkInteger(lhs, rhs);
	case equals(Expr lhs, Expr rhs): {
	  lhsType = typeOf(lhs);
	  rhsType = typeOf(rhs);
	  msgs += {error("Type <lhsType> does not match Type <rhsType>", e.src) | lhsType != rhsType};
	}
	case land(Expr lhs, Expr rhs): msgs += checkBoolean(lhs, rhs);
	case lor(Expr lhs, Expr rhs): msgs += checkBoolean(lhs, rhs);
    
    default: throw "Unchecked expression: <e>";
  }
  
  return msgs; 
}

set[Message] checkInteger(AExpr lhs, AExpr rhs) {
  lhsType = typeOf(lhs);
  rhsType = typeOf(rhs);
  return {error("Expected Integer, got <type2String(lhsType)>", lhs.src) | lhsType != tint()} 
       + {error("Expected Integer, got <type2String(rhsType)>", rhs.src) | rhsType != tint()};
}

set[Message] checkBoolean(AExpr lhs, AExpr rhs) {
  lhsType = typeOf(lhs);
  rhsType = typeOf(rhs);
  return {error("Expected Boolean, got <type2String(lhsType)>", lhs.src) | lhsType != tbool()} 
       + {error("Expected Boolean, got <type2String(rhsType)>", rhs.src) | rhsType != tbool()};
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch(e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case string(_): return tstr();
    case boolean(_): return tbool();
  	case integer(_): return tint();
    
    default: return tunknown();
  }
}

str type2String(Type t) {
  switch(t) {
    case tstr(): return string;
    case tbool(): return boolean;
    case tint(): return integer;
    
    default: return "[Unknown Type]";
  }
}

Type AType2Type(AType t) {
  switch(t) {
    case typ("string"): return tstr();
    case typ("boolean"): return tbool();
    case typ("integer"): return tint();
    
    default: return tunknown();
  }
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

