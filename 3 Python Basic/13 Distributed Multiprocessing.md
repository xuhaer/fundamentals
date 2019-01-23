思路很简单，master 机器负责从队列中 put 数据然后从 salve 取得结果，而 slave 机器只负责 get 任务, 然后计算数据。

queue 模块中的`queue.Queue`或者`multiprocessing`模块中的`multiprocessing.Queue均可来共享数据。

`queue.Queue(maxsize=0)`是Python标准库中的线程安全的队列(`FIFO`)实现,maxsize是个整数，指明了队列中能存放的数据个数的上限。一旦达到上限，插入会导致阻塞，直到队列中的数据被消费掉。如果maxsize小于或者等于0，队列大小没有限制。

`queue.LifoQueue(maxsize=0)`,后进先出,与栈类似

`queue.PriorityQueue(maxsize=0)`, 可自定义优先级

```python
# master.py

import random
from multiprocessing import Queue
from multiprocessing.managers import BaseManager


class MasterProcessing:
    """一个简单的分布式多进程计算"""
    def __init__(self):
        self.task_queue = Queue()
        self.result_queue = Queue()
        BaseManager.register('get_task_queue',
                             callable=lambda: self.task_queue)
        BaseManager.register('get_result_queue',
                             callable=lambda: self.result_queue)
        self.manager = BaseManager(address=('127.0.0.1', 5555),
                                   authkey=b'abc')
        self.manager.start()

    def put_task(self):
        task = self.manager.get_task_queue() 
        for i in range(3):
            n = random.randint(1000, 10000)
            task.put(n)
            print(f'put 任务:计算{n}与{n}的乘积')

    def get_result(self):
        result = self.manager.get_result_queue()
        print('Try get results...')
        for i in range(3):
            print(f' 取得结果: {result.get(timeout=10)}')
        self.manager.shutdown()
        print('master exit.')

if __name__ == '__main__':
    r = MasterProcessing()
    r.put_task()
    r.get_result()
```

```python
# slave.py

import time
from multiprocessing.managers import BaseManager
from multiprocessing import Queue


class SlaveProcessing:

    def __init__(self):
        BaseManager.register('get_task_queue') 
        BaseManager.register('get_result_queue')
        print('Connect to server ...')
        self.manager = BaseManager(address=('127.0.0.1', 5555),
                                   authkey=b'abc')
        self.manager.connect()

    def run_task(self):
        task = self.manager.get_task_queue()
        result = self.manager.get_result_queue()
        for i in range(3):
            try:
                n = task.get(timeout=10)
                print(f'正在计算:{n}与{n}的乘积...')
                time.sleep(1)
                result.put(f'{n} * {n} = {n * n}')
            except Queue.Empty:
                print('task queue is empty.')

if __name__ == '__main__':
    r = SlaveProcessing()
    r.run_task()
```

分别在两个终端运行上面2个脚本，可看到显示如下:

master 终端:

```python
put 任务:计算6625与6625的乘积
put 任务:计算2834与2834的乘积
put 任务:计算4063与4063的乘积
Try get results...
 取得结果: 6625 * 6625 = 43890625
 取得结果: 2834 * 2834 = 8031556
 取得结果: 4063 * 4063 = 16507969
master exit.
```

slave 终端:

```python
Connect to server ...
正在计算:6625与6625的乘积...
正在计算:2834与2834的乘积...
正在计算:4063与4063的乘积...
```

