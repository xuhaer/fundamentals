## ThreadLocal

在多线程环境下，每个线程都有自己的数据。一个线程使用自己的局部变量比使用全局变量好，因为局部变量只有线程自己能看见，不会影响其他线程，而全局变量的修改必须加锁。

但是局部变量也有问题，就是在函数调用的时候，传递起来很麻烦:

```python
def process_student(name):
    std = Student(name)
    do_task_1(std)
    do_task_2(std)

def do_task_1(std):
    do_subtask_1(std)
    do_subtask_2(std)

def do_task_2(std):
    do_subtask_2(std)
    do_subtask_2(std)
```

每个函数一层一层调用都得传参数，那么用全局变量呢? 也不行，因为每个线程处理不同的Student对象，不能共享。

如果用一个全局dict存放所有的Student对象，然后以thread自身作为key获得线程对应的Student对象如何?

理论上是可行的，它最大的优点是消除了std对象在每层函数中的 传递问题，但是，每个函数获取std的代码有点丑。

**ThreadLocal应运而生：解决参数在一个线程中各个函数之间互相传递的问题。**

```python
import threading

local_school = threading.local()

def process_student():
    std = local_school.student
    print(f'Hello, {std} (in {threading.current_thread().name})')

def process_thread(name):
    local_school.student = name
    process_student()

t1 = threading.Thread(target=process_thread, args=('Alice',), name='Thread-A')
t2 = threading.Thread(target=process_thread, args=('Bob',), name='Thread-B')
t1.start()
t2.start()
t1.join()
t2.join()
```

结果:

```python
Hello, Alice (in Thread-A)
Hello, Bob (in Thread-B)
```

每个Thread对全局变量ThreadLocal对象读写student属性，但互不影响。你可以把local_school看成全局变量，但每个属性如local_school.student都是线程的局部变量，可以任意读写而互 不干扰，也不用管理锁的问题

ThreadLocal最常用的地方就是为每个线程绑定一个数据库连接，HTTP请求，用户身份信息等，这样一个线程的所有调用到的处理函数都可以非常方便地访问这些资源。

