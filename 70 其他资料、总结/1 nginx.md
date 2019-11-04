## Nginx

- 启动nginx:**sudo nginx**

- 停止服务:**sudo nginx -s quit**

- 修改了配置文件，要重新生效:**sudo nginx -s reload** service nginx reload

**location匹配：**

* `= `完全匹配
* `^~`或没有限定符规则执行前缀匹配

* `~`或`~*(不区分大小写)`的规则执行正则匹配

**location的查找过程:**

  首先会对所有的`等号规则`和`前缀规则`进行一次匹配筛选。nginx会在所有的前缀匹配中找到一个`最长的`匹配，然后记住这个匹配的location。之后会根据这个匹配规则是否有`限定符`来决定之后的行为：

  1. 如果是`等号规则`匹配到的，nginx会立即结束查找过程，这个location就是最终结果。
  2. 如果匹配到的规则被限定符`^~`修饰，则nginx也会结束这个查找过程，这个location就是最终结果。
  3. 如果没有找到匹配或是匹配项没有被限定符修饰，nginx就会进入`正则规则`的匹配筛选过程。在这个过程中，nginx会按照规则uri在配置中定义的顺序来进行匹配，只要匹配到其中一个，nginx就会立即结束这个匹配过程，这个location也会是最终location。如果没有能找到一个正则匹配，但是之前的前缀匹配成功，那么之前记住的前缀匹配结果则会成为最终结果。

下面举几个例子来看一下：假设用户均访问 "http://www.xxx.com/abc"

 1. `=`命中，跳过正则匹配

```
server {
    listen 80;

    server_name www.xxx.com;

    location /abc {}

    location = /abc {}

    location ~ /abc {}
}
```

 2. `^~`命中，跳过正则匹配

```
server {

    listen 80;

    server_name www.xxx.com;

    location /ab {}

    location ^~ /abc {}

    location ~ /abc {}
}
```

 3. `正则`命中1，正则匹配优先于前缀匹配

server {
    listen 80;

    server_name www.xxx.com;
    
    location /abc {}
    
    location ~ /ab.* {}
}
```

 4. `正则`命中2，正则按顺序匹配

```
server {
    listen 80;

    server_name www.xxx.com;
    
    location /ab {}
    
    location ~ /ab.* {}
    location ~ /abc {}
}
```

 5. `前缀`命中，正则匹配不到，使用之前命中的前缀匹配

```
server {
    listen 80;

    server_name www.xxx.com;
    
    location /abc {}
    
    location ~ /ef.* {}
}