## SICP（Structure and Interpretation of Computer Programs，计算机程序的构造和解释)

阅读 SICP 之前，你也许能通过调用几个函数解决一个简单问题。但阅读完 SICP 之后，你会学会如何将问题抽象并且分解，从而处理更复杂更庞大的问题，这是编程能力巨大的飞跃，这会在本质上改变你思考问题以及用代码解决问题的方式。

在这部书里使用 "程序设计" 一词时，所关注的是程序的创建、执行和研究，这些程序是用一种 Lisp 方言所写，但采用 Lisp 并没有对我们可以编程的范围施以任何约束或者限制，而不过是确定了程序描述的记法形式。

我们所设计的这门计算机科学导引课程反映了两方面的主要考虑。首先，我们希望建立起一种看法：一个计算机语言并不仅仅是让计算机去执行操作的一种方式，更重要的，它是一种表述有关方法学的思想的新颖的形式化媒介。因此，程序必须写得能够供人阅读，偶尔地供计算机执行。其次，我们相信，在这一层次的课程里，最基本的材料并不是特定的程序设计语言的语言，不是有效计算某种功能的巧妙算法，也不是算法的数学分析或者计算的本质基础，而是一些能够用于大型软件系统的智力复杂性的技术。

我们的目标是，使完成了这一科目的学生能对程序设计的风格要素和审美观有一种很好的感觉。他们应该掌握了控制大型系统中的复杂性的主要技术。他们应该能够去读50页长的程序，只要该程序是以一种值得模仿的形式写出来的。他们应该知道在什么时候哪些东西不需要去读，哪些东西不需要去理解。他们应该很有把握地去修改一个程序，同时又能保持原来作者的精神和风格。

这些技能并不仅仅适用于计算机程序设计。我们所教授和提炼出来的这些技术，对于所有的工程设计都是通用的。我们需要在适当的时候隐藏一些细节，通过创建抽象去控制复杂性。

### 第1章 [构造过程抽象(Building Abstractions with Procedures)](./1 构造过程抽象.md)
* 1.1 程序设计的基本元素(The Elements of Programming)
* 1.2 过程与它们所产生的计算(Procedures and the Processes They Generate)
* 1.3 用高阶函数做抽象(Formulating Abstractions with Higher-Order Procedures)
### 第2章 [构造数据抽象(Building Abstractions with Data)](./2 构造数据抽象.md)
* 2.1 数据抽象导引(Introduction to Data Abstraction)
* 2.2 层次性数据和闭包性质(Hierarchical Data and the Closure Property)
* 2.3 符号数据(Symbolic Data)
* 2.4 抽象数据的多重表示(Multiple Representations for Abstract Data)
* 2.5 带有通用型操作的系统(Systems with Generic Operations)
### 第3章 模块化、对象和状态(Modularity, Objects, and State)
* 3.1 赋值和局部状态(Assignment and Local State)
* 3.2 求值的环境模型(The Environment Model of Evaluation)
* 3.3 用变动数据做模拟(Modeling with Mutable Data)
* 3.4 并发：时间是一个本质问题(Concurrency: Time Is of the Essence)
* 3.5 流(Streams)
### 第4章 元语言抽象(Metalinguistic Abstraction)<泛读>
* 4.1 元循环求值器(The Metacircular Evaluator)
* 4.2 Scheme的变形——惰性求值(Variations on a Scheme -- Lazy Evaluation)
* 4.3 Scheme的变形——非确定性计算(Variations on a Scheme -- Nondeterministic Computing)
* 4.4 逻辑程序设计(Logic Programming)
### 第5章 寄存器机器里的计算(Computing with Register Machines)<泛读>
* 5.1 寄存器机器的设计(A Register-Machine Simulator)
* 5.2 一个寄存器机器模拟器(A Register-Machine Simulator)
* 5.3 存储分配和废料收集(Storage Allocation and Garbage Collection)
* 5.4 显式控制的求值器(The Explicit-Control Evaluator)
* 5.5 编译(Compilation)



起始于:2019-1-17