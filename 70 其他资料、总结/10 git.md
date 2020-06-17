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
    - git reset --mixed: HEAD引用指向给定提交，并且索引（暂存区）内容也跟着改变，工作目录内容不变。这个命令会**将索引（暂存区）变成你刚刚暂存该提交全部变化时的状态，会显示工作目录中有什么修改**。(也就是回到你提交前，并且还未执行`git add`时的状态)
    - git reset --soft: 将HEAD引用指向给定提交。索引（暂存区）和工作目录的内容是不变的，在三个命令中对现有版本库状态改动最小。
    - git reset --hard: HEAD引用指向给定提交，索引（暂存区）内容和工作目录内容都会变给定提交时的状态。也就是在给定提交后所修改的内容都会丢失，新文件会被删除。
    假若我想回退上次提交，并在上次提交的基础上再做一点小更改(比如上次提交为 fix some bugs，但里面某行代码少些了个括号，再提交一次显得没有意义)，那么使用reset 的默认方式再好不过了。
    注意：假若我想删除上次提交，而且并不关心上次提交具体是什么，可以用 --hard，然后git push -f，达到回退的效果。但是，这仅限于自己使用，若是团队合作，这样会有重大缺陷：假若其他人本地上pull 了你刚刚不需要的提交就比较麻烦。

- git-revert
    Revert some existing commits
    这个就好理解了，通过叠加一次新的提交而达到回退的效果。

还有个小区别，reset 是紧跟你"到达" 的某次commit，而 revert  自然紧跟你想覆盖掉的某次commit。

例子：git log里已经有2次提交：commit_id_2(第二次提交)、commit_id_1 (第一次提交), 如果想撤销掉commit_2，可以有如下方法:

- `git reset commit_id_1`: 此时保留了 commit_id_2 做的修改，但未 add
- `git reset --soft commit_id_1`: 此时保留了 commit_id_2 做的修改，并且状态属于已经 git add后的了。
- `git reset --hard commit_id_1`: 此时相当于回到干净时的commit_id_1 状态。
- `git-revert commit_id_2`： 通过覆盖掉上次提交而达到回退的作用。



## Git rebase

**场景1:** 合并多次提交纪录

有时候，git history里充满了很多没有意义的commit，比如，针对一个bug，有好多次提交，每次都叫 fix the xxx bug，这不仅仅是多了一些提交记录而已，这样还不利于代码 `review，`同样也会造成分支污染。那么这时，我们可以使用`git rebase`来合并多次提交纪录。

```bash
# 比如，我们来合并最近的 4 次提交纪录，执行：
git rebase -i HEAD~4
# 这时候，会自动进入 vi 编辑模式,根据需要选择相应的命令，然后保存。
```

需要注意：不要合并先前提交的东西，也就是已经提交至远程分支的纪录。不然会导致`error: cannot 'squash' without a previous commit`。



**场景2:** 分支合并

dev分支：	a --> b --> c --> d

master分支：a --> b

一般要把dev上的提交应用到master分支上去，使用一个merge即可，然后会有一个新的提交(Merge branch xxx)。 但有时我们不希望有这么一个merge的提交记录，则可以使用: git rebase。

详情见 [视频](https://www.bilibili.com/video/BV1Qb411N7ay)

如果执行上面后，我们仅仅想在master上保留一个commit，这时，再在master上使用rebase 回到场景1即可。 [参见链接](https://stackoverflow.com/questions/15727597/git-how-to-rebase-and-squash-commits-from-branch-to-master)


## 多分支开发 Git 相关流程

### 若有git clone (git push)的权限

这种情况，我个人不太喜欢先fork，我偏向于直接 clone，然后切到工作分支，再checkout -b 至个人分支，最后提交(在远程上创建自己的分支)。

例子：alarm库的dev分支上有个bug，需要做相应修改。

```bash
# 1. clone 指定分支(-b, 也可默认clone,再切换分支):
git clone -b dev ssh://git@code-cbu.huawei.com:2233/CBU-PaaS/CCI/CCI-Common/alarm.git

# 2. 切到个人分支
git checkout -b xxl-fix

# 3. 修复bug commit 后fetch一下，确保拉取到远程最新的代码
git fetch origin

# 4. 若远程有新的提交，则rebase一下。若有冲突，则合并冲突
git rebase origin/dev # 此例子是我需要在dev分支上做修改

# 5. git push (冒号前是本地分支名，冒号前的是你远程想创建的分支名)
# 下例中等价于 git push origin xxl-fix
git push origin xxl-fix:xxl-fix

# 6. 提交将xxl-fix分支merge 到 dev分支的 PR

git clone ssh://git@code-cbu.huawei.com:2233/CBU-PaaS/CCI/CCI-Common/alarm.git

# 7. merge后删除该修复分支
git push --delete origin xxl-fix
```

### 若没有权限，只能fork

例子：alarm库的dev分支上有个bug，需要做相应修改。

```bash
# 1. 先fork该项目到自己仓库

# 2. clone fork后的项目, 指定分支(-b, 也可默认clone,再切换分支):
git clone -b dev ssh://git@code-cbu.huawei.com:2233/x30005286/alarm.git

# 3. 切到个人分支
git checkout -b xxl-fix

# 3. 修复bug commit 后fetch一下，确保拉取到远程最新的代码
git fetch origin

# 4. 若远程有新的提交，则rebase一下。若有冲突，则合并冲突
git rebase origin/dev # 此例子是我需要在dev分支上做修改

# 5. git push (冒号前是本地分支名，冒号前的是你远程想创建的分支名)
# 下例中等价于 git push origin xxl-fix
git push origin xxl-fix:xxl-fix

# 6. 提交将xxl-fix分支merge 到 dev分支的 PR

# 当然，若有clone、push的权限，你也可以先fork，按照上面的操作，到了第5步后，也可：
# git remote add <别名> <url>
# 6. git remote add huawei ssh://git@code-cbu.huawei.com:2233/CBU-PaaS/CCI/CCI-Common/alarm.git

# 7. 然后直接push 到华为的远程分支
git push huawei xxl-fix:xxl-fix

# 8.提交将huawei项目仓库中的 xxl-fix分支merge 到 dev分支的 PR
```



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
- **chore:** 更新核心模块，包括配置文件，不涉及生产环境的代码；

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
