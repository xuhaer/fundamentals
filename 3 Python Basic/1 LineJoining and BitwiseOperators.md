## Line Joining

在一个字符串中，一个放置在末尾的反斜杠表示字符串将在下一行继续，但不会添加新的一行。

例如:

```python
s = "This is the first sentence. \
This is the second sentence."
```

相当于：`s = "This is the first sentence. This is the second sentence."`

这被称作**显式行连接（Explicit Line Joining）**

在某些情况下，会存在一个隐含的假设，允许你不使用反斜杠。这一情况即逻辑行以括号开始，它可以是圆括号、方括号或花括号。这被称作 隐式行连接（Implicit Line Joining）

例如:

```python
l = ['a', #可以带注释, 等于 l = ['a', 'b']
     'b']
```



## BitwiseOperators

* x << y

  Returns x with the bits shifted to the left by y places (and new bits on the right-hand-side are zeros). This is the same as multiplying `x` by `2**y`.

  左移几位相当于乘于`2**n`次方, 可用来整数的乘法, 比如 `3 << 2 == 3 * 2 ** 2` True.

* x >> y

  注意: 不能用来作除法，在位数够用的情况下，如 `8 >> 2` 结果为2(相当于8 / 2** 2) ，但9 >> 2结果也为 2, `3 >> 2` 结果为 0
  