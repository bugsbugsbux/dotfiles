Structure of the repo:
~~~
files are named and located as they would be in ~ or /
except, that they are located in a subfolder of the repository-root
which represents the target plattform (linux, windows, termux, nixos)
~~~

How this repo is to be used:
~~~
A bare repo in ~/repos
    is used to combine the histories of the clones and to interact with UPSTREAM.
    When a worktree is necessary it can be added using:
    `git worktree add /tmp/master`
    but has to be removed again for the clones to be able to interact with the bare repo! use:
    `git worktree remove /tmp/master` (if the worktree exists and is clean) or
    `git worktree prune` (if it was removed manually)

Sparse clones of this repo are located in ~/.dot
    They use a non-tracking branch 'dev'
    and a tracking branch 'master' which pulls from and pushes to the bare repo
    and is used to cherry pick from 'dev' to compose a nice history on 'master'
~~~
