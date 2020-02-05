module \test

import IO;

list[int] test1() {
  return test2([]);
}

list[int] test2(list[int] arr) {
  return test2(arr) + [1];
}