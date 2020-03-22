**contextmanager: decorator, 可用于为 with 语句上下文管理器定义工厂函数，而无需创建类或单独的 enter() 和 exit() 方法。**

```python
import time
from contextlib import contextmanager

@contextmanager
def foo():
    print('entering')
    yield 'sleep 2s'
    print('exiting')


with foo() as a:
    print(a)
    time.sleep(2) # 会在 with 语句结束后才会执行 print('exiting)


print('the same as below:')

class Bar:

    def __enter__(self):
        print('entering')
        return 'sleep 2s'

    def __exit__(self, exc_ty, exc_val, tb):
        print('exiting')

with Bar() as a:
    print(a)
    time.sleep(2)
```

另一个实际在项目中遇到的：

```python
session = Session()

@contextmanager
def sql_session():
    try:
        print('__enter__')
        yield session
        print('__exit__')
        session.commit() # 可理解为 with 语句结束自动执行 commit

    except Exception as err:
        # session.commit() 出错会被 catch
        # sesssion.do.... 的过程中出现错误也会被 catch。
        session.rollback()
        raise err
    finally:
        session.close()

with sql_session() as session:
    sesssion.do....


# 上面的except Exception 两种情况如下：
@contextmanager
def sql_session():
    try:
        print('__enter__')
        yield 'session'
        print('__exit__')
        'session' + 1 

    except Exception as err:
        print('error')
        raise err
    finally:
        print('close')

with sql_session() as session:
    print(session)
# 结果: 
# __enter__
# session
# __exit__
# error
# close
# TypeError: can only concatenate str (not "int") to str


@contextmanager
def sql_session():
    try:
        print('__enter__')
        yield 'session'
        print('__exit__')

    except Exception as err:
        print('error')
        raise err
    finally:
        print('close')

with sql_session() as session:
    session + 1 

# 结果:
# __enter__
# error
# close
# TypeError: can only concatenate str (not "int") to str
```
