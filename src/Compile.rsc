module Compile

import AST;
import Resolve;
import IO;
import String;
import lang::html5::DOM; // see standard library


str string = "string";
str boolean = "boolean";
str integer = "integer";

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
  list[HTML5Node] contents = [];
  contents += block2html(f.formBody);
  return html(head(title("<f.name.name>"), body(contents)));
}

HTML5Node question2html(AQuestion q) {
  list[HTML5Node] contents = [];
  //cleaning the qText from string quotes
  contents += p("<substring(q.qText, 1, size(q.qText) - 1)>");
  
  switch(q) {
    case question(str qText, AId name, AType qType): {
      contents += getInputNode(qType);
    }
    case computedQuestion(str qText, AId name, AType qType, AExpr computedExpr): 
      contents += p(id(q.src));
  }
  
  return div(contents);

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
  contents += div(block2html(ift.thenBody));
  contents += div(block2html(ift.elseBody));
  return div(contents);
}

HTML5Node getInputNode(AType t) {
  switch(t) {
    case typ(string): return input();
    case typ(boolean): return input(\type("checkbox"));
    case typ(integer): return input(\type("number"), step("1"));
  }
  return p("[INVALID TYPE: <t.typeName>]");
}

str form2js(AForm f) {
  return "";
}
