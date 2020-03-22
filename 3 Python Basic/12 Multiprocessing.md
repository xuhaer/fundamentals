Python的multiprocessing模块包装了底层的机制，提供了 Queue、Pipes等多种方式来交换数据:

```python
import os
import time
import queue
from multiprocessing import Process, Queue

def t1(q):
    q.put(os.getpid())
    time.sleep(2)
    print(f'my id is {os.getpid()}')

def t2(q):
    s = q.get()
    time.sleep(2)
    print(f'my id is {os.getpid()},my sibings is:{s}')

q = Queue()
p1 = Process(target=t1, args=(q,))
p2 = Process(target=t2, args=(q,))
p1.start()
p2.start()
p1.join()
p2.join()
p1.close()
p2.close()
```

通过往Queue实例中 put 数据和 get 数据从而达到交换数据。

结果:

```python
my id is 82360
my id is 82361,my sibings is:82360
```

## Pool 类

在使用Python进行系统管理时，特别是同时操作多个文件目录或者远程控制多台主机，并行操作可以节约大量的时间。如果操作的对象数目不大时，还可以直接使用Process类动态的生成多个进程，十几个还好，但是如果上百个甚至更多，那手动去限制进程数量就显得特别的繁琐，此时进程池就派上用场了。 

**Pool类可以提供`指定数量的进程`供用户调用，当有新的请求提交到Pool中时，如果池还没有满，就会创建一个新的`进程`来执行请求。如果池满，请求就会告知先等待，直到池中有进程结束，才会创建新的进程来执行这些请求。 **

Pool类的几个方法:

* `apply_async(func[, args=()[, kwargs={}]])`: 非阻塞、支持结果返回进行回调
* ` map(func, iterable[, chunksize=None])`: 与内置的map函数用法行为基本一致，它会使进程阻塞直到返回结果。注意，虽然第二个参数是一个迭代器，但在实际使用中，必须在整个队列都就绪后，程序才会运行子进程。
* `close()`:关闭进程池（pool），使其不在接受新的任务。
* `terminate()`: 结束工作进程，不在处理未处理的任务。
* `join()`: 主进程阻塞等待子进程的退出，join方法必须在close或terminate之后使用。

```python
import time
from multiprocessing import Pool

def task(n):
    time.sleep(1)
    return n * 2

def main(x):
    a = time.time()
    pool = Pool(x) # Pool的默认大小是CPU的线程数
    # 如果池满，请求就会等待，直到池中有进程结束，才会创建新的进程来执行这些请求。 
    # 比如当池的大小为4而range(5)的时候
    pool.map(task, range(5))
    print(f'Pool 池指定数量:{x}, 用时{time.time() - a }')

main(4)
main(5)
main(10)
```

结果:

```python
Pool 池指定数量:4, 用时2.052304267883301
Pool 池指定数量:5, 用时1.0146291255950928
Pool 池指定数量:10, 用时1.0229480266571045
```



与`apply_async`对比:

```python
import time
import subprocess
from multiprocessing import Pool

def task(n):
    time.sleep(1)
    return n

def main(x):
    a = time.time()
    pool = Pool(x)
    ress = [pool.apply_async(task, args=(i, )) for i in range(5)]
    print([res.get() for res in ress])
    pool.close()
    pool.join()
    print(f'Pool 池指定数量:{x}, 用时{time.time() - a }')

main(4)
main(5)
main(10)
```

结果:

```python
[0, 1, 2, 3, 4]
Pool 池指定数量:4, 用时2.114387035369873
[0, 1, 2, 3, 4]
Pool 池指定数量:5, 用时1.0569658279418945
[0, 1, 2, 3, 4]
Pool 池指定数量:10, 用时1.0654759407043457
```

map 与 apply_async 有以下区别：

* `map()` 放入迭代参数，一次可以完成多个任务，返回多个结果
* `apply_async()`一次只能完成一项任务果，如果想得到map()的效果需要通过迭代

如果不需要拿到值:

```python
import time
import subprocess
from multiprocessing import Pool

def task(n):
    time.sleep(1)
    subprocess.call(['echo', n])

def main(x):
    a = time.time()
    pool = Pool(x)
    pool.map(task, '12345')
    print(f'Pool 池指定数量:{x}, 用时{time.time() - a }')

main(4)
```

```python
2
1
4
3 # 这里打印3后会停顿一秒
5
Pool 池指定数量:4, 用时2.044571876525879
```



```python
import time
import subprocess
from multiprocessing import Pool

def task(n):
    time.sleep(1)
    subprocess.call(['echo', n])

def main(x):
    a = time.time()
    pool = Pool(x)
    [pool.apply_async(task, args=(f'{i}', )) for i in range(5)]
    pool.close()
    pool.join()
    print(f'Pool 池指定数量:{x}, 用时{time.time() - a }')

main(4)
```

结果:

```python
0
3
2
1 # 这里打印1后会停顿一秒
4
Pool 池指定数量:4, 用时2.1025390625
```

