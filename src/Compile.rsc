module Compile

import AST;
import Resolve;
import IO;
import String;
import lang::html5::DOM; // see standard library

import util::Resources;

//constants
str string = "string";
str boolean = "boolean";
str integer = "integer";

HTML5Attr attrHidden = html5attr("style", "display: none;");
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
  list[HTML5Node] contents = [];
  contents += block2html(f.formBody);
  str fileName = "<substring(f.src.top.file, 0, size(f.src.top.extension) - 1)>";
  str scriptLoc = "http://localhost:8080/<fileName>.js";
  return html(head(title("<f.name.name>"), script(src(scriptLoc), \type("module"), html5attr("crossorigin", "anonymous")), vueCDN), body(div(div(contents), id("app"))));
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
      contents += p("{{message}}", id(q.src));
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
  contents += div(block2html(ift.thenBody), class("thenBody"), id("ifThen-<ift.src.begin.line>.thenBody"));
  contents += div(block2html(ift.elseBody), class("elseBody"), id("ifThen-<ift.src.begin.line>.elseBody"));
  return div(contents);
}

HTML5Node getInputNode(AType t) {
  switch(t) {
    case typ(string): return input();
    case typ(boolean): return input(\type("checkbox"), onclick("test()"));
    case typ(integer): return input(\type("number"), step("1"));
  }
  return p("[INVALID TYPE: <t.typeName>]");
}

str form2js(AForm f) {
  return 
  "
  import Vue from \'<vueUrl>/dist/vue.esm.browser.min.js\';
  var app = new Vue({
  el: \'#app\',
  data: {
    message: \'Hello Vue!\'
  }
  });
  function test() {
  	console.log(\'this is a test function\');
  }
  
  ";
}
