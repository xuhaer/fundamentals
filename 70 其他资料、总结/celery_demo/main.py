'''
    启动 Celery Worker 进程：celery -A celery_app worker --loglevel=info
    然后即可使用 delay() 或 apply_async() 方法来调用任务了
'''
import time

from celery_app.add_task import add_task
from celery_app.multiply_task import multiply_task

# delay 方法封装了 apply_async 而已
# apply_async 有几个常用参数 countdown： 指定多少秒后执行任务

add_task.delay(2, 8)
multiply_res = multiply_task.apply_async(args=[3, 7], countdown=1)
# 虽然任务函数 add_task 和 multiply_res 需要等待 5 秒才返回执行结果，
# 但由于它是一个异步任务，不会阻塞当前的主程序，因此主程序会往下执行 print 语句，打印出结果。
print('我不会被阻塞！')
# 使用 ready() 判断任务是否执行完毕
while not multiply_res.ready():
    time.sleep(0.2)

print(multiply_res.ready())
print(multiply_res.get())
