## Python 拷贝

* 赋值：简单地拷贝对象的引用，两个对象的id相同。

* 浅拷贝：创建一个新的组合对象，这个新对象与原对象共享内存中的**子对象**。

* 深拷贝：创建一个新的组合对象，同时递归地拷贝所有子对象，新的组合对象与原对象没有任何关联。虽然实际上会共享不可变的子对象，但不影响它们的相互独立性。

* 浅拷贝和深拷贝的不同仅仅是对组合对象来说，所谓的组合对象就是包含了其它对象的对象，如列表，类实例。而对于数字、字符串、元组以及其它“原子”类型，没有拷贝一说，产生的都是原对象的引用。

  ```python
  import copy

  a = [1, 2, 3]
  b = [4, 5, 6]
  c = [a, b]
  cc = (a, b)

  e = copy.deepcopy(c)
  ee = copy.deepcopy(cc)

  assert id(e) != id(c)
  assert id(e) != id(cc)
  assert id(c[0]) == id(a)
  assert id(e[0]) != id(a)

  a.append(4)
  assert c == [[1, 2, 3, 4], [4, 5, 6]]
  assert e == [[1, 2, 3], [4, 5, 6]]
  ```

  ​

对于可变对象:

```python
import copy

a = [1, 2]
b = [2, 3]
c = [a, b]

e = copy.copy(c) #相当于只会'深'拷贝一层,e指向一个新的列表,但新列表中的a,b并非深拷贝
assert id(e) != id(c)
assert id(e[0]) == id(c[0])

a.append(3)
assert id(c[0]) == id(e[0])
```

对于不可变对象:copy.copy 相当于赋值

```python
import copy

a = [1, 2]
b = [2, 3]
c = (a, b)
e = copy.copy(c) # 元组不可变性,copy.copy相当于是个引用
assert id(e) == id(c)
a.append(3)
assert id(c) == id(e)
```

