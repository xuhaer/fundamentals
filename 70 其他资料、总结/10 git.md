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
