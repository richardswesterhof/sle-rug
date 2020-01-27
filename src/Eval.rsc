module Eval

import AST;
import Resolve;

import IO;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.

//constants
str string = "string";
str boolean = "boolean";
str integer = "integer";

// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value val];

// Modeling user input
data Input = input(str question, Value val);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv venv = ();
  visit(f) {
    case AQuestion q: {
      switch(q.qType) {
        case typ(string): venv += (q.name.name : vstr(""));
        case typ(boolean): venv += (q.name.name : vbool(false));
        case typ(integer): venv += (q.name.name : vint(0));
      }
    }
  }
  return venv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve(venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  venv += eval(f.formBody, inp, venv);
  return venv; 
}

VEnv eval(ABlock b, Input inp, VEnv venv) {
  // top level questions
  for(AQuestion q <- b.questions) {
    venv += eval(q, inp, venv);
  }
  
  // questions inside ifThens
  for(AIfThen ift <- b.ifThens) {
    venv += eval(ift, inp, venv);
  }
  return venv;
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  switch(q) {
    case question(str qText, AId name, AType qType): {
      venv[name.name] = (name.name == inp.question) ? inp.val : venv[name.name];
    }
    case computedQuestion(str qText, AId name, AType qType, AExpr computedExpr): {
      venv[name.name] = eval(computedExpr, venv);
    }
  }
  return venv; 
}

VEnv eval(AIfThen ift, Input inp, VEnv venv) {
  switch(ift) {
    case ifThen(AExpr guard, ABlock thenBody): {
      if(eval(guard, venv).b) {
        venv += eval(thenBody, inp, venv);
      }
    }
    case ifThenElse(AExpr guard, ABlock thenBody, ABlock elseBody): {
      if(eval(guard, venv)) {
        venv += eval(thenBody, inp, venv);
      }
      else {
        venv += eval(elseBody, inp, venv);
      }
    }
  }
  return venv;
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case neg(AExpr unnegated): return vbool(!eval(unnegated, venv).b);
	case mul(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n * eval(rhs, venv).n);
	case div(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n / eval(rhs, venv).n);
	case modu(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n % eval(rhs, venv).n);
	case add(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n + eval(rhs, venv).n);
	case subtr(AExpr lhs, AExpr rhs): return vint(eval(lhs, venv).n - eval(rhs, venv).n);
	case greater(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n > eval(rhs, venv).n);
	case less(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n < eval(rhs, venv).n);
	case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
	case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
	case equals(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv) == eval(rhs, venv));
	case land(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
	case lor(AExpr lhs, AExpr rhs): return vbool(eval(lhs, venv).b || eval(rhs, venv).b);
	case string(str sVal): return vstr(sVal);
	case boolean(bool bVal): return vbool(bVal);
	case integer(int iVal): return vint(iVal);
    
    default: throw "Unsupported expression <e>";
  }
}