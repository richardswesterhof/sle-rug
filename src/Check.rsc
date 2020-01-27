module Check

import AST;
import Resolve;
import Message; // see standard library

import util::Math;

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
alias TEnv = rel[loc def, loc varDef, str name, str label, Type \type];


TEnv collect(AForm f) {
  tenv = {};  
  
  visit(f) {
    case AQuestion q: tenv += {<q.src, q.name.src, "<q.name.name>", q.qText, AType2Type(q.qType)>};
  }
  return tenv;
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  visit(f) {
    case AQuestion q: msgs += check(q, tenv, useDef);
    case AExpr e: msgs += check(e, tenv, useDef);
  } 
  return msgs;
}

set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  switch(q) {
    case question(str qText, AId name, AType qType, src = qSrc): {
      for(<loc src, loc varSrc, "<name.name>", str label, Type t> <- tenv) {
        msgs += {error("Variable \"<name.name>\" is already defined as Type <type2String(t)> on line <varSrc.begin.line>", name.src) 
                 | t != AType2Type(qType) && name.src.begin.line > varSrc.begin.line};
                 
        msgs += {warning("Duplicate label of line <src.begin.line>", qSrc) | qText == label && name.src.begin.line > src.end.line};
      }
    }
    case computedQuestion(str qText, AId name, AType qType, AExpr computedExpr, src = qSrc): {
      for(<loc src, loc varSrc, "<name.name>", str label, Type t> <- tenv) {
        msgs += {error("Variable \"<name.name>\" is already defined as Type <type2String(t)> on line <varSrc.begin.line>", name.src) 
                 | t != AType2Type(qType) && name.src.begin.line > varSrc.begin.line};
                 
        msgs += {warning("Duplicate label of line <src.begin.line>", qSrc) | qText == label && name.src.begin.line > src.end.line};
      
        Type exprType = typeOf(computedExpr, tenv, useDef);
        msgs += {error("Expected Type of expression to be <type2String(AType2Type(qType))>, but got <type2String(exprType)>", computedExpr.src) | exprType != AType2Type(qType)};
      }
    }
  }
  return msgs;
}

// Check operand compatibility with operators.
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch(e) {
    case ref(AId x):
      msgs += {error("Undeclared variable", x.src) | useDef[x.src] == {}};
    case string(_): return {};
    case boolean(_): return {};
    case integer(_): return {};
	case neg(AExpr e): {
	  eType = typeOf(e, tenv, useDef);
	  msgs += {error("Expected Type to be Boolean, but got <type2String(eType)>", e.src) | eType != tbool()};
	}
	case mul(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case div(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case modu(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case add(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case subtr(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case greater(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case less(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case geq(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case leq(AExpr lhs, AExpr rhs): msgs += checkInteger(lhs, rhs, tenv, useDef);
	case equals(AExpr lhs, AExpr rhs): {
	  lhsType = typeOf(lhs, tenv, useDef);
	  rhsType = typeOf(rhs, tenv, useDef);
	  msgs += {error("Type <type2String(lhsType)> does not match Type <type2String(rhsType)>", e.src) | lhsType != rhsType};
	}
	case land(AExpr lhs, AExpr rhs): msgs += checkBoolean(lhs, rhs, tenv, useDef);
	case lor(AExpr lhs, AExpr rhs): msgs += checkBoolean(lhs, rhs, tenv, useDef);
    
    default: throw "Unchecked expression: <e> at line <e.src.begin.line>";
  }
  return msgs; 
}

set[Message] checkInteger(AExpr lhs, AExpr rhs, TEnv tenv, UseDef useDef) {
  lhsType = typeOf(lhs, tenv, useDef);
  rhsType = typeOf(rhs, tenv, useDef);
  return {error("Expected Type to be Integer, but got <type2String(lhsType)>", lhs.src) | lhsType != tint()} 
       + {error("Expected Type to be Integer, but got <type2String(rhsType)>", rhs.src) | rhsType != tint()};
}

set[Message] checkBoolean(AExpr lhs, AExpr rhs, TEnv tenv, useDef) {
  lhsType = typeOf(lhs, tenv, useDef);
  rhsType = typeOf(rhs, tenv, useDef);
  return {error("Expected Boolean, got <type2String(lhsType)>", lhs.src) | lhsType != tbool()} 
       + {error("Expected Boolean, got <type2String(rhsType)>", rhs.src) | rhsType != tbool()};
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch(e) {
    case ref(id(_, src = loc use)): {
      //find earliest type definition of variable and assume that as the correct type
      real earliest = pow(2,64);
      Type typ = tunknown();
      for (<use, loc def> <- useDef, <_, def, _, _, Type t> <- tenv) {
        typ = typ == tunknown()? t : typ;
        if(def.begin.line < earliest) {
          earliest = toReal(def.begin.line);
          typ = t;
        }
      }
      return typ;
    }
    case neg(AExpr unnegated): return typeOf(unnegated, tenv, useDef) == tbool()? tbool() : tunknown();
	case mul(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tint() : tunknown();
	case div(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tint() : tunknown();
	case modu(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tint() : tunknown();
	case add(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tint() : tunknown();
	case subtr(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tint() : tunknown();
	case greater(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tbool() : tunknown();
	case less(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tbool() : tunknown();
	case geq(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tbool() : tunknown();
	case leq(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tint() && typeOf(rhs, tenv, useDef) == tint()) ? tbool() : tunknown();
	case equals(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef)) ? tbool() : tunknown();
	case land(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool()) ? tbool() : tunknown();
	case lor(AExpr lhs, AExpr rhs): return (typeOf(lhs, tenv, useDef) == tbool() && typeOf(rhs, tenv, useDef) == tbool()) ? tbool() : tunknown();
	case string(_): return tstr();
    case boolean(_): return tbool();
  	case integer(_): return tint();
  }
  return tunknown();
}

str type2String(Type t) {
  switch(t) {
    case tstr(): return string;
    case tbool(): return boolean;
    case tint(): return integer;
  }
  return "[Unknown Type]";
}

Type AType2Type(AType t) {
  switch(t) {
    case typ("string"): return tstr();
    case typ("boolean"): return tbool();
    case typ("integer"): return tint();
  }
  return tunknown();
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
 
 

