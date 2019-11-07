# Some useful features in Python3.7



## dataclass

该装饰器主要用于数据类(数据类通常是一个主要包含数据的类)，并且`dataclass` 类已实现了某些基本功能:

```python
from dataclasses import dataclass
from typing import Any

@dataclass
class User:
    '''
    	在 dataclass 装饰器下，只需要列出该类中需要的字段，并使用变量注释的特性声明即可；
    	若不想向其添加显式类型，可以使用 typing.Any
    '''
    name: str
    height: float
    weight: float = 50.5
    nationality: Any = 'China'


u = User('name', 170, 50)
print(u) # User(name='name', height=170, weight=50, nationality='China'
u == User('name', 170, 50) # True
```

将 dataclass 其与其他普通类进行比较的话。最基本的普通类看起来像这样：

```python
class User:
    def __init__(self, name, height, weight, nationality='China'):
        self.name = name
        self.height = height
        self.weight = weight
        self.nationality = nationality

u = User('name', 170, 50)
print(u) # <__main__.User object at 0x10f5ccda0>
u == User('name', 170, 50) # False
```

为了初始化一个对象， name 等属性出现了3次。此外，如果你尝试使用这个普通类，你会注意到对象的表示不是很具有描述性，并且会出现上面那种让人困惑的情况。

其实，`dataclass` 类不仅默认实现了`__repr__()`方法用来提供一个比较好的字符串表示方式(`dataclass` 类不实现 `__str__()` 方法，因此Python将返回到 `__repr__()` 方法。)，还实现了`__eq__()`方法以供基本对象之间的比较。此外，还有以下特性:

- `dataclass` 类允许对象排序
- 可以表示不可变数据
- 像普通类一样可以继承



**先说说dataclass 的替代方案**

对于简单的数据结构，你可能会使用tuple、dict或namedtuple，例如：

```python
from collections import namedtuple

UserTuple = namedtuple('User', 'name height weight')
u = UserTuple('name', 170, 50)

PersonTuple = namedtuple('Person', 'name height weight')
p = PersonTuple('name', 170, 50)
p == u # True
```

namedtuple 在简单数据结构是的确不失为一种好的解决方法，但其本质上是一个元组，就会出现上面 `p == u`的"bug"；此外其也有一些限制，比如不能添加默认值，本质上不可变，不够灵活等。

dataclass 的出现不是为了取代上述几种数据结构: 例如，如果你需要的数据结构像元组那样，那么 namedtuple 是一个完美的选择！



再回到dataclass，其本身是一个普通类，当然可以添加任意方法，如:

```python
@dataclass
class User:
    height: float
        
    def bmi(self):
        pass
```



**field()说明符号**

如果我们想基于某个可变类作为默认参数该怎么办呢？你可能想:

```python
from typing import List

@dataclass
class AllUser:
    users: List[User] = [User(height) for height in [170, 175]]
# ValueError: mutable default <class 'list'> for field users is not allowed: use default_factory
```

直觉告诉你不能这么做: 不要在Python中使用可变参数作为默认参数。实际上， `dataclass` 类也会阻止你这样做，上面的代码将引发 `ValueError` 。

相反， `dataclass` 类使用称为 `default_factory` 的东西来处理可变的默认值。 要使用 `default_factory` （以及 `dataclass` 类的许多其他很酷的功能），你需要使用 `field()` 说明符：

```python
from dataclasses import dataclass, field

def make_users():
    return [User(height) for height in [170, 175]]

@dataclass
class AllUser:
    users: List[User] = field(default_factory=make_users)

AllUser() # AllUser(users=[User(height=170), User(height=175)])
AllUser([User(160)]) # AllUser(users=[User(height=160)])
```

`field()` 说明符用于单独自定义 `dataclass` 类的每个字段。下面有一些 `field()` 支持的参数，可以供你作为参考：

- *default* : 字段的默认值(不能同时指定 *default* 和 *default_factory* )
- *default_factory* : 该函数返回字段的初始值
- *init* : 是否在 `__init__()` 方法中使用字段（默认为True。）
- *repr* : 是否在对象的 `repr` 中使用字段（默认为True。）
- *compare* : 是否在比较时包含这个字段（默认为True。）
- *hash* : 在计算 `hash()`  时是否包含该字段（默认值是使用与比较相同的值）
- *metadata* : 包含有关该字段的信息的映射

例如，在上例中，你想自定义某个字段并将其隐藏在`__repr__`中，可以用: 

```python
@dataclass
class User:
    name: str
    weight: float = field(default=50, metadata={'unit': 'kg'})
    height: float = field(default=170, repr=False)

u = User('name')
print(u) # User(name='name', weight=50)
```

可以使用 `fields()` 函数检索 *metadata* (以及关于字段的其他信息)

```python
from dataclasses import fields

fields(u)
fields(u)[1].metadata # mappingproxy({'unit': 'kg'})
fields(u)[1].metadata['unit'] # 'kg'
```

让我们来实现一个用户列表：

```python
@dataclass
class User:
    name: str
    nationality: Any = 'China'
    
    def __str__(self):
        return f'{self.name}-{self.nationality}'

def make_users():
    return [User(str(name)) for name in range(10)]

@dataclass
class AllUser:
    users: List[User] = field(default_factory=make_users)

print(AllUser()) # 又臭又长
```

尽管我们实现了User类的`__str__`方法，上面的结果仍然又臭又长。为此，我们可以添加自己的`__repr__`方法(当然，这里也违反了能够重新创建对象代码的原则)。

```python
@dataclass
class AllUser:
    users: List[User] = field(default_factory=make_users)

    def __repr__(self):
        # 转换符 '!s' 即对结果调用 str()，'!r' 为调用 repr()，而 '!a' 为调用 ascii()。
        users = ', '.join(f'{u!s}' for u in self.users)
        return f'{self.__class__.__name__}({users})'

AllUser() # much better
```



**比较User**

假如我要实现一个User的比较(基于身高) 该怎么做呢？

```python
@dataclass(order=True)
class User:
    name: str
    height: float
    weight: float = 50.5
    nationality: Any = 'China'
   
User('1', 170) < User('2', 180) # True
```

`@dataclass` 装饰器有两种形式。到目前为止，你已经看到了指定 `@dataclass` 的简单形式，没有使用任何括号和参数。但是，你也可以像上边一样，在括号中为 `@dataclass()` 装饰器提供参数。支持的参数如下：

- init:  是否增加 __init__() 方法， (默认是True)
- repr:  是否增加 __repr__() 方法， (默认是True)
- eq:  是否增加 __eq__() 方法， (默认是True)
- order:  是否增加 ordering 方法， (默认是False)
- unsafe_hash:  是否强制添加 __hash__() 方法, (默认是False )
- frozen:  如果为 True ，则分配给字段会引发异常。(默认是False )**可起到类似namedtuple的作用**

`dataclass` 类比较对象时就好像它们是字段的元组一样。比如在该例，类似于：

```python
('1', 170, 50.5. 'China') < ('2', 180, 50.5. 'China')
```

但我此时仅仅想根据其身高排序，那么可以这样做：

```python
@dataclass(order=True)
class User:
    '''仅对身高字段进行排序'''
    name: str = field(compare=False)
    height: float
    weight: float = field(default=50, compare=False)
    nationality: Any = field(default='China', compare=False)

User('3', 170) < User('2', 180) # True

@dataclass(order=True)
class User:
    '''用`__post_init__` 来做更复杂的比较'''
    sort_index: int = field(init=False, repr=False)
    name: str
    height: float
    weight: float = 50
    nationality: Any = 'China'
      
    def __post_init__(self):
        '''根据bmi来比较'''
        self.sort_index = self.weight / (self.height / 100)**2

User('3', 180, 50) < User('2', 170, 50) # True
```

注意： `sort_index` 作为类的第一个字段添加。这样，才能首先使用 `sort_index` 进行比较，并且只有在还有其他字段的情况时才能生效。使用 `field()` ，还必须指定 `sort_index` 不应作为参数包含在 `__init__()` 方法中。为避免让使用者对此实现细节感到困惑，从类的 *repr* 中删除 `sort_index` 可能也是个好主意。



**继承**

我们可以像普通类一样非常自由地子类化 `dataclass` 类，但是，如果基类中的任何字段具有默认值，事情会变得复杂一些：

```python
@dataclass
class User:
    name: str
    nationality: Any = 'China'

@dataclass
class SubUser(User):
    sex: str

# TypeError: non-default argument 'sex' follows default argument
```

错误的原因是`dataclass` 类将尝试编写一个像下面一样的 `__init__()` 方法：

```python
def __init__(name: str, nationality: Any = 'China', sex: str):
    pass
```

所以，**如果基类中的字段具有默认值，那么子类中添加的所有新字段也必须具有默认值。**

另一件需要注意的是字段在子类中的排序方式。 从基类开始，字段按照首次定义的顺序排序。 如果在子类中重新定义字段，则其顺序不会更改。




## breakpoint 函数

在Python3.7中新增了内置的"断点"函数`breakpoint()`,可以使得调试器更加直观和灵活，比如在服务器上完成一些简单的调试工作。

```python
def foo(a, b):
    breakpoint()
    return a / b

foo(1, 0)
```

当脚本运行到 `breakpoint()` 的位置时会中断， 进入一个 PDB 的调试会话。你可以敲 `c` 然后回车使脚本继续。

- `n` (next)
- `s` (step)

如果我们在代码里加上`breakpoint()`后却不想让它在此中断执行呢？ 可以带上新的`PYTHONBREAKPOINT=value` 实现一些特定的功能。

- `PYTHONBREAKPOINT=0` 停止中断执行(相当于忽略`breakpoint()`函数)

- `PYTHONBREAKPOINT=第三方callable`，每次执行到`breakpoint()`时会自动调用第三方的`callable()`。

这样的话，你就可以用pudb(全屏的基于控制台的可视化调试器)、web-pdb(网络浏览器中远程调试 python 脚本)

```python
PYTHONBREAKPOINT=web_pdb.set_trace python ex1.py
```



## 使用importlib.resources 导入数据文件

This module leverages Python’s import system to provide access to *resources* within *packages*. **If you can import a package, you can access resources within that package**. Resources can be opened or read, in either binary or text mode.

在python项目中，以往可能通过类似于`HERE = os.path.dirname(__file__)`这样的方式来定位文件路径，使用 `__file__` 具备了可移植性，但是如果 Python 项目被以一个 zip 文件安装，它就没有 `__file__` 属性了。不过现在我们有更好的处理方式了。

比如一个django项目:

```python
'''
from app1 import somefile 能运行
'''

from importlib import resources

with resources.open_text("app1", "somefile") as f:
    print(f.read())

print(resources.read_text("app1", "somefile"))
```



# Some useful features in Python3.8



## 赋值表达式

新增一个新的赋值语法`:=`，它将赋给左边变量并将赋值语句转换成一个表达式。

```python
if (n := len(a)) > 10:
    print(f"List is too long ({n} elements, expected <= 10)")

# 等价于：
n = len(a)
if n > 10:
    pass

while (block := f.read(256)) != '':
    process(block)
```

另一个值得介绍的用例出现于列表推导式中，在筛选条件中计算一个值，而同一个值又在表达式中需要被使用:

```python
[int(n) for n in ['1', '2', '3'] if (int(n) > 1)] # 需两次计算int(n)
# 现在可以用：
[int_n for n in ['1', '2', '3'] if (int_n := int(n)) > 1]
```



## 仅限位置形参

一般来说，Python中的参数传递有三种形式：位置参数、可变参数和关键字参数，为了避免不必要的麻烦，规定在可变参数之后只允许使用关键字参数。可是即便如此还是给程序员们留下了很大的自由空间，比如在可变参数之前，位置参数和关键字参数的使用几乎不受限制。这样就出现了一个问题，假如一个团队中很多人进行合作开发，函数的定义形式和调用模式是很难规范和统一的。

因此Python3.8就引入了一个“Positional-Only Argument”的概念和分隔符“/”，在分隔符“/”左侧的参数，只允许使用位置参数的形式进行传递。

```python
def foo(a, b, c=1, /, d=100, *, e):
    '''a 和 b 强制位置参数，e 为强制关键字参数'''
    print(a, b, c, d, e)

foo(1, 2, c=2) # TypeError:...
foo(1, 2, e=3) # valid
```

这种标记形式的一个用例是它允许纯 Python 函数完整模拟现有的用 C 代码编写的函数的行为。

另一个用例是在不需要形参名称时排除关键字参数。 

另一个益处是将形参标记为仅限位置形参将允许在未来修改形参名而不会破坏客户的代码。



## 跨进程内存共享

以往跨进程共享得使用Queue、Pipes等方式来实现，数据无法直接共享。

**在Python 3.8中，multiprocessing模块提供了SharedMemory类，可以在不同的Python进程之间创建共享的内存block**。一个简单的例子如下：

打开一个ipython：

```python
from multiprocessing import shared_memory

a = shared_memory.ShareableList([1, 'a'])
a # ShareableList([1, 'a'], name='psm_c71544cf')
```

打开另一个ipython，将上面ShareableList 的 name 复制到下面代码：

```python
from multiprocessing import shared_memory

b = shared_memory.ShareableList(name='psm_c71544cf')
b # ShareableList([1, 'a'], name='psm_c71544cf')
```



## f-string 对`=`的支持

Python3.8对形式为 `f'{expr=}'` 的 f-字符串将扩展表示为表达式文本，加一个等于号，再加表达式的求值结果。可用于自动记录表达式和调试文档。

```python
x = 2
print(f'{x * 2 = }') # x * 2 = 4
```



## importlib.metadata 读取第三方包的元数据

```python
from importlib.metadata import version, files, requires

version('ipython') # '7.9.0'
requires('ipython')[:2] # ['setuptools (>=18.5)', 'jedi (>=0.10)']
```



## functools 中的几点改变

#### 新增缓存属性(`functools.cached_property`):用于在实例生命周期内缓存已计算特征属性。

```python
from functools import cached_property

class Bar:
    
    @cached_property
    def cached_(self):
        print('not cached!')
        return 'some value'

b = Bar()
b.cached_ # print('not cached!')
b.cached_ # not print('not cached!')
```



#### functools.lru_cache 作为装饰器时可以不加参数

​	略



#### functools.singledispatchmethod 装饰器可使用 single dispatch 将方法转换为 泛型函数(参见[笔记](https://github.com/xuhaer/fundamentals/blob/master/60%20%E5%85%B6%E4%BB%96%E4%B9%A6%E7%B1%8D/32%20Fluent%20Python.md#782-%E5%8D%95%E5%88%86%E6%B4%BE%E6%B3%9B%E5%87%BD%E6%95%B0)):

```python
from functools import singledispatchmethod
from contextlib import suppress

class TaskManager:

    def __init__(self, tasks):
        self.tasks = list(tasks)

    @singledispatchmethod
    def discard(self, value):
        with suppress(ValueError):
            self.tasks.remove(value)

    @discard.register(list)
    def _(self, tasks):
        targets = set(tasks)
        self.tasks = [x for x in self.tasks if x not in targets]
```

