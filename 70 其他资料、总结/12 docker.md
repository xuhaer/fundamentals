# Docker

导入/导出镜像:

```bash
docker save image > ~/Desktop/img.tar
docker load < img.tar
```

提交容器为镜像：`docker commit -m "message" id name:tag`



## mysql:5.7镜像

**基于mysql:5.7的基础镜像搭建，暴露3306端口并挂载外部数据库和配置文件**

```bash
# Create docker network
docker network create my-net

# 启动 mysql 容器
docker run \
--name mysql-db \ 
--network my-net \
-v ~/Documents/docker/mysql.cnf:/etc/mysql/conf.d \
-v ~/Documents/docker/db/:/var/lib/mysql \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=123321 \
-d \
mysql:5.7 \
--character-set-server=utf8 \
--collation-server=utf8_unicode_ci

# 确保启动成功
docker ps -a
```
此后在Python程序中连接该数据库 HOST 仅需填写上面--network的name：
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'db-name',
        'USER': 'root',
        'PASSWORD': '123321',
        'HOST': 'my-net',      # docker 容器内程序的连接方式
        # 'HOST': 'localhost', # 宿主机的连接方式
        'PORT': 3306,
        'OPTIONS': {
            'sql_mode': 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO'
        }
    }
}
```



## 寻求最佳python基础镜像

寻求一个最佳的包含python环境的docker镜像，需求如下：

- 能通过pip安装大多数三方包

- python版本尽可能新

- 镜像体积尽可能小

  

仅用代表性的numpy、matplotlib、uwsgi这几个包，这几个包能解决，大部分包应该都能安装。



### python:3.7-alpine 或纯alpine镜像

本身基础镜像很少，但会出现各种依赖性出错，而安装依赖项又慢，太麻烦了，放弃。



### python:3.8-slim

当然，在安装 pyodbc 或 mysqlclient 还需要额外的依赖项，pymysql 则无此问题: 

- src/pyodbc.h:56:10: fatal error: sql.h: No such file or directory
- OSError: mysql_config not found

通过bash 进去执行同样的步骤: 537MB

`docker build -t python3.8:m_u -f Dockerfile .` build 成功后: 538MB

```dockerfile
FROM python:3.8-slim

# 237M
RUN apt update && \
	apt install --no-install-recommends -y build-essential pkg-config libfreetype6-dev && \
	pip install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy matplotlib uwsgi && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf ~/.cache/pip/* 
```



### ubuntu:18.04

Ubuntu:18.04 基础镜像65M, 当然，用此种方法很难做到安装指定版本的python(如python3.8)

`apt install python3`后其python版本为3.6.8(取决于官方源里的python版本)。

当然，这种方式在安装 pyodbc 或 mysqlclient 仍然需要安装额外的依赖项。

`docker build -t ubuntu:m_u -f Dockerfile .` build成功后 docker images 显示大小为:556MB

```dockerfile
FROM ubuntu:18.04

# --no-install-recommends 不可行。
RUN apt update && apt install -y python3 python3-pip && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy matplotlib uwsgi && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf ~/.cache/pip/*  
```

另一种尝试：通过`add-apt-repository ppa:deadsnakes/ppa`，然后可以安装最新的python3.8，但在安装某些需要编译环境的包时(如matplotlib)会缺少依赖。 不然先`python3 python3-pip `， 再安装python3.8，这样会导致两个python3 共存，而且默认的pip3 是python3.6的，需要 `python3.8 -m pip install package`。遂放弃该尝试。



还有一种尝试: bash 进入ubuntu，然后通过源码安装python3.8：

```bash
apt update
apt install 一大串依赖项

docker cp  Python-3.8.0.tgz 容器id:/

tar -xf Python-3.8.0.tgz
cd Python-3.8.0
./configure --enable-optimizations
make altinstall
python3.8 --version

pip3.8 install XX
```

也因一大串依赖项下来占用过大而放弃了。



### Centos:7

centos:7 基础镜像就 200M 了, 懒得试了。

```dockerfile
FROM centos:7

RUN yum update && yum install -y python3 python3-devel gcc && \
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy matplotlib uwsgi
```



### 结论

一圈下来发现仅2种比较合适的方法：

- 通过 python:slim 基础镜像搭建，优点是相对可控python版本, 缺点是过程慢(相比通过ubuntu 构建在安装pandas、matplotlib这种包时要慢很多)
- 通过 ubuntu:18.04 基础镜像搭建，优点是方便快捷，唯一缺点是python版本不可控。
- 够丧心病狂的话可以在生产环境(requirements.txt 包几乎不变)`pip install -r requirements.txt`后卸载 pip(限基础镜像里不包含pip的): `apt purge --auto-remove -y python3-pip && apt clean && rm -f xxx `， 能省出200多MB 空间(没记错的话)。

