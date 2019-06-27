## 第一章:数据结构和算法

### 1.7 字典排序
讨论
**OrderedDict 内部维护着一个根据键插入顺序排序的双向链表**。每次当一个新的元素插入进来的时候，它会被放到链表的尾部。对于一个已经存在的键的重复赋值不会改变键的顺序。
需要注意的是，**一个 OrderedDict 的大小是一个普通字典的两倍，因为它内部维护着另外一个链表**。所以如果你要构建一个需要大量 OrderedDict 实例的数据结构的 时候(比如读取 100,000 行 CSV 数据到一个 OrderedDict 列表中去)，那么你就得仔细权衡一下是否使用 OrderedDict 带来的好处要大过额外内存消耗的影响。

### 1.8 在比较多个序列、涉及字典的值比较、排序等问题时优先考虑使用 zip

* 选出两个列表中对应较大的值：
```Python
a = [2, 5, 8 ,2 ,7]
b = [3, 6, 4, 8, 5]

In [119]: %timeit list(map(lambda pair: max(pair), zip(a, b)))
2.44 µs ± 53.3 ns per loop (mean ± std. dev. of 7 runs, 100000 loops each)

In [121]: %timeit [max(ai,bi) for ai, bi in zip(a,b)]
1.98 µs ± 71.5 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)

In [120]: %timeit [max(pair) for pair in zip(a,b)] # 优选
1.91 µs ± 40.7 ns per loop (mean ± std. dev. of 7 runs, 100000 loops each)

In [122]: %timeit list(map(max, zip(a,b)))
1.77 µs ± 125 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

* 选出某字典最大的值(往往需要保留键的信息)：
```Python
a = {'b': 1, 'c': 2, 'a': 3}

In [163]: %timeit min(a.items(), key=lambda k: k[1])
1.12 µs ± 60.8 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)

In [164]: %timeit min(a, key=lambda k: a[k])
925 ns ± 5.16 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)

In [162]: %timeit min(zip(a.values(), a.keys())) # 优选
870 ns ± 13.2 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)

In [161]: %timeit min(a, key=a.get) # 优选
687 ns ± 8.63 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```
需要注意的是在计算操作中使用到了 (值，键) 对。当多个实体拥有相同的值的时候，键会决定返回结果。比如，在执行 min() 和 max() 操作的时候，如果恰巧最小或最大值有重复的，那么拥有最小或最大键的实体会返回。

### 1.9 查找两字典的相同点(相同的键或值)

```Python
a = {
    'x' : 1,
    'y' : 2,
    'z' : 3
}
b = {
    'w' : 10,
    'x' : 11,
    'y' : 2
}
a.keys() & b.keys() # { 'x', 'y' }  慢于 `{k for k in b if k in a}`
a.keys() - b.keys() # { 'z' }
a.items() & b.items() # { ('y', 2) } 快于 `{item for item in b.items() if item in a.items()}`
```
* 键视图的一个很少被了解的特性就是它们也支持集合操作，比如 集合并、交、差运算。所以，如果你想对集合的键执行一些普通的集合操作，可以直接使用键视图对象而不用先将它们转换成一个 set。
* 字典的 items() 方法返回一个包含 (键，值) 对的元素视图对象。这个对象同样也支持集合操作，并且可以被用来查找两个字典有哪些相同的键值对。
* 尽管字典的 values() 方法也是类似，但是它并不支持这里介绍的集合操作。某种 程度上是因为值视图不能保证所有的值互不相同。

### 1.13 在对字典排序或使用 min、max 时的 key 使用 itemgetter() 会比 lambda 表达式快。
其他需要对不支持原生比较的对象排序的情况见 `6 Sorted.md`。

### 1.18 映射名称到序列元素
collections.namedtuple() 命名元组的一个主要用途是将你的代码从下标操作中解脱出来。因此，如果你从数据库调用中返回了一个很大的元组列表，通过下标去操作其中的元素，当你在表中添加了新的列的时候你的代码可能就会出错了。但是如果你使用了命名元组，那么就不会有这样的顾虑。
命名元组另一个用途就是作为字典的替代，因为字典存储需要更多的内存空间。如果你需要构建一个非常大的包含字典的数据结构，那么使用命名元组会更加高效。但是需要注意的是，不像字典那样，一个命名元组是不可更改的。
如果你真的需要改变属性的值，那么可以使用命名元组实例的 _replace() 方法， 它会创建一个全新的命名元组并将对应的字段用新的值取代。

```Python
from collections import namedtuple

Stock = namedtuple('Stock', ['name', 'shares', 'price'])
s = Stock('ACME', 100, 123.45)
s.shares = 75 # AttributeError: can't set attribute
s = s._replace(shares=75)
```

### 1.19 转换并同时计算数据
你需要在数据序列上执行聚集函数(比如 sum() , min() , max() )，但是首先你需要先转换或者过滤数据。
使用一个生成器表达式作为参数会比先创建一个临时列表更加高效和优雅,此外后者会先创建一个额外的列表。对于小型列表可能没什么关系，但是如果元素数量非常大的时候，它会创建一个巨大的仅仅被使用一次就被丢弃的临时数据结构。而生成器方案会以迭代的方式转换数据，因此更省内存(生成器表达式会比列表推导式慢一点点)。

```Python
In [205]: %timeit sum([x * x for x in a])
723 ns ± 7.79 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)

In [206]: %timeit sum(x * x for x in a) # 不需要写成 `sum((x * x for x in nums))`
827 ns ± 1.5 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

### 1.20 合并多个字典或映射
现在有多个字典或者映射，你想将它们从逻辑上合并为一个单一的映射后执行某些操作，比如查找值或者检查某些键是否存在。
a = {'x': 1, 'z': 3 }
b = {'y': 2, 'z': 4 }
```Python
from collections import ChainMap

c = ChainMap(a,b)
print(c['x']) # Outputs 1 (from a)
print(c['y']) # Outputs 2 (from b)
print(c['z']) # Outputs 3 (from a) 重复键，那么第一次出现的映射值会被返回
```
一个 ChainMap 接受多个字典并将它们在逻辑上变为一个字典(与 `a.update(b)` 不同)，ChainMap 类只是在内部创建了一个容纳这些字典的列表,并重新定义了一些常见的字典操作来遍历这个列表， 因此当 a、b 有更新时，c 也会即使更新。
对于字典的更新或删除操作总是影响的是列表中第一个字典。比如:
```Python
c['z'] = 33
print(c) # ChainMap({'x': 1, 'z': 33}, {'y': 2, 'z': 4})
print(a) # {'x': 1, 'z': 33}
print(b) # {'y': 2, 'z': 4}
del c['z']
```

## 第二章:字符串和文本

### 3.7 无穷大与 NaN

Pyhon 并没有特殊的语法来表示这些特殊的浮点值，但是可以使用 float() 来创建它们。比如:
```Python
a = float('-inf')
b = float('nan')

# 检测
import math

math.isinf(a) # True
math.isnan(b) # True
```
但其在比较和操作符相关的时候需要特别注意:
```Python
float('-inf') + 45 # -inf
10 / float('-inf') # -0.0
float('-inf') / float('-inf') # nan
float('-inf') + float('inf') # nan
# NaN 值一个特殊的地方是它们之间的比较操作总是返回 False。比如:
float('nan') == float('nan') # False
# 因此，测试 NaN 值的安全的方法就是 math.isnan()或 numpy(np.isnan())、pandas(pd.isna()),
```

## 第四章：迭代器与生成器

### 4.14 展开嵌套的序列
可以写一个包含 yield from 语句的递归生成器来轻松解决这个问题:
```Python
from collections import Iterable


def flatten(items, ignore_types=(str, bytes)):
    for x in items:
        if isinstance(x, Iterable) and not isinstance(x, ignore_types):
            yield from flatten(x)
        else:
            yield x

items = [1, 2, [3, 4, [5, 6], 7], 8]
# Produces 1 2 3 4 5 6 7 8
list(flatten(items))
```
语句 yield from 在你想在生成器中调用其他生成器的值的时候非常有用。 如果你不使用它的话，那么就必须写额外的 for 循环。比如:
```Python
def flatten(items, ignore_types=(str, bytes)):
    for x in items:
        if isinstance(x, Iterable) and not isinstance(x, ignore_types):
            for i in flatten(x):
                yield i
        else:
            yield x
```

### 4.15 顺序迭代合并后的排序迭代对象
你有一系列排序序列，想将它们合并后得到一个排序序列并在上面迭代遍历。
```Python
import heapq

a = [1, 4, 7, 10]
b = [2, 5, 6, 11]

list(heapq.merge(a, b)) # [1, 2, 4, 5, 6, 7, 10, 11]
```

heapq.merge 可迭代特性意味着它不会立马读取所有序列。这就意味着你可以在非常长的序列中使用它，而不会有太大的开销。比如，下面是一个例子来演示如何合并两个排序文件(指文件内容的先后顺序，下例则是 file1 在前):
```Python
with open('sorted_file_1', 'r') as file1, \
    open('sorted_file_2', 'r') as file2, \
    open('merged_file', 'w') as outf:
    for line in heapq.merge(file1, file2):
        outf.write(line)
```

有一点要强调的是 heapq.merge() 需要所有输入序列必须是排过序的。特别的， 它并不会预先读取所有数据到堆栈中或者预先排序，也不会对输入做任何的排序检测。 它仅仅是检查所有序列的开始部分并返回最小的那个，这个过程一直会持续直到所有输入序列中的元素都被遍历完。

## 第八章: 类与对象

### 8.4 创建大量对象时节省内存方法

对于主要是用来当成简单的数据结构的类而言，你可以通过给类添加 __slots__ 属性来极大的减少实例所占的内存。比如:

```Python
class Date:
    __slots__ = ['year', 'month', 'day']
    def __init__(self, year, month, day):
        self.year = year
        self.month = month
        self.day = day
```
当你定义 __slots__ 后，Python 就会为实例使用一种更加紧凑的内部表示。实例通过一个很小的固定大小的数组来构建，而不是为每个实例定义一个字典，这跟元组或列表很类似。在 __slots__ 中列出的属性名在内部被映射到这个数组的指定小标上。使用 slots 一个不好的地方就是我们不能再给实例添加新的属性了，只能使用在 __slots__ 中定义的那些属性名。

使用 slots 后节省的内存会跟存储属性的数量和类型有关。不过，一般来讲，使用 到的内存总量和将数据存储在一个元组中差不多。为了给你一个直观认识，假设你不使用 slots 直接存储一个 Date 实例，在 64 位的 Python 上面要占用 428 字节，而如果使用了 slots，内存占用下降到 156 字节。如果程序中需要同时创建大量的日期实例，那么这个就能极大的减小内存使用量了。

关于 __slots__ 的一个常见误区是它可以作为一个封装工具来防止用户给实例增 加新的属性。尽管使用 slots 可以达到这样的目的，但是这个并不是它的初衷。__slots__ 更多的是用来作为一个内存优化工具。


### 8.24 让类支持比较操作

你想让某个类的实例支持标准的比较运算 (比如 >=,!=,<=,< 等)，但是又不想去实现那一大堆的特殊方法。

Python 类对每个比较操作都需要实现一个特殊方法来支持。例如为了支持 >= 操 作符，你需要定义一个 __ge__() 方法。尽管定义一个方法没什么问题，但如果要你实 现所有可能的比较方法那就有点烦人了。

装饰器 functools.total_ordering 就是用来简化这个处理的。使用它来装饰一个 来，你只需定义一个 __eq__() 方法，外加其他方法 (__lt__, __le__, __gt__, or __ge__) 中的一个即可。然后装饰器会自动为你填充其它比较方法。

```Python
from functools import total_ordering

class Room:
    def __init__(self, name, length, width):
        self.name = name
        self.length = length
        self.width = width
        self.square_feet = self.length * self.width

@total_ordering
class House:
    def __init__(self, name, style):
        self.name = name
        self.style = style
        self.rooms = list()

    @property
    def living_space_footage(self):
        return sum(r.square_feet for r in self.rooms)

    def add_room(self, room):
        self.rooms.append(room)

    def __eq__(self, other):
        return self.living_space_footage == other.living_space_footage

    def __lt__(self, other):
        return self.living_space_footage < other.living_space_footage
```


### 8.25 创建缓存实例

一个 WeakValueDictionary 实例只会保存那些在其它地方还在被使用的实例。 否则的话，只要实例不再被使用了，它就从字典中被移除了。

```Python
import weakref

class CachedSpamManager:
    def __init__(self):
        self._cache = weakref.WeakValueDictionary()

    def get_spam(self, name):
        if name not in self._cache:
            s = Spam(name)
            self._cache[name] = s
        else:
            s = self._cache[name]
        return s

    def clear(self):
        self._cache.clear()
    
class Spam:
    manager = CachedSpamManager()
    def __init__(self, name):
        self.name = name
    
    def get_spam(name):
        return Spam.manager.get_spam(name)
```
但是，我们暴露了类的实例化给用户，用户很容易去直接实例化这个类， 而不是使用工厂方法，如
```Python
>>> a = Spam('foo')
>>> b = Spam('foo')
>>> a is b
False
```
有几种方式可以防止用户这样做，第一个是将类的名字修改为以下划线 (_) 开头， 提示用户别直接调用它。第二种就是让这个类的 __init__() 方法抛出一个异常，让它不能被初始化:
```Python
class CachedSpamManager2:
    def __init__(self):
        self._cache = weakref.WeakValueDictionary()

    def get_spam(self, name):
        if name not in self._cache:
            temp = Spam3._new(name) # Modified creation
            self._cache[name] = temp
        else:
            temp = self._cache[name]
        return temp

    def clear(self):
        self._cache.clear()

class Spam3:
    manager = CachedSpamManager()

    def __init__(self, *args, **kwargs):
        raise RuntimeError("Can't instantiate directly")
    
    # Alternate constructor
    @classmethod
    def _new(cls, name):
        self = cls.__new__(cls)
        self.name = name
        return self

    def get_spam(name):
        return Spam.manager.get_spam(name)

```

### 9.3 解除一个装饰器

一个装饰器已经作用在一个函数上，你想撤销它，直接访问原始的未包装的那个函 数。
假设装饰器是通过 @wraps (参考 9.2 小节) 来实现的，那么你可以通过访问 __wrapped__ 属性来访问原始函数:

```Python
@somedecorator
def add(x, y):
    return x + y

orig_add = add.__wrapped__
orig_add(3, 4)
```
最后要说的是，并不是所有的装饰器都使用了 @wraps ，因此这里的方案并不全部 适用。特别的，内置的装饰器 @staticmethod 和 @classmethod 就没有遵循这个约定 (它们把原始函数存储在属性 __func__ 中)。


### 12.4 给关键部分加锁

要在多线程程序中安全使用可变对象，你需要使用 threading 库中的 Lock 对象， 就像下边这个例子这样:

```Python
import threading

class SharedCounter:
    '''A counter object that can be shared by multiple threads. '''
    def __init__(self, initial_value = 0):
        self._value = initial_value
        self._value_lock = threading.Lock()

    def incr(self,delta=1):
        '''Increment the counter with locking '''
        with self._value_lock:
                self._value += delta

    def decr(self,delta=1): 
        '''Decrement the counter with locking '''
        with self._value_lock:
            self._value -= delta
```
with 语句会在这个代码块执行前自动获取锁，在执行 结束后自动释放锁。

### 12.5 防止死锁的加锁机制

在多线程程序中，死锁问题很大一部分是由于线程同时获取多个锁造成的。举个例 子:一个线程获取了第一个锁，然后在获取第二个锁的时候发生阻塞，那么这个线程就 可能阻塞其他线程的执行，从而导致整个程序假死。解决死锁问题的一种方案是为程序 中的每一个锁分配一个唯一的 id，然后只允许按照升序规则来使用多个锁，这个规则 使用上下文管理器是非常容易实现的，示例如下:
```Python
import threading
from contextlib import contextmanager

# Thread-local state to stored information on locks already acquired
_local = threading.local()

@contextmanager
def acquire(*locks):
   # Sort locks by object identifier
    locks = sorted(locks, key=lambda x: id(x))
    
    # Make sure lock order of previously acquired locks is not violated
    acquired = getattr(_local,'acquired',[])
    if acquired and max(id(lock) for lock in acquired) >= id(locks[0]):
        raise RuntimeError('Lock Order Violation')

    # Acquire all of the locks
    acquired.extend(locks)
    _local.acquired = acquired

    try:
        for lock in locks:
            lock.acquire()
        yield
    finally:
        # Release locks in reverse order of acquisition 
        for lock in reversed(locks):
            lock.release()
        del acquired[-len(locks):]
```

如何使用这个上下文管理器呢?你可以按照正常途径创建一个锁对象，但不论是 单个锁还是多个锁中都使用 acquire() 函数来申请锁，示例如下:
```Python
x_lock = threading.Lock()
y_lock = threading.Lock()
def thread_1():
    while True:
        with acquire(x_lock, y_lock):
            print('Thread-1')

def thread_2():
    while True:
        with acquire(y_lock, x_lock):
            print('Thread-2')

t1 = threading.Thread(target=thread_1)
t1.daemon = True
t1.start()

t2 = threading.Thread(target=thread_2)
t2.daemon = True
t2.start()
```
如果你执行这段代码，你会发现它即使在不同的函数中以不同的顺序获取锁也没 有发生死锁。其关键在于，在第一段代码中，我们对这些锁进行了排序。通过排序，使 得不管用户以什么样的顺序来请求锁，这些锁都会按照固定的顺序被获取。

死锁是每一个多线程程序都会面临的一个问题(就像它是每一本操作系统课本的 共同话题一样)。根据经验来讲，尽可能保证每一个线程只能同时保持一个锁，这样程 序就不会被死锁问题所困扰。一旦有线程同时申请多个锁，一切就不可预料了。

死锁的检测与恢复是一个几乎没有优雅的解决方案的扩展话题。一个比较常用的 死锁检测与恢复的方案是引入看门狗计数器。当线程正常运行的时候会每隔一段时间 重置计数器，在没有发生死锁的情况下，一切都正常进行。一旦发生死锁，由于无法重 置计数器导致定时器超时，这时程序会通过重启自身恢复到正常状态。

避免死锁是另外一种解决死锁问题的方式，在进程获取锁的时候会严格按照对象 id 升序排列获取，经过数学证明，这样保证程序不会进入死锁状态。证明就留给读者作 为练习了。避免死锁的主要思想是，单纯地按照对象 id 递增的顺序加锁不会产生循环 依赖，而循环依赖是死锁的一个必要条件，从而避免程序进入死锁状态。


