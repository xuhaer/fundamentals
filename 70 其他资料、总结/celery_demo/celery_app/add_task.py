import time
from . import app


# 创建一个 Celery 任务 add，当函数被 @app.task 装饰后，就成为可被 Celery 调度的任务
@app.task
def add_task(x, y):
    print('add_task 模拟耗时3秒')
    time.sleep(3)
    return x + y
