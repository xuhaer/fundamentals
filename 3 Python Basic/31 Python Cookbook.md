## 第一章:数据结构和算法

### 1.7 字典排序
讨论
**OrderedDict 内部维护着一个根据键插入顺序排序的双向链表**。每次当一个新的 元素插入进来的时候，它会被放到链表的尾部。对于一个已经存在的键的重复赋值不会 改变键的顺序。
需要注意的是，**一个 OrderedDict 的大小是一个普通字典的两倍，因为它内部维护着另外一个链表**。所以如果你要构建一个需要大量 OrderedDict 实例的数据结构的 时候(比如读取 100,000 行 CSV 数据到一个 OrderedDict 列表中去)，那么你就得仔 细权衡一下是否使用 OrderedDict 带来的好处要大过额外内存消耗的影响。

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
* 键视图的一个很少被了解的特性就是它们也支持集合操作，比如 集合并、交、差运算。所以，如果你想对集合的键执行一些普通的集合操作，可以直接 使用键视图对象而不用先将它们转换成一个 set。
* 字典的 items() 方法返回一个包含 (键，值) 对的元素视图对象。这个对象同样也 支持集合操作，并且可以被用来查找两个字典有哪些相同的键值对。
* 尽管字典的 values() 方法也是类似，但是它并不支持这里介绍的集合操作。某种 程度上是因为值视图不能保证所有的值互不相同。

### 1.13 在对字典排序或使用 min、max 时的 key 使用 itemgetter() 会比 lambda 表达式快。
其他需要对不支持原生比较的对象排序的情况见 `6 Sorted.md`。

### 1.18 映射名称到序列元素
collections.namedtuple() 命名元组的一个主要用途是将你的代码从下标操作中解脱出来。因此，如果你从数 据库调用中返回了一个很大的元组列表，通过下标去操作其中的元素，当你在表中添加 了新的列的时候你的代码可能就会出错了。但是如果你使用了命名元组，那么就不会有 这样的顾虑。
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
你需要在数据序列上执行聚集函数(比如 sum() , min() , max() )，但是首先你需 要先转换或者过滤数据。
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

Pyhon 并没有特殊的语法来表示这些特殊的浮点值，但是可以使用 float() 来创 建它们。比如:
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

heapq.merge 可迭代特性意味着它不会立马读取所有序列。这就意味着你可以在 非常长的序列中使用它，而不会有太大的开销。比如，下面是一个例子来演示如何合并两个排序文件(指文件内容的先后顺序，下例则是 file1 在前):
```Python
with open('sorted_file_1', 'r') as file1, \
    open('sorted_file_2', 'r') as file2, \
    open('merged_file', 'w') as outf:
    for line in heapq.merge(file1, file2):
        outf.write(line)
```

有一点要强调的是 heapq.merge() 需要所有输入序列必须是排过序的。特别的， 它并不会预先读取所有数据到堆栈中或者预先排序，也不会对输入做任何的排序检测。 它仅仅是检查所有序列的开始部分并返回最小的那个，这个过程一直会持续直到所有输入序列中的元素都被遍历完。

## 第五章:文件与 IO
