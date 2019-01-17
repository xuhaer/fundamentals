## Func Params

```python
def add_end(a, L=[1]):
    L.append('END')
    return a, L

add_end(1) # (1, [1, 'END'])
add_end(1) # (1, [1, 'END', 'END'])
```

**定义默认参数要牢记一点：默认参数必须指向不变对象！**



## Named Keyword Arguments

命名关键字参数需要一个特殊分隔符*，*后面的参数被视为命名关键字参数。

命名关键字参数必须传入参数名，这和位置参数不同。如果没有传入参数名，调用将报错。

```python
def person(name, *, age, job):
    print(name, age, job)

person('Jack', age=23, job='Engineer')# Jack 23 Engineer
```

如果函数定义中已经有了一个可变参数，后面跟着的命名关键字参数就不再需要一个特殊分隔符`*`了：

```python
def person(name, age, *args, job):
    print(name, age, args, job)
person('Jack', 24, 'Beijing', job='Engineer')# Jack 24 ('Beijing',) Engineer
```

命名关键字参数可以有缺省值，从而简化调用：

```python
def person(name, *, age=23,job):
    print(name, age, job)
person('Jack', job='Engineer')# Jack 23 Engineer

```

参数组合:

```python
def f1(a, b, c=0, *args, **kw):
    print('a =', a, 'b =', b, 'c =', c, 'args =', args, 'kw =', kw)

def f2(a, b, c=0, *, d, **kw):
    print('a =', a, 'b =', b, 'c =', c, 'd =', d, 'kw =', kw)
    

args = (1, 2, 3, 4)
kw = {'d': 99, 'x': '#'}
f1(*args, **kw) # a = 1 b = 2 c = 3 args = (4,) kw = {'d': 99, 'x': '#'}

args = (1, 2, 3)
kw = {'d': 88, 'x': '#'}
f2(*args, **kw) # a = 1 b = 2 c = 3 d = 88 kw = {'x': '#'}
```

