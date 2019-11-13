'''config for celery'''

# broker = 'redis://127.0.0.1:6379' # without authentication
# broker_url = 'redis://user:password@host:6379/0' # with authentication
BROKER_URL = 'redis://default:123321@47.100.138.140:6379/0' # with authentication
CELERY_RESULT_BACKEND = 'redis://default:123321@47.100.138.140:6379/1'

CELERY_TIMEZONE = 'Asia/Shanghai'                   # 指定时区，默认是 UTC
CELERY_IMPORTS = (                                  # 指定导入的任务模块
    'celery_app.add_task',
    'celery_app.multiply_task'
)
