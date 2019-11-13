import time
from . import app


@app.task
def multiply_task(x, y):
    print('multiply_task 模拟耗时2秒')
    time.sleep(2)
    return x * y
