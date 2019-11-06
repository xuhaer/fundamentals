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

-   `dataclass` 类允许对象排序
-   可以表示不可变数据
-   像普通类一样可以继承



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
@dataclass
class AllUser:
    users: List[User] = [User(height) for height in [170, 175]]
# ValueError: mutable default <class 'list'> for field users is not allowed: use default_factory
```

直觉告诉你不能这么做: 不要在Python中使用可变参数作为默认参数。实际上， `dataclass` 类也会阻止你这样做，上面的代码将引发 `ValueError` 。

相反， `dataclass` 类使用称为 `default_factory` 的东西来处理可变的默认值。 要使用 `default_factory` （以及 `dataclass` 类的许多其他很酷的功能），你需要使用 `field()` 说明符：

```python
from dataclasses import dataclass, field
from typing import List

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
        users = ', '.join(f'{u!s}' for u in self.users) # `!s` 显式地使用 str() 
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
  	sort_index: int = field(init=False, repr=False)
    name: str
    height: float
    weight: float = 50.5
    nationality: Any = 'China'
      
    def __post_init__(self):
        self.sort_index = (RANKS.index(self.rank))

User('2', 170) < User('2', 180) # True
```

注意： `sort_index` 作为类的第一个字段添加。这样，才能首先使用 `sort_index` 进行比较，并且只有在还有其他字段的情况时才能生效。使用 `field()` ，还必须指定 `sort_index` 不应作为参数包含在 `__init__()` 方法中(因为它是根据 *rank* 和 *suit* 字段计算的)。为避免让使用者对此实现细节感到困惑，从类的 *repr* 中删除 `sort_index` 可能也是个好主意。



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
    ...
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

