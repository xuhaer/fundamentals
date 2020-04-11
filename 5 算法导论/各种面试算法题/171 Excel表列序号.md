给定一个Excel表格中的列名称，返回其相应的列序号。
例如，A -> 1, Z -> 26, AA -> 27


与十进制的方法一样，从高位遍历，之前的值乘以进制数再加上当前位上的值

```python
class Solution(object):
    def titleToNumber(self, s):
        ans = 0
        for i, c in enumerate(s):
            ans = ans*26 + ord(c)-ord('A') + 1
        return ans
```
