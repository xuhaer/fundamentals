# 附录 D EXPLAIN

EXPLAIN命令是查看查询优化器如何决定执行查询的主要方法。这个功能有局限性,并不总会说出真相,但它的输出是可以获取的最好信息,值得花时间了解,因为可以学习到查询是如何执行的。学会解释 EXPLAIN将帮助你了解 MySQL优化器是如何工作的。

## 调用 EXPLAIN

要使用 EXPLAIN,只需在查询中的 SELECT关键字之前增加 EXPLAIN这个词。 MySQL会在查询上设置一个标记。当执行查询时,这个标记会使其返回关于在执行计划中每一步的信息,而不是执行它。它会返回一行或多行信息,显示出执行计划中的每一部分和执行的次序。



要意识到 EXPLAIN只是个近似结果,别无其他。有时候它是一个很好的近似,但在其他时候,可能与真相相差甚远。以下是一些相关的限制。

* EXPLAIN根本不会告诉你触发器、存储过程或UDF(用户自定义函数)会如何影响查询。
* 它并不支持存储过程,尽管可以手动抽取查询并单独地对其进行 EXPLAIN操作。
* 它并不会告诉你 MySQL在查询执行中所做的特定优化。
* 它并不会显示关于查询的执行计划的所有信息( MySQL开发者会尽可能增加更多信息)
* 它并不区分具有相同名字的事物。例如,它对内存排序和临时文件都使用 "filesort", 并且对于磁盘上和内存中的临时表都显示"Using temporary"。

## 重写非 SELECT查询(MySQL 5.6 允许解释非 SELECT 查询)

MySQL EXPLAIN只能解释 SELECT查询,并不会对存储程序调用和 INSERT、 UPDATE、DELETE或其他语句做解释。然而,你可以重写某些非 SELECT查询以利用 EXPLAIN。为了达到这个目的,只需要将该语句转化成一个等价的访问所有相同列的 SELECT。任何提及的列都必须在 SELECT列表,关联子句,或者WHERE子句中。

## EXPLAIN 中的列

EXPLAIN 的输出总是有相同的列，可变的是行数及内容。

###  id列

这一列总是包含一个编号,标识 SELECT所属的行。如果在语句当中**没有子查询或联合**,那么只会有唯一的 SELECT,于是每一行在这个列中都将显示一个1。否则,内层的SELECT语句一般会顺序编号,对应于其在原始语句中的位置。

**MySQL将 SELECT查询分为简单和复杂类型,复杂类型可分成三大类:简单子查询、所谓的派生表(在FROM子句中的子查询),以及 UNION查询。**

注："FR0N子句中的子查询是派生表" 这一表述是对的,但“派生表是FR0M子句中的子查询”则不对,术语“派生表”在SQL中含义很宽泛。

下面是一个简单的子查询：

```mysql
mysql> EXPLAIN SELECT (SELECT 1 FROM actor LIMIT 1) FROM film;
```


### select_type列

这一列显示了对应行是简单还是复杂 SELECT(如果是后者,那么是三种复杂类型中的哪种)。SIMPLE值意味着查询不包括子査询和 UNION。如果查询有仼何复杂的子部分,则最外层部分标记为 PRIMARY,其他部分标记如下。
- SUBQUERY: 包含在 SELECT列表中的子查询中的 SELECT(换句话说,不在FROM子句中)标记为SUBQUERY。
- DERIVED: DERIVED值用来表示包含在FROM子句的子查询中的 SELECT, MySQL会递归执行并将结果放到一个临时表中。服务器内部称其“派生表”,因为该临时表是从子查询中派生来的。
- UNION: 在UNI0N中的第二个和随后的 SELECT被标记为UNI0N。
- UNION RESULT: 用来从 UNION的匿名临时表检索结果的 SELECT被标记为 UNION RESULT。

除了这些值, SUBQUERY和UNION还可以被标记为 DEPENDENT和 UNCACHEABLE。 DEPENDENT 意味着 SELECT依赖于外层查询中发现的数据; UNCACHEABLE意味着 SELECT中的某些特性阻止结果被缓存于一个 Item cache中。

### table 列
这一列显示了对应正在访问哪个表。
