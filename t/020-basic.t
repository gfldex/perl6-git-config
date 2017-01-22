use v6;
use Test;

use Git::Config;

is git-config('t/data/gitconfig'.IO)<user><email>, 'hans@hansen.net', 'Hash Subscript to email field';
is git-config('t/data/gitconfig'.IO){'remote "origin"'}<url>, 'https://github.com/perl6/ecosystem.git', 'fancy section name';
