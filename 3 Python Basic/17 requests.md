## Python requests 库
先在一个终端中打开输入: `nc -kl  8765` 

```python
>>> import json
>>> import requests

>>> d = {'a': 1, 'b': 2}
>>> requests.post("http://localhost:8765", data=d)
>>> j = json.dumps(payload)
>>> requests.post("http://localhost:8765", data=j)
```

- 不管json是str还是dict，如果不指定headers中的content-type，默认为application/json
- data为dict时，如果不指定content-type，默认为application/x-www-form-urlencoded，相当于普通form表单提交的形式，此时数据可以从request.POST里面获取，而request.body的内容则为a=1&b=2的这种形式，注意，即使指定content-type=application/-json，request.body的值也是类似于a=1&b=2，所以并不能用json.loads(request.body.decode())得到想要的值
- data为str时，如果不指定content-type，默认为application/json


Background: In the `prepare_body `method of requests a dictionary is explicitely converted to json and a content-header is also automatically set:

```python
if not data and json is not None:
    content_type = 'application/json'
    body = complexjson.dumps(json)
```

过程又遇到一个问题：如果 data 中是一个镶嵌的字典而content_type 是x-www-form-urlencoded 呢？ 只需要将为 dict 的value dumps 一下: [查看链接](https://github.com/kennethreitz/requests/issues/2885)
```Python
d = {'a': 1, 'b': {'b1': 1, 'b2': 2}}
data = {'a': 1, 'b': json.dumps({'b1': 1, 'b2': 2})}
requests.post("http://localhost:8765", data=data)
```
