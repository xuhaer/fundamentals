## Git 合并2个仓库(保留 commit 记录)

比如我想把 repo_a 仓库合并到 myropo 仓库中：
```bash
cd ~/git/myropo
git remote add repo_a ~/git/repo_a/
git fetch repo_a --tags
git merge --allow-unrelated-histories repo_a/master
git remote remove project-a

git add --> commit --> push
```

## 版本回退

- git-reset
    Reset current HEAD to the specified state
    有3种模式：
    - git reset --mixed: HEAD引用指向给定提交，并且索引（暂存区）内容也跟着改变，工作目录内容不变。这个命令会**将索引（暂存区）变成你刚刚暂存该提交全部变化是的状态，会显示工作目录中有什么修改**。
    - git reset --soft: 将HEAD引用指向给定提交。索引（暂存区）和工作目录的内容是不变的，在三个命令中对现有版本库状态改动最小。
    - git reset --hard: HEAD引用指向给定提交，索引（暂存区）内容和工作目录内容都会变给定提交时的状态。也就是在给定提交后所修改的内容都会丢失，新文件会被删除。
    假若我想回退上次提交，并在上次提交的基础上再做一点小更改(比如上次提交为 fix some bugs，但里面某行代码少些了个括号，再提交一次显得没有意义)，那么使用reset 的默认方式再好不过了。
    注意：假若我想删除上次提交，而且并不关心上次提交具体是什么，可以用 --hard，然后git push -f，达到回退的效果。但是，这仅限于自己使用，若是团队合作，这样会有重大缺陷：假若其他人本地上pull 了你刚刚不需要的提交就比较麻烦。

- git-revert
    Revert some existing commits
    这个就好理解了，通过叠加一次新的提交而达到回退的效果。

还有个小区别，reset 是紧跟你"到达" 的某次commit，而 revert  自然紧跟你想覆盖掉的某次commit。



## Git Commit Message 编写指南

### 提交信息的结构

Commit message 一般都包括三个部分：Header，Body 和 Footer。

```
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

其中，Header 是必需的，Body 和 Footer 大多数情况可以省略。

#### 1. Header

**Type：类型**

`type`用于说明 commit 的类别, 具体来说，`Type` 分为：

- **feat:** 增加新功能(feature)；
- **fix:** 修复错误(bug)；
- **docs:** 修改文档(documentation)；
- **style:** 修改样式(不影响代码运行的变动)；
- **refactor:** 代码重构(即不是新增功能，也不是修改bug的代码变动)；
- **test:** 增加测试模块，不涉及生产环境的代码；
- **chore:** 更新核心模块，包配置文件，不涉及生产环境的代码；

如果`type`为`feat`和`fix`，则该 commit 将肯定出现在 Change log (**可以直接从commit生成Change log**)之中。其他情况（`docs`、`chore`、`style`、`refactor`、`test`）由你决定，要不要放入 Change log，建议是不要。



**Scope**

`scope`用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。



**Subject：标题**

`subject`是 commit 目的的简短描述，不超过50个字符。

具体要求如下: 

* 以动词开头，使用祈使句来描述，比如`change`，而不是`changed`或`changes`
* 第一个字母小写
* 结尾不加句号（`.`）

#### 2. Body：正文

并不是所有的 Commit 都需要正文，必要的时候对本次 Commit 做一些背景说明，阐释具体的原因和内容，但是不解释具体的过程。

注意：

* 正文的文字不能超过72个字符
* 同样使用祈使句来描述

#### 3. Footer：结尾

Footer 部分只用于两种情况。

**（1）不兼容变动**

如果当前代码与上一个版本不兼容，则 Footer 部分以`BREAKING CHANGE`开头，后面是对变动的描述、以及变动理由和迁移方法。

```markdown
BREAKING CHANGE: isolate scope bindings definition has changed.

    To migrate the code follow the example below:

    Before:

    scope: {
      myAttr: 'attribute',
    }

    After:

    scope: {
      myAttr: '@',
    }

    The removed `inject` wasn't generaly useful for directives so there should be no code using it.
```

**（2）关闭 Issue**

如果当前 commit 针对某个issue，那么可以在 Footer 部分关闭这个 issue 。

```markdown
Closes #1, #2, #3
```



**补充:**

还有一种特殊情况，如果当前 commit 用于撤销以前的 commit，则必须以`revert:`开头，后面跟着被撤销 Commit 的 Header。

```
revert: feat(pencil): add 'graphiteWidth' option

This reverts commit 667ecc1654a317a13331b17617d973392f415f02.
```

Body部分的格式是固定的，必须写成`This reverts commit <hash>.`，其中的`hash`是被撤销 commit 的 SHA 标识符。

如果当前 commit 与被撤销的 commit，在同一个发布（release）里面，那么它们都不会出现在 Change log 里面。如果两者在不同的发布，那么当前 commit，会出现在 Change log 的`Reverts`小标题下面。

**Example：举例**

```
docs: add FAQ in readme file
```