## Coroutine

协程通过 async/await 语法进行声明。注意：简单地调用一个协程并不会将其加入执行日程:

```python
async def hello():
    print("Hello world!")
    await asyncio.sleep(1)
hello() # <coroutine object main at 0x1053bb7c8>
```

要真正运行一个协程，asyncio 提供了三种主要机制:

* [`asyncio.run()`](https://docs.python.org/zh-cn/3/library/asyncio-task.html#asyncio.run) 函数用来运行最高层级的入口点 "main()" 函数
* 等待一个协程
* [`asyncio.create_task()`](https://docs.python.org/zh-cn/3/library/asyncio-task.html#asyncio.create_task) 函数用来`并发运行`作为 asyncio [`任务`](https://docs.python.org/zh-cn/3/library/asyncio-task.html#asyncio.Task) 的多个协程。

```python
import time
import asyncio


async def hello(i):
    print("Hello world!")
    await asyncio.sleep(1) # asyncio.sleep() 总是会挂起当前任务，以允许其他任务运行。
    print(f'task {i} filished')


async def main():
    a = time.time()
    # 再多加几个 task 耗时相同
    t1 = asyncio.create_task(hello(1))
    t2 = asyncio.create_task(hello(2))
    await t1 # awaited to wait until it is complete
    await t2 # 也可取消掉
    print(f'用时{time.time() - a}秒')


asyncio.run(main())
```

结果:

```python
Hello world!
Hello world!
task 1 filished
task 2 filished
用时1.0046730041503906秒
```

### 可等待对象

如果一个对象可以在 await 语句中使用，那么它就是可等待对象；三种主要类型: 协程, 任务 和 Future.

* *Python 协程* 属于可等待对象，因此可以在其他协程中被等待

* *任务* 被用来设置日程以便 *并发* 执行协程。

  当一个协程通过 asyncio.create_task() 等函数被打包为一个 任务，该协程将自动排入日程准备立即运行。

* [`Future`](https://docs.python.org/zh-cn/3/library/asyncio-future.html#asyncio.Future)  是一种特殊的 低层级 可等待对象，表示一个异步操作的最终结果。


### 运行 asyncio 程序
`asyncio.``run`(*coro*, ***, *debug=False*)

此函数运行传入的协程，负责管理 asyncio 事件循环并 *完结异步生成器*。

当有其他 asyncio 事件循环在同一线程中运行时，此函数不能被调用。

此函数总是会创建一个新的事件循环并在结束时关闭之。它应当被用作 asyncio 程序的主入口点，理想情况下应当只被调用一次。

### 创建任务

`asyncio.``create_task`(*coro*)

将 *coro* [协程](https://docs.python.org/zh-cn/3/library/asyncio-task.html#coroutine) 打包为一个 [`Task`](https://docs.python.org/zh-cn/3/library/asyncio-task.html#asyncio.Task) 排入日程准备执行。返回 Task 对象

