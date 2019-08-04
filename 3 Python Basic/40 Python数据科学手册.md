## Python数据科学手册

###  **Ipython**:

1.9 P44(pdf页码，非实际页码)  代码的分析与计时

* %time 对单个语句的执行时间进行计时。

* %timeit 对单个语句的重复执行进行计时，以获得更高的准确度。

* %prun 利用分析器运行代码。

* %lprun 利用逐行分析器运行代码。

* %memit 测量单个语句的内存使用。

* %mprun 通过逐行的内存分析器运行代码。这个魔法函数仅仅 对独立模块内部的函数有效，而对于 Notebook 本身不起作用。所以首先用 %%file 魔法函数创建一个简单的模块，将需测量的函数放里面。

   **说明:最后 4 条魔法命令并不是与 IPython 捆绑的，你需要安装 line_profiler 和 memory_ profiler 扩展。**

 ```
$ pip install line_profiler # 安装失败
$ pip install memory_profiler
%load_ext line_profiler
%load_ext memory_profiler
%lprun? 
 ```


### Numpy

* 不同于 Python 列表，NumPy 要求数组必须包含同一类型的数据。如果类型不匹 配，NumPy 将会向上转换(如果可行)  如：

  ```python
  In [20]: np.array(['1', 2, True])
  Out[20]: array(['1', '2', 'True'], dtype='<U4')
  a = np.array([1,2])
  a.dtype # dtype('int64')
  a[0] = 1.2 #和上面不同，此时为将一个浮点值插入一个整型数组时，浮点值会被截短成整型
  ```

* 如果希望明确设置数组的数据类型，可以用 dtype 关键字

* 不同于 Python 列表，NumPy 数组可以被指定为多维的，内层的列表被当作二维数组的行：

```python
In [21]: np.array([range(i, i + 3) for i in [2, 4, 6]])
Out[21]:
array([[2, 3, 4],
       [4, 5, 6],
       [6, 7, 8]])
```

* `np.full(shape, fill_value, dtype=None, order='C')`

  Return a new array of given shape and type, filled with `fill_value`.

* `np.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None)`

  Return evenly spaced numbers over a specified interval.

  In: `np.linspace(0, 1, 5)`

  Out: `array([ 0.  ,  0.25,  0.5 ,  0.75,  1. ])`

* ` np.random.random(size=None)` :生成[0,1)之间的浮点数,"continuous uniform" distribution

* `np.random.randn(d0,d1,...,dn)`  返回一个或一组样本，具有标准正态分布。

* `np.random.rand(d0,d1,...,dn)` rand函数根据给定维度生成[0,1)之间的数据，包含0，不包含1, uniform distribution

* `np.random.randint(low, high=None, size=None, dtype='l') `

* `np.eye(3)` :3*3的单位矩阵

* ### **np数组的属性**

  * 有 nidm(数组的维度)、shape(数组每个维度的大小)和 size(数组的总大小)属性
  * 另外一个有用的属性是 dtype，它是数组的数据类型

* 数组切片返回的是数组数据的视图，而python数组返回的是数值数据的副本

* 创建数组的副本可通过.copy()方法实现

* 数组的变形

  *  reshape() 函数, 原始数组的大小必须和变形后数组的大小一致

  * 切片操作中利用 newaxis 关键字

    ```python
    In[39]: x = np.array([1, 2, 3])
    		# 通过变形获得的行向量
    		x.reshape((1, 3))
    Out[39]: array([[1, 2, 3]])
    In[40]: # 通过newaxis获得的行向量
        	x[np.newaxis, :]
         	Out[40]: array([[1, 2, 3]])
    In[41]: # 通过变形获得的列向量
        	x.reshape((3, 1))
         	Out[41]: array([[1],
                         	[2],
    						[3]])
    In[42]: # 通过newaxis获得的列向量 
        	x[:, np.newaxis]
         	Out[42]: array([[1],
                         	[2],
                         	[3]])
    ```

* ### **数组拼接和分裂**

  * `concatenate((a1, a2, ...), axis=0, out=None)`

  沿着固定维度处理数组时,使用 np.vstack(垂直栈)和 np.hstack(水平栈)函数会 更简洁

  *  np.vstack

  *  np.hstack

  与拼接相反的过程是分裂。分裂可以通过 `np.split`、`np.hsplit` 、`np.vsplit` 和 `np.dsplit`函数来实现。

  * `np.split(ary, indices_or_sections, axis=0)`

    值得注意的是，N 分裂点会得到 N + 1 个子数组。相关的 np.hsplit 和 np.vsplit 的用法也 类似

    ```python
    x = [1, 2, 3, 99, 99, 3, 2, 1]
    x1, x2, x3 = np.split(x, [3, 5])
    print(x1, x2, x3)
    [1 2 3] [99 99] [3 2 1] 
    ```

* ### **np数组的计算**

  NumPy 中的向量操作是通过通用函数实现的。通用函数的主要目的是对 NumPy 数组中的 值执行更快的**重复**操作。 

  通过通用函数用向量的方式进行计算几乎总比用 Python 循环实现的计算更加有效，尤其是 当数组很大时。只要你看到 Python 脚本中有这样的循环，就应该考虑能否用向量方式替换 这个循环。

  ```python
  In [100]: np.arange(5) / np.arange(1, 6)
  Out[100]: array([0.        , 0.5       , 0.66666667, 0.75      , 0.8       ])
  In [110]: x = 2*  np.arange(9).reshape((3, 3))
  In [111]: x
  Out[111]:
  array([[ 0,  2,  4],
         [ 6,  8, 10],
         [12, 14, 16]])

  x = [1, 2, 3]
  print("e^x =", np.exp(x))
  print("2^x =", np.exp2(x)) #没有np.exp3()
  print("3^x =", np.power(3, x))

  np.log(x) # ln(x)
  np.log2(x)
  np.log10(x) #同样没有log3(),换底吧
  ```

  * **指定输出**:不同于创建 临时数组，你可以用这个特性将计算结果直接写入到你期望的存储位置。所有的通用函数 都可以通过`out` 参数来指定计算结果的存放位置:

    ```python
    In[24]: x = np.arange(5)
            y = np.zeros(10)
            np.power(2, x, out=y[::2])
            print(y) # [ 1.  0.  2.  0.  4.  0.  8.  0. 16.  0.]
     '''如果这里写的是 y[::2] = 2 ** x，那么结果将是创建一个临时数组，该数组存放的是 2 ** x 的结果，并且接下来会将这些值复制到 y 数组中。对于上述例子中比较小的计 算量来说，这两种方式的差别并不大。但是对于较大的数组，通过慎重使用 out 参数 将能够有效节约内存。'''           
    ```

  * **聚合**

    ```python
    x = np.arange(1, 5)
    np.multiply.reduce(x) # 24
    # 如果需要存储每次计算的中间结果，可以使用 accumulate:
    In [4]: np.multiply.accumulate(x)
    Out[4]: array([ 1,  2,  6, 24])
    # np.sum、np.prod、np.cumsum、np.cumprod 也可以实现上面的reduce功能。
    ```

  * **外积**

    ```python
    #任何通用函数都可以用 outer 方法获得两个不同输入数组所有元素对的函数运算结果,如实现一个3*3乘法表
    In [5]: x = np.arange(1, 4)

    In [6]: np.multiply.outer(x, x)
    Out[6]:
    array([[1, 2, 3],
           [2, 4, 6],
           [3, 6, 9]])
    ```

  * **广播**

    ```python
    a = np.arange(3)
    b = np.arange(3)[:, np.newaxis]
    a + b
    Out[5]:
    array([[0, 1, 2],
           [1, 2, 3],
           [2, 3, 4]])
    M = np.ones((3, 2))
    a + M #ValueError: operands could not be broadcast together with shapes (3,) (3,2) 
    ```

    ​

  * **np中的布尔运算符: &、|、^ 和 ~以及与python中的 or and 区别** 

    ```python
    # and 和 or 判断整个对象是真或假，而 & 和 | 是指每个对象中的比特位。
    '对于 NumPy 布尔数组，后者是常用的 操作。'
    In [14]: bool(1 and 0)
    Out[14]: False
        
    In [15]: bin(1)
    Out[15]: '0b1'

    In [16]: bin(0)
    Out[16]: '0b0'

    In [17]: bin(1 & 0) # 1 & 0 的实际操作
    Out[17]: '0b0' # 0
        
    '''当你在 NumPy 中有一个布尔数组时，该数组可以被当作是由比特字符组成的，其中
    1 = True、0 = False。这样的数组可以用上面介绍的方式进行 & 和 | 的操作:'''
    In [25]: A = np.array([1, 0, 1, 0, 1, 0])

    In [26]: A
    Out[26]: array([1, 0, 1, 0, 1, 0])

    In [27]: B = np.array([1, 1, 1, 0, 1, 1])

    In [28]: A | B
    Out[28]: array([1, 1, 1, 0, 1, 1]) # bin()层面的操作

    In [29]: A or B
    ---------------------------------------------------------------------------
    ValueError                                Traceback (most recent call last)
    <ipython-input-29-ea2c97d9d9ee> in <module>()
    ----> 1 A or B

    ValueError: The truth value of an array with more than one element is ambiguous. Use a.any() or a.all()
    # 同样，对给定数组进行逻辑运算时，你也应该使用 | 或 &，而不是 or 或 and:
    (A > 4) and (A < 8) # ValueError 同上
    ```

    ​

  * **将布尔数组作为掩码**

    ```python
    In [9]: c = a + b
        	c
    Out[9]:
    array([[0, 1, 2],
           [1, 2, 3],
           [2, 3, 4]])
    In [11]: c < 2
    Out[11]:
    array([[ True,  True, False],
           [ True, False, False],
           [False, False, False]])
    # 现在为了将这些值从数组中选出，可以进行简单的索引，即掩码操作:
    In [13]: c[c < 2] # 与pd.DataFrame不同。
    Out[13]: array([0, 1, 1]) # 返回的是一个一维数组，它包含了所有满足条件的值
    ```

    ​

  * **索引Fancy Indexing**:传递一个索引数组来一次性获得多个数组元素。

    ```python
    # 利用花哨的索引，结果的形状与索引数组的形状一致，而不是与被索引数组的形状一致:
    In [34]: x = np.random.randint(100, size=10)
    Out[34]: array([73, 53,  6, 21, 45, 26, 90, 38,  7, 31])
    In [38]: ind = np.array([[2, 4],
        ...:                 [3, 5]])
    In [39]: x[ind]
    Out[39]:
    array([[ 6, 45],
           [21, 26]])
    # 对于多维数组:
    In [40]: X = np.arange(12).reshape((3, 4))

    In [41]: X
    Out[41]:
    array([[ 0,  1,  2,  3],
           [ 4,  5,  6,  7],
           [ 8,  9, 10, 11]])
    In [45]: row = np.array([0, 1, 2])

    In [46]: col = np.array([2, 1, 3])
    # 当我们将一个列向 量和一个行向量组合在一个索引中时，会得到一个二维的结果:
    In [48]: [row[:, np.newaxis], col]
    Out[48]:
    [array([[0],
            [1],
            [2]]), array([2, 1, 3])]

    In [49]: X[row[:, np.newaxis], col] #与X[:,[2,1,3]]结果相同
    Out[49]:
    array([[ 2,  1,  3],
           [ 6,  5,  7],
           [10,  9, 11]])
    #花哨的索引返回的值反映的是广播后的索引数组的形状，而不是 被索引的数组的形状。

    '使用花哨索引修改值：'
    # 需注意，操作中重复的索引会导致一些出乎意料的结果产生,如:
    In [74]: x
    Out[74]: array([6., 0., 0., 0., 0., 0., 0., 0., 0., 0.])

    In [77]: x[[0, 0]]
    Out[77]: array([0, 0])

    In [89]: x
    Out[89]: array([6., 0., 0., 0., 0., 0., 0., 0., 0., 0.])
    # 首先赋值 x[0] = 4，然后赋值 x[0] = 6，因此当然 x[0] 的值为 6
    In [90]: i = [2, 3, 3, 4, 4, 4]

    In [91]: x[i]
    Out[91]: array([0., 0., 0., 0., 0., 0.])

    In [92]: x[i] += 1

    In [93]: x
    Out[93]: array([6., 0., 1., 1., 1., 0., 0., 0., 0., 0.])
    #x[i] + 1计算后，这个结果被赋值给了x相应的索引值。记住这个原理后，我们却 发现数组并没有发生多次累加，而是发生了赋值，显然这不是我们希望的结果。
    '如果希望累加，可是使用通用函数中的at()方法：'
    In [94]: x = np.zeros(10)

    In [95]: np.add.at(x, i, 1)

    In [96]: x
    Out[96]: array([0., 0., 1., 2., 3., 0., 0., 0., 0., 0.])
    ```

    ​

  * **数组的排序**

    np.sort的排序算法是快速排序,O[NlogN]

    np.argsort函数返回的是原始数组排好序的索引值

    np排序算法的一个有用的功能是通过 axis 参数，沿着多维数组的行或列进行排序

    * **部分排序:分割** 对应 `np.argpartition`

      ```python
      In [3]: x = np.array([7, 2, 3, 1, 6, 5, 4])

      In [4]: np.partition(x, 3)
      Out[4]: array([2, 1, 3, 4, 6, 5, 7]) # 左3为x中最小的三个值,注意：两个分隔区间中，元素都是任意排列的。
      # 也可以沿着多维数组任意的轴进行分隔:
      np.partition(X, 2, axis=1)
      ```



### Pandas

* 需要注意的是，当使用显式索引(即 data['a':'c'])作切片时，结果包含最后一个索引;而当使用隐式索引(即 data[0:2]) 作切片时，结果不包含最后一个索引。

* **索引器:loc、iloc和ix**

  切片是绝大部分混乱之源。例如，如果你的 Series 是显式整数索引，那么 data[1] 这样的取值操作会使用显式索引，而 data[1:3] 这样的切片操作却会使用隐式索引。

  由于整数索引很容易造成混淆，所以 Pandas 提供了一些索引器(indexer)属性来作为取值 的方法。

  * 第一种索引器是 loc 属性，表示取值和切片都是**显式**的;

  * 第二种是 iloc 属性，表示取值和切片都是 Python 形式的(从0开始，左开右闭)**隐式**索引;

  * 第三种取值属性是 ix，它是前两种索引器的混合形式 #**deprecated**

  另外，避免对用属性形式选择的列直接赋值(即可以用 data['pop'] = z，但不要用data.pop = z)。

    ```python
    In [53]: data = pd.Series(['a', 'b', 'c'], index=[1, 3, 5])

    In [54]: 
    Out[54]:
    1    a
    3    b
    5    c
    dtype: object
    data.loc[1] # 显式  Out[14]: 'a'
    data.iloc[1]# 隐式  Out[16]: 'b'
    ```


   对单个标签**取值**就选择列，而对多个标签用**切片**就选择行

* 多级索引的局部切片 和许多其他相似的操作都要求 **MultiIndex 的各级索引是有序**的(即按照字典顺序由 A 至 Z),所以不少时候需要先`sort_index()`再局部切片

* **groupby**方法:其返回值不是一个 DataFrame 对象，而是一个 DataFrameGroupBy 对象。 这个对象的魔力在于，你可以将它看成是一种特殊形式的 DataFrame，里面隐藏着若干组 数据，但是在没有应用累计函数之前不会计算。这种“延迟计算”(lazy evaluation)的方 法使得大多数常见的累计操作可以通过一种对用户而言几乎是透明的(感觉操作仿佛不存 在)方式非常高效地实现。

* **累积、过滤、转换和应用**

  * **累积aggregate**

    ```python
    df.groupby('key').aggregate(['min', np.median, max])
    # 另一种用法就是通过 Python 字典指定不同列需要累计的函数:
    df.groupby('key').aggregate({'data1': 'min','data2': 'max'})
    ```

  * **过滤filter**

    ```python
    #filter() 函数会返回一个布尔值，表示每个组是否通过过滤
    df.groupby('key').filter(filter_func)
    ```

  * **转换transform**

    ```python
    #累计操作返回的是对组内全量数据缩减过的结果，而转换操作会返回一个新的全量数据。
    df.groupby('key').transform(lambda x: x - x.mean())
    ```

  * **应用apply**

    ```python
    df.groupby('key').apply(norm_by_data2)
    ```

    Two major differences between `apply` and `transform`

    There are two major differences between the `transform` and `apply` groupby methods.

    - `apply` implicitly passes all the columns for each group as a **DataFrame** to the custom function, while `transform` passes each column for each group as a **Series** to the custom function
    - The custom function passed to `apply` can return a scalar, or a Series or DataFrame (or numpy array or even list). The custom function passed to `transform` must return a sequence (a one dimensional Series, array or list) the same length as the group.

    So, `transform` works on just one Series at a time and `apply` works on the entire DataFrame at once.

    ```Python
    test = pd.DataFrame({'id':[1,2,3,1,2,3,1,2,3], 'price':[1,2,3,2,3,1,3,1,2]})
    test
    grouping = test.groupby('id')['price']
    grouping.min()
    grouping.transform(min)
    ```

    ​


* **透视表pivot_table**

  ```python
  >>> table = pivot_table(df, values='D', index=['A', 'B'],
  ...                     columns=['C'], aggfunc=np.sum)
  # 上句等同于:
  table = df.groupby(['A','B','C'])['D'].aggregate('sum').unstack()
  ```

* df.str.get_dummies

* **处理时间序列**

  * Pandas 时间序列工具非常适合用来处理带时间戳的索引数据。

  ```python
  In [52]: data
  Out[52]:
  2014-07-04    0
  2014-08-04    1
  2015-07-04    2
  2015-08-04    3
  dtype: int64
  # 仅在此类 Series 上可用的取值操作:
  In [53]: data['2014']
  Out[53]:
  2014-07-04    0
  2014-08-04    1
  dtype: int64
  ```

  * pd.to_datetime() 函数，它可以解析许多日期与时间格式。对 pd.to_datetime() 传 递一个日期会返回一个 Timestamp 类型，传递一个时间序列会返回一个 DatetimeIndex 类型

    ```python
    In [56]: dates = pd.to_datetime([datetime(2015, 7, 3), 
                                     '4th of July, 2015',                       								 '2015-Jul-6', '07-07-2015', 											 '20150708'])
    In [57]: dates
    Out[57]:
    DatetimeIndex(['2015-07-03', '2015-07-04', '2015-07-06', '2015-07-07',
                   '2015-07-08'],
                  dtype='datetime64[ns]', freq=None)
    ```

  * 任何 DatetimeIndex 类型都可以通过 to_period() 方法和一个频率代码转换成 PeriodIndex
    类型。下面用 'D' 将数据转换成单日的时间序列:

    ```python
    In [58]: dates.to_period('D')
    Out[58]:
    PeriodIndex(['2015-07-03', '2015-07-04', '2015-07-06', '2015-07-07',
                 '2015-07-08'],
                dtype='period[D]', freq='D')
    ```

  * 当用一个日期减去另一个日期时，返回的结果是 TimedeltaIndex 类型:

    ```python
    In [59]: dates - dates[0]
    Out[59]: TimedeltaIndex(['0 days', '1 days', '3 days', '4 days', '5 days'], dtype='timedelta64[ns]', freq=None)
    ```

  * **有规律的时间序列:pd.date_range()**

    ```python
    pd.date_range() 可以 处理时间戳、pd.period_range() 可以处理周期、pd.timedelta_range() 可以处理时间间隔

    ```

  * **高性能Pandas:eval()与query()**

    * 用pandas.eval()实现高性能运算

      (1) 算术运算符。pd.eval() 支持所有的算术运算符

      (2) 比较运算符。pd.eval() 支持所有的比较运算符，包括链式代数式(chained expression)

      (3) 位运算符。pd.eval() 支持 &(与)和 |(或)等位运算符

      (4) 对象属性与索引。pd.eval() 可以通过 obj.attr 语法获取对象属性，通过 obj[index] 语
      法获取对象索引

      (5) 其他运算。目前 pd.eval() 还不支持函数调用、条件语句、循环以及更复杂的运算。如
      果你想要进行这些运算，可以借助 **Numexpr** 来实现。

    * 用DataFrame.eval()实现列间运算

      ```python
      In [63]: df = pd.DataFrame(np.random.rand(1000, 3), columns=['A', 'B', 'C'])

      In [64]: df.head(3)
      Out[64]:
                A         B         C
      0  0.852231  0.668425  0.878697
      1  0.310232  0.742497  0.448540
      2  0.406288  0.549678  0.177804
      # 如果用前面介绍的 pd.eval()，就可以通过下面的代数式计算这三列:
      n [65]: result1 = (df['A'] + df['B']) / (df['C'] - 1)

      In [66]: result2 = pd.eval("(df.A + df.B) / (df.C - 1)")

      In [67]: np.allclose(result1, result2)
      Out[67]: True
      #而 DataFrame.eval() 方法可以通过列名称实现简洁的代数式:
      In [69]: result3 = df.eval('(A + B) / (C - 1)')

      In [70]: np.allclose(result1, result3)
      Out[70]: True
      ```

    * 还可用DataFrame.eval() 创建或修改新的列 

      ```python
      # 用 df.eval() 创建或修改一个新的列 'D'，然后赋给它其他列计算的值
      df.eval('D = (A + B) / C', inplace=True)
      ```

    * DataFrame.eval() 方法还支持通过 @ 符号使用 Python 的局部变量

      ```python
      In [72]: column_mean = df.mean(1)

      In [73]: result1 = df['A'] + column_mean

      In [74]: result2 = df.eval('A + @column_mean')

      In [75]: np.allclose(result1, result2)
      Out[75]: True
      # @ 符号只能在 DataFrame.eval() 方法中使用，而不能在 pandas.eval() 函数中使用
      ```

    * **DataFrame.query()方法**

      ```python
      # 上面的 result2 = pd.eval('df[(df.A < 0.5) & (df.B < 0.5)]')
      # 对于这种过滤运算，你可以用 query() 方法:
      result2 = df.query('A < 0.5 and B < 0.5')
      # query() 方法也支持用 @ 符号引用局部变量:
      df.query('A < @var and B < @var')

      ```

    * 在考虑要不要用这两个函数时，需要思考两个方面:计算时间和内存消耗，而内存消耗是 更重要的影响因素,每个涉及 NumPy 数组或 Pandas 的 DataFrame 的复合代数式都会产生临时数组,如:

      ```python
      In[26]: x = df[(df.A < 0.5) & (df.B < 0.5)]
      #它基本等价于:
      In[27]:  tmp1 = df.A < 0.5
               tmp2 = df.B < 0.5
               tmp3 = tmp1 & tmp2
               x = df[tmp3]
      '以通过下面的方法大概估算一下变量的内存消耗'
      df.values.nbytes
      ```



### Scikit-Learn 

​	机器学习的本质就是借助**数学模型**理解数据。当我们给模型装上可以适应观测数据的可调 参数时，“学习”就开始了;此时的程序被认为具有从数据中“学习”的能力。一旦模型 可以拟合旧的观测数据，那么它们就可以预测并解释新的观测数据。

* **有监督学习**

  是指**对数据的若干特征与若干标签(类型)之间的关联性进行建模**的过程;只要模型被确定，就可应用到新的未知数据上。

  这类学习过程可以进一步分为**分类 (classification)**任务与**回归(regression)**任务。在分类任务中，标签都是离散值;而在回归任务中，标签都是连续值。

* **无监督学习**

  是指**对不带任何标签的数据特征进行建模**，通常被看成是一种“让数据自己介 绍自己”的过程。这类模型包括**聚类(clustering)**任务和**降维(dimensionality reduction)** 任务。聚类算法可以将数据分成不同的组别，而降维算法追求用更简洁的方式表现数据。

* 半监督学习(semi-supervised learning)：通常可以在数据标签不完整时使用

小结

有监督学习:可以训练带标签的数据以预测新数据的标签的模型。

* 分类:可以预测两个或多个离散分类标签的模型。


* 回归:可以预测连续标签的模型。

无监督学习:识别无标签数据结构的模型。

* 聚类: 检测、识别数据显著组别的模型。


* 降维:从高维数据中检测、识别低维数据结构的模型