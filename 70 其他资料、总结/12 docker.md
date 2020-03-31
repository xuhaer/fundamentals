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



## redis镜像

使用 redis:5.0-alpine 为基础镜像并挂载配置文件和data文件。

首先，在服务器(或本机)起一个docker 的 redis 实例：
```bash
docker run -d \
-p 6379:6379 \
--name my_redis \
-v $PWD/redis_data:/data:rw \
-v $PWD/conf/redis.conf:/etc/redis/redis.conf:ro \
--privileged=true \
redis:5.0-alpine \
redis-server /etc/redis/redis.conf --requirepass "123321" 

其中：
--requirepass 不能少，奇怪！conf里不是已经定义了密码了吗？？
-v: 映射数据目录 rw 为读写, 挂载配置文件 ro 为readonly
--privileged=true: 给与一些权限
```

然后，在本机上就可以远程连接服务器上的redis了(控制台允许6379端口)：`47.100.138.140` 为服务器ip。

```bash
docker run -it --rm redis:5.0-alpine redis-cli -h 47.100.138.140 -p 6379
KEYS * # (error) NOAUTH Authentication required.
auth 123321
```

若要在服务器的另一个docker 实例中连接该redis，有两种方法：感觉都不太好，正确都处理方式应该是通过 docker-compose 吗？

```bash
# 直接连 -h localhost -p 6379 连接不成功，有点不解。
# 方法一：先取得该实例的ip: 
inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my_redis
# 得到：172.18.0.2
# 然后重启一个redis 实例，运行 `redis-cli -h 172.18.0.2 -p 6379` 即可。
docker run -it --rm redis:5.0-alpine redis-cli -h 172.18.0.2 -p 6379

# 方法二：docker容器内可通过 --link （--link 官方不推荐使用）
docker run -it --link my_redis:my_redis --rm redis:5.0-alpine redis-cli -h my_redis -p 6379
KEYS * # (error) NOAUTH Authentication required.
auth 123321
```

## Docker Compose

Compose 项目是 Docker 官方的开源项目，负责实现对 Docker 容器集群的快速编排。

通过第一部分中的介绍，我们知道使用一个 Dockerfile 模板文件，可以让用户很方便的定义一个单独的应用容器。然而，在日常工作中，经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个 Web 项目，除了 Web 服务容器本身，往往还需要再加上后端的数据库服务容器，甚至还包括负载均衡容器等。
Compose 恰好满足了这样的需求。它允许用户通过一个单独的 docker-compose.yml 模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。

Compose 中有两个重要的概念：

- 服务（service）：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
- 项目(project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。
Compose 的默认管理对象是项目，通过子命令对项目中的一组容器进行便捷地生命周期管理。

Compose 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。因此，只要所操作的平台支持 Docker API，就可以在其上利用 Compose 来进行编排管理。

一个简单的例子如下(Nginx、uwsgi、mysql、django):
文件路径大致如下:
```bash
- django-project
    - app
    - settings/
- nginx
    - sites-enabled
    - Dockerfile
- docker-compose.yml
- .env
- manager.py
- requirements.txt
- uwsgi.ini
```

docker-compose.yml 文件大致如下：
```yaml
version: '3'
services:
  db:
    image: mysql:5.7
    restart: always
    ports:
    # 使用宿主：容器（HOST:CONTAINER）格式，或者仅仅指定容器的端口（宿主将会随机选择端口）都可以。
      - 3306
    env_file: .env # 使用文件为容器设置多个环境变量
    volumes: xxx_mysql_data:/var/lib/mysql
  web:
    build: .
    restart: always
    ports:
        - 8000:8000
    depends_on:
        - db
    links:
      - db:mysql
    command: uwsgi -i ./uwsgi.ini
  nginx:
    build: ./nginx/
    restart: always
    ports:
      - 8080:80
    volumes:
      - /www/static
    depends_on:
        - web
    links:
     - web:web
```

现在就可以通过`sudo docker-compose up --build`启动项目了。
