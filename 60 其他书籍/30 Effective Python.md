## Effective Python:59 Specific Ways to Write Better Python

### 第7条：使用列表推导来取代 map 和 filter，但不要使用含有两个以上表达式的列表推导
除非是调用只有一个参数的函数，否则，对于简单的情况来说，列表推导要比内置的 map 函数更清晰。如果使用 map 那就要创建 lambda 函数，这会使代码看起来有些乱。如果还有过滤条件，那么只需要在循环后面加上条件表达式即可，而如果用 map，就得将 filter 与 map 结合起来，代码相对更加晦涩。
当然，在数据量较大的时候，用生成器表达式来改写列表推导是有必要的。

### 第10条：尽量用 enumerate 取代 range

### 第16条：考虑用生成器来改写直接返回列表的函数(注意，迭代器不应该反复被调用)

```Python
def find_words(text):
    """找出 text 中单词首字母的索引"""
    res = []
    if text:
        res.append(0)
    for i, letter in enumerate(text):
        if letter == ' ':
            res.append(i + 1)
    return res

find_words('An apple a day')
```

该函数有两个问题：
* 这段代码写得较拥挤，每次找到结果，都要调用 append 方法，但我们真正该强调的并不是对 res.append 方法的调用，而且那个值。
* 第二个问题是该函数在返回前，要把所有结果放在列表里面，如果信息量很大，那么该函数可能耗费大量内存而浪费资源。

改进:
```Python
def find_words_iter(text):
    if text:
        yield 0
    for i, letter in enumerate(text):
        if letter == ' ':
            yield i + 1
res = find_words_iter('An apple a day')
```

### 第 22 条：尽量使用辅助类来维护程序的状态，而不要用字典和元组

Python 内置的字典类型可以很好地保存某个对象在其生命周期里的动态内部状态。例如{学生：成绩}，如果成绩又得细分为 语文成绩、数学成绩，也可以轻易实现，可以将成绩用 namedtuple 表示即可。 但当其内部状态的很复杂时，尽量将这些代码拆解为多个辅助类。另外，也应该尽量不要使用包含其他字典的字典。


### 第30条：用描述符来改写需要复用的@property 方法
```Python
class Exam:
    def __init__(self):
        self._math_grade = 0
        self._writing_grade = 0

    @property
    def writing_grade(self):
        return self._writing_grade
    
    @writing_grade.setter # @后面第一个参数必须为@property对应的函数名
    def writing_grade(self, value): # 这里函数名定义为 xx,就得使用 e.xx = value
        self._writing_grade = value

    @property
    def math_grade(self):
        return self.__math_grade
    
    @math_grade.setter
    def math_grade(self, value):
        self.__math_grade = value
```
如果再增加些别的成绩也得这样写下去，不够通用。有一种更好的方法来实现上述功能，那就是采用 Python 的描述符(descriptor)来做。

```Python
class Grade:

    def __init__(self):
        self._grade = 0

    def __get__(self, instance, instance_type):
        return self._grade

    def __set__(self, instance, value):
        self._grade = value

class Exam:
    math_grade = Grade()
    writing_grade = Grade()

exam = Exam()
exam.writing_grade = 40
exam1 = Exam()
exam1.writing_grade = 50
print(exam.writing_grade) # 50
print(exam1.writing_grade) # 50
```
不幸的是，对于writing_grade这个类属性来说，所有的 Exam() 实例都要共享同一份 Grade 实例。而表示该属性的那个 Grade 实例，只会在程序的生命周期种构建一次。
为了解决此问题，我们需要把每个 Exam 实例所对应的值记录到 Grade 中。下面这段代码，用字典来保存每个实例的状态。

```Python
class Grade:

    def __init__(self):
        self._grade = {} # 替换为 WeakKeyDictionary()

    def __get__(self, instance, instance_type):
        if instance is None:
            return self
        return self._grade.get(instance, 0)

    def __set__(self, instance, value):
        self._grade[instance] = value

```
上面这种实现方式很简单，而且能够正确运作，但仍有问题，那就是会泄露内存。在程序的生命周期内，对于传给__set__方法的每个 Exam 实例来说，_grade 字典都会保存指向该实例的一份引用，这就导致该实例的引用计数无法降为0，从而使垃圾收集器无法将其回收。
使用 Python 内置的 weakref 模块，即可解决此问题。该模块提供了名为 WeakKeyDictionary 的特殊字典，它可以取代_value 原来所用的普通字典。WeakKeyDictionary 的特殊之处在于：**如果运行期系统发现这种字典所特有的引用，是整个程序里面指向 Exam 实例的最后一份引用(没有指向 Exam 实例的强引用)**，那么，系统就会自动将该实例从字典的键中移除。Python 会做好相关的维护工作，以保证当程序不再使用任何 Exam 实例时，_value 字典会是空的。


### 第38条：在线程种使用 Lock 来防止数据竞争

### 第43条：考虑用 contextlib 和 with 语句来改写可复用的 try/finally 代码

开发者可以用内置的 contextlib 模块来处理自己所编写的对象和函数，使他们能够支持 with 语句。该模块提供了名为 contextmanager 的修饰器。一个简单的函数，只需经过 contextmanager 的修饰，即可用在 with 语句中。
典型用法：

```Python
@contextmanager
def some_generator(<arguments>):
    <setup>
    try:
        yield <value>
    finally:
        <cleanup>

# This makes this:
with some_generator(<arguments>) as <variable>:
    <body>

# equivalent to this:
<setup>
try:
    <variable> = <value>
    <body>
finally:
    <cleanup>
```
例子1：
```Python
import time
from contextlib import contextmanager

@contextmanager
def foo():
    print('entering')
    yield 'sleep 2s'
    print('exiting')


with foo() as a:
    print(a)
    time.sleep(2)


print('the same as below:')

class Bar():

    def __enter__(self):
        print('entering')
        return 'sleep 2s'

    def __exit__(self, exc_ty, exc_val, tb):
        print('exiting')

with Bar() as a:
    print(a)
    time.sleep(2)
```

例子2：
```Python
session = Session()

@contextmanager
def sql_session():
    try:
         # __enter__
        yield session
        # __exit__
        session.commit()
    except Exception as err:
        session.rollback()
        raise err
    finally:
        session.close()
```

### 第47条：在重视精确度的场合，使用decimal
decimal 模块为快速正确舍入的十进制浮点运算提供支持。 它提供了 float 数据类型以外的几个优点：
* 十进制数字可以准确表示。 相比之下，数字如 1.1 和 2.2 在二进制浮点中没有精确的表示。 最终用户通常不希望``1.1 + 2.2``显示为 3.3000000000000003 ，就像二进制浮点一样。
* 精确性延续到算术中。 在十进制浮点数中，0.1 + 0.2  - 0.3 恰好等于零。 在二进制浮点数中，结果为 5.5511151231257827e-017 。 虽然接近于零，但差异妨碍了可靠的相等性检验，并且差异可能会累积。 因此，在具有严格相等不变量的会计应用程序中， decimal 是首选。
* 十进制模块包含一个重要位置的概念，因此 1.30 + 1.20 是 2.50 。 保留尾随零以表示重要性。 这是货币申请的惯常陈述。 对于乘法，“教科书”方法使用被乘数中的所有数字。 例如， 1.3 * 1.2 给出 1.56 而 1.30 * 1.20 给出 1.5600 。
* 与基于硬件的二进制浮点不同，十进制模块具有用户可更改的精度（默认为28个位置)。

例如，打电话，每分钟 0.05 美元的费率，通话5秒。
```Python
from decimal import Decimal
rate = 0.05
seconds = 5
cost = rate * seconds / 60
print(cost)
print(round(cost, 2)) # 由于数值很小，结果为 0.0

rate = Decimal('0.05')
seconds = 5
cost = rate * seconds / 60
print(cost) # 0.00416666....
print(cost.quantize(Decimal('0.01'), rounding='ROUND_UP')) # 0.01
```
Decimal 在精度方面仍有局限，例如 1/3，若想用精度不受限制的方式来表达有理数，可采用 fractions 模块里的 Fraction 类。

