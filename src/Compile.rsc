module Compile

import AST;
import Resolve;
import IO;
import String;
import lang::html5::DOM; // see standard library

import util::Resources;
import List;
import Eval;

//constants
str string = "string";
str boolean = "boolean";
str integer = "integer";

str vueUrl = "https://cdn.jsdelivr.net/npm/vue@2.6.11";
HTML5Node vueCDN = script(src(vueUrl));

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, "\<!DOCTYPE HTML\>\n" + toString(form2html(f)));
}

HTML5Node form2html(AForm f) {
  list[HTML5Node] contents = [h1("<f.name.name>")];
  contents += block2html(f.formBody);
  contents += button("submit", html5attr("@click", "submitForm"), class("submit"));
  //getting the filename without the extension
  str fileName = "<substring(f.src.top.file, 0, size(f.src.top.file) - size(f.src.top.extension) - 1)>";
  str scriptLoc = "http://localhost:8080/<fileName>.js";
  str cssLoc = "http://localhost:8080/main.css";
  return html(
    head(
      title("<f.name.name>"), 
      vueCDN, 
      script(
        src(scriptLoc), 
        \type("module"), 
        html5attr("crossorigin", "anonymous")
      ),
      link(
        \rel("stylesheet"),
        href("<cssLoc>")
      )
    ), 
    body(
      div(
        div(contents), 
        id("app")
      )
    )
  );
}

HTML5Node question2html(AQuestion q) {
  list[HTML5Node] contents = [];
  //cleaning the qText from string quotes
  contents += p("<substring(q.qText, 1, size(q.qText) - 1)>");
  
  switch(q) {
    case question(str qText, AId name, AType qType): {
      contents += getInputNode(name, qType);
    }
    case computedQuestion(str qText, AId name, AType qType, AExpr computedExpr, src = qSrc): 
      contents += input(html5attr("v-model", "<getComputedVarName(q)>"), id(q.src), html5attr("disabled", "true"));
  }
  
  return div(div(contents), class("question"));
}

HTML5Node block2html(ABlock b) {
  list[HTML5Node] contents = [];
  // top level questions
  for(AQuestion q <- b.questions) {
    contents += question2html(q);
  }
  
  // questions inside ifThens
  for(AIfThen ift <- b.ifThens) {
    contents += ifThen2html(ift);
  }
  
  return div(contents);
}

HTML5Node ifThen2html(AIfThen ift) {
  list[HTML5Node] contents = [];
  contents += div(block2html(ift.thenBody), html5attr("v-if", "<getComputedVarName(ift)>"), class("thenBody"), id("ifThen-<ift.src.begin.line>.thenBody"));
  contents += div(block2html(ift.elseBody), html5attr("v-else", "true"), class("elseBody"), id("ifThen-<ift.src.begin.line>.elseBody"));
  return div(div(contents), class("ifThen"));
}

HTML5Node getInputNode(AId name, AType t) {
  switch(t) {
    case typ(string): return input(html5attr("v-model", "<name.name>"));
    case typ(boolean): return input(\type("checkbox"), html5attr("v-model", "<name.name>"));
    case typ(integer): return input(\type("number"), step("1"), html5attr("v-model", "<name.name>"));
  }
  return p("[INVALID TYPE: <t.typeName>]");
}

str prettyPrintExpr(AExpr e, str parentName) {
  switch(e) {
    case neg(AExpr unnegated): return "(!<prettyPrintExpr(unnegated, parentName)>)";
    case mul(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> * <prettyPrintExpr(rhs, parentName)>)";
    case div(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> / <prettyPrintExpr(rhs, parentName)>)";
    case modu(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> % <prettyPrintExpr(rhs, parentName)>)";
    case add(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> + <prettyPrintExpr(rhs, parentName)>)";
    case subtr(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> - <prettyPrintExpr(rhs, parentName)>)";
    case greater(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> \> <prettyPrintExpr(rhs, parentName)>)";
    case less(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> \< <prettyPrintExpr(rhs, parentName)>)";
    case geq(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> \>= <prettyPrintExpr(rhs, parentName)>)";
    case leq(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> \<= <prettyPrintExpr(rhs, parentName)>)";
    case equals(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> == <prettyPrintExpr(rhs, parentName)>)";
    case land(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> && <prettyPrintExpr(rhs, parentName)>)";
    case lor(AExpr lhs, AExpr rhs): return "(<prettyPrintExpr(lhs, parentName)> || <prettyPrintExpr(rhs, parentName)>)";
    case string(str sVal): return "\'<sVal>\'";
    case boolean(bool bVal): return "<bVal>";
    case integer(int iVal): return "<iVal>";
    case ref(AId id): return (size(parentName) > 0) ? "<parentName>.<id.name>" : "<id.name>";
  }
  return "";
}

str form2js(AForm f) {
  RefGraph rg = resolve(f);
  VEnv initialEnv = initialEnv(f);
  //variables that will be mapped directly to questions
  list[str] variables = getNeededVars(rg, initialEnv);
  
  //computed variables will be mapped to IfThen guards and computed questions
  list[str] computedVars = getNeededComputedVars(f);
  
  list[str] methods = [
  "submitForm() {
  			console.log(\'VALUES SUBMITTED \' + new Date());
			<for(<str name, _> <- rg.defs) {>
			console.log(\'<name> == \' + this.<name>);
			<}>
			console.log(\'END VALUES SUBMITTED\');
		}"
  ];

  return 
    "//vue.esm.browser.min.js for production, vue.esm.browser.js for development\n" + 
	"import Vue from \'<vueUrl>/dist/vue.esm.browser.js\';\n" +
	"Vue.config.productionTip = false;\n" +
	"var app = new Vue({
	el: \'#app\',
	data: {
		<intercalate(",\n\t\t", variables)>
	},
	
	computed: {
		<intercalate(",\n\t\t", computedVars)>
	},
  
	methods: {
		<intercalate(",\n\t\t", methods)>
	},
});
";
}

list[str] getNeededVars(RefGraph rg, VEnv venv) {
  list[str] variables = [];
  for(<str name, _> <- rg.defs) {
    switch(venv[name]) {
      case vint(int n): variables += "<name>: <n>";
      case vbool(bool b): variables += "<name>: <b>";
      case vstr(str s): variables += "<name>: \'<s>\'";
    }
  }
  return variables;
}

list[str] getNeededComputedVars(AForm f) {
  list[str] computedVars = [];
  visit(f) {
    case AIfThen ite: computedVars += "<getComputedVarName(ite)>() {
	\t\treturn <prettyPrintExpr(ite.guard, "this")>;
	\t}";
    case AQuestion q: if(q is computedQuestion) computedVars += "<getComputedVarName(q)>() {
	\t\treturn <prettyPrintExpr(q.computedExpr, "this")>;
	\t}";
  }
  
  return computedVars;
}

str getComputedVarName(AIfThen ite) {
  return "__COMPUTED_GUARD_<ite.src.begin.line>_<ite.src.begin.column>";
}

str getComputedVarName(AQuestion q) {
  return "__COMPUTED_QUESTION_<q.src.begin.line>_<q.src.begin.column>";
}
