module \test

import IO;

list[int] test1() {
  arr = [1,2,3,4,5];
  test2(arr);
  return arr;
}

void test2(list[int] arr) {
  arr[0] = 100;
  println(arr);
}