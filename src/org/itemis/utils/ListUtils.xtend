/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.utils

import java.util.List

class ListUtils {
  def <T extends Object> ensureListIndexExists(List<T> list, T fillValue, int index) {
    ensureListLength(list, fillValue, index + 1)
  }

  def <T extends Object> ensureListLength(List<T> list, T fillValue, int length) {
    while(list.length < length) {
      list.add(fillValue)
    }
  }

  def <T extends Object> ensureNestedListIndexExists(List<List<T>> list, int index) {
    ensureNestedListLength(list, index + 1)
  }

  def <T extends Object> ensureNestedListLength(List<List<T>> list, int length) {
    while(list.length < length) {
      list.add(newArrayList())
    }
  }

  def <T extends Object> T get(T list) {
    list
  }

  def <T extends Object> T get(List<T> list, int a) {
    list.get(a)
  }

  def <T extends Object> T get(List<List<T>> list, int a, int b) {
    list.get(a).get(b)
  }

  def <T extends Object> T get(List<List<List<T>>> list, int a, int b, int c) {
    list.get(a, b).get(c)
  }

  def <T extends Object> T get(List<List<List<List<T>>>> list, int a, int b, int c, int d) {
    list.get(a, b, c).get(d)
  }

  def <T extends Object> T get(List<List<List<List<List<T>>>>> list, int a, int b, int c, int d, int e) {
    list.get(a, b, c, d).get(e)
  }

  def <T extends Object> T get(List<List<List<List<List<List<T>>>>>> list, int a, int b, int c, int d, int e, int f) {
    list.get(a, b, c, d, e).get(f)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<T>>>>>>> list, int a, int b, int c, int d, int e,
    int f, int g) {
    list.get(a, b, c, d, e, f).get(g)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<T>>>>>>>> list, int a, int b, int c, int d,
    int e, int f, int g, int h) {
    list.get(a, b, c, d, e, f, g).get(h)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<List<T>>>>>>>>> list, int a, int b, int c, int d,
    int e, int f, int g, int h, int i) {
    list.get(a, b, c, d, e, f, g, h).get(i)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>> list, int a, int b, int c,
    int d, int e, int f, int g, int h, int i, int j) {
    list.get(a, b, c, d, e, f, g, h, i).get(j)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>> list, int a, int b,
    int c, int d, int e, int f, int g, int h, int i, int j, int k) {
    list.get(a, b, c, d, e, f, g, h, i, j).get(k)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>> list, int a,
    int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l) {
    list.get(a, b, c, d, e, f, g, h, i, j, k).get(l)
  }

  def <T extends Object> T get(List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>> list,
    int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m) {
    list.get(a, b, c, d, e, f, g, h, i, j, k, l).get(m)
  }

  def <T extends Object> T get(
    List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>> list, int a, int b, int c,
    int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n) {
    list.get(a, b, c, d, e, f, g, h, i, j, k, l, m).get(n)
  }

  def <T extends Object> T get(
    List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>> list, int a, int b,
    int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n, int o) {
    list.get(a, b, c, d, e, f, g, h, i, j, k, l, m, n).get(o)
  }

  def <T extends Object> T get(
    List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>>> list, int a,
    int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n, int o, int p) {
    list.get(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o).get(p)
  }

  def <T extends Object> T get(T list, List<Integer> indices) {
    list
  }

  def <T extends Object> T get(List<T> list, List<Integer> indices) {
    if(indices.size >= 1) {
      list.get(indices.get(0))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get2(List<List<T>> list, List<Integer> indices) {
    if(indices.size >= 2) {
      list.get(indices.get(0), indices.get(1))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get3(List<List<List<T>>> list, List<Integer> indices) {
    if(indices.size >= 3) {
      list.get(indices.get(0), indices.get(1), indices.get(2))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get4(List<List<List<List<T>>>> list, List<Integer> indices) {
    if(indices.size >= 4) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get5(List<List<List<List<List<T>>>>> list, List<Integer> indices) {
    if(indices.size >= 5) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get6(List<List<List<List<List<List<T>>>>>> list, List<Integer> indices) {
    if(indices.size >= 6) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get7(List<List<List<List<List<List<List<T>>>>>>> list, List<Integer> indices) {
    if(indices.size >= 7) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get8(List<List<List<List<List<List<List<List<T>>>>>>>> list, List<Integer> indices) {
    if(indices.size >= 8) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get9(List<List<List<List<List<List<List<List<List<T>>>>>>>>> list, List<Integer> indices) {
    if(indices.size >= 9) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7), indices.get(8))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get10(List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>> list,
    List<Integer> indices) {
    if(indices.size >= 10) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7), indices.get(8), indices.get(9))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get11(List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>> list,
    List<Integer> indices) {
    if(indices.size >= 11) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get12(List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>> list,
    List<Integer> indices) {
    if(indices.size >= 12) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10), indices.get(11))
    } else {
      throw new IllegalArgumentException("indices list is not long enough")
    }
  }

  def <T extends Object> T get13(List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>> list,
    List<Integer> indices) {
    if(indices.size >= 13) {
      list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
        indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10), indices.get(11),
        indices.get(12))
      } else {
        throw new IllegalArgumentException("indices list is not long enough")
      }
    }

    def <T extends Object> T get14(
      List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>> list,
      List<Integer> indices) {
        if(indices.size >= 14) {
          list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
            indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10), indices.get(11),
            indices.get(12), indices.get(13))
        } else {
          throw new IllegalArgumentException("indices list is not long enough")
        }
      }

      def <T extends Object> T get15(
        List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>> list,
        List<Integer> indices) {
          if(indices.size >= 15) {
            list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
              indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10), indices.get(11),
              indices.get(12), indices.get(13), indices.get(14))
          } else {
            throw new IllegalArgumentException("indices list is not long enough")
          }
        }

        def <T extends Object> T get16(
          List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>>> list,
          List<Integer> indices) {
          if(indices.size >= 16) {
            list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5),
              indices.get(6), indices.get(7), indices.get(8), indices.get(9), indices.get(10), indices.get(11),
              indices.get(12), indices.get(13), indices.get(14), indices.get(15))
          } else {
            throw new IllegalArgumentException("indices list is not long enough")
          }
        }

        def <R, T extends Object> R fold(T list, R accu, (R, T)=>R func) {
          func.apply(accu, list)
        }

        def <R, T extends Object> R fold(List<T> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = func.apply(result, elem)
          }
          result
        }

        def <R, T extends Object> R fold2(List<List<T>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold(result, func)
          }
          result
        }

        def <R, T extends Object> R fold3(List<List<List<T>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold2(result, func)
          }
          result
        }

        def <R, T extends Object> R fold4(List<List<List<List<T>>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold3(result, func)
          }
          result
        }

        def <R, T extends Object> R fold5(List<List<List<List<List<T>>>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold4(result, func)
          }
          result
        }

        def <R, T extends Object> R fold6(List<List<List<List<List<List<T>>>>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold5(result, func)
          }
          result
        }

        def <R, T extends Object> R fold7(List<List<List<List<List<List<List<T>>>>>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold6(result, func)
          }
          result
        }

        def <R, T extends Object> R fold8(List<List<List<List<List<List<List<List<T>>>>>>>> list, R accu,
          (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold7(result, func)
          }
          result
        }

        def <R, T extends Object> R fold9(List<List<List<List<List<List<List<List<List<T>>>>>>>>> list, R accu,
          (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold8(result, func)
          }
          result
        }

        def <R, T extends Object> R fold10(List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>> list, R accu,
          (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold9(result, func)
          }
          result
        }

        def <R, T extends Object> R fold11(List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>> list,
          R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold10(result, func)
          }
          result
        }

        def <R, T extends Object> R fold12(
          List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>> list, R accu, (R, T)=>R func) {
          var R result = accu
          for (elem : list) {
            result = elem.fold11(result, func)
          }
          result
        }

        def <R, T extends Object> R fold13(
          List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>> list, R accu,
          (R, T)=>R func) {
            var R result = accu
            for (elem : list) {
              result = elem.fold12(result, func)
            }
            result
          }

          def <R, T extends Object> R fold14(
            List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>> list, R accu,
            (R, T)=>R func) {
            var R result = accu
            for (elem : list) {
              result = elem.fold13(result, func)
            }
            result
          }

          def <R, T extends Object> R fold15(
            List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>> list, R accu,
            (R, T)=>R func) {
            var R result = accu
            for (elem : list) {
              result = elem.fold14(result, func)
            }
            result
          }

          def <R, T extends Object> R fold16(
            List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>>>>>>>> list,
            R accu, (R, T)=>R func) {
            var R result = accu
            for (elem : list) {
              result = elem.fold15(result, func)
            }
            result
          }
        }
        