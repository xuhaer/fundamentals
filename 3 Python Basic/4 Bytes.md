

## 标准数据类型: Bytes

Bytes 对象是由单个字节作为基本元素（8位，取值范围 0-255）组成的序列，为不可变对象。

Bytes 对象$\color{red}{只负责以二进制字节序列的形式记录所需记录的对象} $，至于该对象到底表示什么（比如到底是什么字符）则由相应的编码格式解码所决定。

In addition to the literal forms, bytes objects can be created in a number of other ways:

- A zero-filled bytes object of a specified length: `bytes(10)`
- From an iterable of integers: `bytes(range(20))`
- Copying existing binary data via the buffer protocol:  `bytes(obj)`

```python
>>> a = '许'
>>> ord(a)
35768
>>> bytes(a, 'utf-8')
b'\xe8\xae\xb8' # 3个字节长度
>>> bytes(a, 'gb2312')
b'\xd0\xed'     # 2个字节长度
```

对于 ASCII 字符串，可直接使用 b'xxxx''赋值创建 bytes 实例，而对于非 ASCII 编码的字符串则不能通过这种方式创建 bytes 实例：

```python
>>> b'许'
SyntaxError: bytes can only contain ASCII literal characters.
>>> b'hello'
b'hello'
```

由于 bytes 是序列，因此可通过索引或切片访问它的元素。

Since bytes objects are sequences of integers (akin to a tuple), for a bytes object *b*, `b[0]` will be an integer, while `b[0:1]` will be a bytes object of length 1. (This contrasts with text strings, where both indexing and slicing will produce a string of length 1)

```python
>>> bytes('你好', 'utf-8')
b'\xe4\xbd\xa0\xe5\xa5\xbd'
>>> bytes('你好', 'utf-8')[0]   # 当然，interger 没有 len
228
>>> bytes('你好', 'utf-8')[0:1] # 其 len 为 1
b'\xe4'
```

对于 bytes 实例，如果需要还原成相应的字符串，则需要`decode()`,如果采用错误的解码格式解码，则可能会发生错误：

```python
# 有什么区别？
>>> '你好'.encode() == bytes('你好', 'utf-8')
True
```

```python
>>> bytes('你好', 'utf-8').decode()
'你好'
>>> bytes('你好', 'utf-8').decode('gb2312')
UnicodeDecodeError: 'gb2312' codec can't decode byte 0xa0 in position 2: illegal multibyte sequence
```

Since 2 hexadecimal digits correspond precisely to a single byte, hexadecimal numbers are a commonly used format for describing binary data. Accordingly, the bytes type has an additional class method to read data in that format:

- *classmethod* `fromhex`(*string*)

  This [`bytes`](https://docs.python.org/3/library/stdtypes.html#bytes) class method returns a bytes object, decoding the given string object. The string must contain two hexadecimal digits per byte, with ASCII whitespace being ignored.

  In 3.7: skips all ASCII whitespace in the string, not just spaces.

```python
>>> bytes.fromhex('e4 \nbd')
b'\xe4\xbd'
# A reverse conversion function exists to transform a bytes object into its hexadecimal representation:
>>> b'\xe4\xbd'.hex()
'e4bd'
```

另外，可通过 list(b)将一个 bytes object 转换为 a list of integers:

```python
>>> list(b'\x01\x02')
[1, 2]
```

