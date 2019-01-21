单例是一种**设计模式**，应用该模式的类只会生成一个实例。

单例模式保证了在程序的不同位置都**可以且仅可以取到同一个对象实例**：如果实例不存在，会创建一个实例；如果已存在就会返回这个实例。因为单例是一个类，所以你也可以为其提供相应的操作方法，以便于对这个实例进行管理。



## 使用函数装饰器实现单例

```python
def singleton(cls):
    _instance = {}

    def inner():
        if cls not in _instance:
            _instance[cls] = cls()
        return _instance[cls]
    return inner

@singleton
class Cls:
    def __init__(self):
        pass

cls1 = Cls()
cls2 = Cls()
print(cls1 is cls2) # True
```

该方法使用不可变的**类地址**作为键，其实例作为值，每次创造实例时，首先查看该类是否存在实例，存在的话直接返回该实例即可，否则新建一个实例并存放在字典中。

## 使用类装饰器实现单例

```python
class Singleton:
    def __init__(self, cls):
        self._cls = cls
        self._instance = {}

    def __call__(self):
        if self._cls not in self._instance:
            self._instance[self._cls] = self._cls()
        return self._instance[self._cls]

@Singleton
class Cls2:
    def __init__(self):
        pass

cls1 = Cls2()
cls2 = Cls2()
print(cls1 is cls2) # True
```

## `__new__` 关键字(推荐)

使用 __new__ 方法在创造实例时进行干预，达到实现单例模式的目的。

```python
import threading

class Single(object):
    _instance_lock = threading.Lock()
    _instance = None
    
    def __new__(cls, *args, **kw):
        if cls._instance is None:
            with cls._instance_lock:
                if cls._instance is None:
            		cls._instance = object.__new__(cls, *args, **kw)
        return cls._instance

    def __init__(self):
        pass

single1 = Single()
single2 = Single()
print(single1 is single2) # True
```

## 使用模块

其实，**Python 的模块就是天然的单例模式**，因为模块在第一次导入时，会生成 .pyc 文件，当第二次导入时，就会直接加载 .pyc 文件，而不会再次执行模块代码。因此，我们只需把相关的函数和数据定义在一个模块中，就可以获得一个单例对象了。如果我们真的想要一个单例类，可以考虑这样做：

```python
#mysingleton.py
class Singleton(object):
    def foo(self):
        pass
singleton = Singleton()
```

将上面的代码保存在文件 mysingleton.py 中，要使用时，直接在其他文件中导入此文件中的对象，这个对象即是单例模式的对象

```python
from mysingleton import singleton
```

