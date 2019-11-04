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
