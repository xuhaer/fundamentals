## Python requests 库
先在一个终端中打开输入: `nc -kl  8765` 

```Python
>>> import json
>>> import requests

>>> d = {'a': 1, 'b': 2}
>>> requests.post("http://localhost:8765", data=d)
^C
>>> j = json.dumps(payload)
>>> requests.post("http://localhost:8765", data=j)
^C
```
若传递给 data 字段为一个字典，那么 request body 的 Content-Type为`application/x-www-form-urlencoded`: `a=1&b=2`

如果直接传递一个字符串，其将没有明确的Content-Type 字段:
{"a": 1, "b": 2}

上面的第二种方式也可以更明确地直接传递 `requests.post("http://localhost:8765", json=d)`

Background: In the `prepare_body `method of requests a dictionary is explicitely converted to json and a content-header is also automatically set:

```Python
if not data and json is not None:
        content_type = 'application/json'
        body = complexjson.dumps(json)
```

试过过程又遇到一个问题：如果 data 中是一个镶嵌的字典而content_type 是x-www-form-urlencoded 呢？ 只需要将为 dict 的value dumps 一下: [查看链接](https://github.com/kennethreitz/requests/issues/2885)
```Python
d = {'a': 1, 'b': {'b1': 1, 'b2': 2}}
data = {'a': 1, 'b': json.dumps({'b1': 1, 'b2': 2})}
requests.post("http://localhost:8765", data=data)
```
