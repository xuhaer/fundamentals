## threading

多任务可以由多进程完成，也可以由一个进程内的多线程完成。

```python
import time
import threading

def loop():
    cur = threading.current_thread().name
    print(f'    thread {cur} is running...')
    n = 0
    while n < 3:
        n += 1
        print(f'    thread {cur} >>> {n}')
        time.sleep(2)
    print(f'    thread {cur} ended')

cur = threading.current_thread().name
print(f'thread {cur} is running...')
t = threading.Thread(target=loop, name='LoopThread')
t.start()
t.join()
print(f'thread {cur} ended')
```

结果:

```python
thread MainThread is running...
    thread LoopThread is running...
    thread LoopThread >>> 1
    thread LoopThread >>> 2
    thread LoopThread >>> 3
    thread LoopThread ended
thread MainThread ended
```

任何进程默认就会启动一个线程，我们把该线程称为**主线程**，主线程又可以启动新的线程，Python的threading模块有个`current_thread()`函数，它永远返回当前线程的实例。主线程实例的名字叫MainThread，子线程的名字在创建时指定，如果不起名字Python就自动给线程命名为Thread- 1，Thread-2......



## lock

多线程和多进程最大的不同在于，多进程中，同一个变量，各自有一份拷贝存在于每个进程中，互不影响，而**多线程中，全局变量由所有线程共享，所以，任何一个全局变量都可以被任何一个线程修改**，因此，线程之间共享数据最大的危险在于多个线程同时改一个变量

来看看多个线程同时操作一个变量怎么把内容给改乱了:

```python
from threading import Thread

balance = 0
def change_it(n):
    global balance
    balance += n
    balance -= n

def run_thread(n):
    for i in range(1000000):
        change_it(n)

t1 = Thread(target=run_thread, args=(2, ))
t2 = Thread(target=run_thread, args=(3, ))
t1.start()
t2.start()
t1.join()
t2.join()
print(balance) # 预期结果为0，但实际上结果可能为 3、-4 等
```



原因是因为 int 为不可变类型，balance += n 相当于 balance = balance + n, 而这一语句在 CPU 执行时分两步：

* 计算balance + n，存入临时变量中
* 将临时变量的值赋给全局变量balance

而在多线程中，t1和 t2是交替执行的，这就是问题所在，如果操作系统以下面的顺序执行 t1,t2:

```python
将临时变量的值赋给balance
初始值 balance = 0
t1: temp_1 = balance + 2
t2: temp_2 = balance + 3

t2: balance = temp_2 # 3
t1: balance = temp_1 # 2

t1: temp_1 = balance - 2 # 0
t1: balance = temp_1 # 0

t2: temp_2 = balance - 3 # -3
t2: balance = temp_2 # -3

结果: balance = -3
```

如果我们要确保balance计算正确，就要给change_it()上一把锁(也可以不加锁，将balance作为局部变量，每次传入，但比较麻烦,见11.md)，当某个线程开始执行change_it()时，我们说，该线程因为获得了锁，因此其他线程不能同时执行change_it()，只能等待，直到锁被释放后，获得该锁以后才能改。由于锁只有一个，无论多少线程，同一时刻最多只有一个线程持有该锁，所以，不会造成修改的冲突。创建一个锁就是通过`threading.Lock()`来实现:

```python
balance = 0
lock = threading.Lock()

def change_it(n):
    global balance
    balance += n
    balance -= n

def run_thread(n):
    for i in range(1000000):
        lock.acquire()
        try:
            change_it(n)
        finally:
            lock.release()
        # 也可用：
        # with lock:
        #     change_it(n)

```

锁的好处就是确保了某段关键代码只能由一个线程从头到尾完整地执行，但其阻止了多线程并发执行，**包含锁的某段代码实际上只能以单线程模式执行**。此外，由于可以存在多个锁，不同的线程持有不同的锁，并试图获取对方持有的锁时，可能会造成死锁，导致多个线程全部挂起，既不能执行，也无法结束，只能靠操作系统制终止。

## 多核CPU

要想把N核(逻辑核，非物理核)CPU的核心全部跑满，就必须启动N个死循环线程。

```python
import threading
import multiprocessing

def loop():
    x = 0
    while True:
        x = x ^ 1

for i in range(multiprocessing.cpu_count()):
    t = threading.Thread(target=loop)
    t.start()
```

启动与CPU核心数量相同的N个线程，在4核CPU上可以监控到CPU占用率仅 有102%，也就是仅使用了一核。

但是用C、C++或Java来改写相同的死循环，直接可以把全部核心跑满，4核 就跑到400%，8核就跑到800%，为什么Python不行呢?

因为Python的线程虽然是真正的线程，但解释器执行代码时，有一个GIL 锁:Global Interpreter Lock，任何Python线程执行前，必须先获得GIL锁， 然后，**每执行100条字节码，解释器就自动释放GIL锁，让别的线程有机会执行**。这个GIL全局锁实际上把所有线程的执行代码都给上了锁，所以，**多线程在Python中只能交替执行**，即使100个线程跑在100核CPU上，也只能用到 1个核。

所以，在Python中，可以使用多线程，但不要指望能有效利用多核。

Python虽然不能利用多线程实现多核任务，但可以通过多进程实现多核任务。多个Python进程有各自独立的GIL锁，互不影响。此外，若在`
多线程在Python中只能交替执行`的交替过程中，本身也存在io等待呢？ 这样也相当于能能有效利用多进程增加运行效率。
