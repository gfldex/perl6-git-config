#!bash

cat $root_dir/task.bash
echo; echo;

cd $cache_root_dir

git init

git remote add origin https://github.com/gfldex/perl6-git-config.git
git remote add origin2 https://github.com/gfldex/perl6-git-config.git
git config user.name "John Doe\\"
git config --add core.gitproxy 'proxy-command for example.com'
git config --add core.gitproxy 'proxy-command2 for example2.com'

echo "=== git config ==="
cat .git/config
echo "==="

cat << 'HERE' | raku - 2>&1
use Git::Config;
my $gc =  git-config('.git/config'.IO);

say "remote-repo: [{$gc{'remote "origin2"'}<url>}]";
say "remote-repo2: [{$gc{'remote "origin2"'}<url>}]";
say "user.name: [{$gc<user><name>}]";
say "core.filemode: [{$gc<core><filemode>}]";
for $gc<core><gitproxy><> -> $p {
  say $p
}
HERE

echo "==="
