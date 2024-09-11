**What is this?**

This repo contains my dotfiles, separated by target paltform (the
toplevel folders) and named as they would be in HOME or root, meaning
`/etc/*` files would be in `PLATFORM/etc/*` and hidden files, like
`~/.config/*`, stay hidden: `PLATFORM/.config/*`. This is because it
makes it easier to automate the install process.

**How to manage dotfiles?**

Dotfiles are best managed by putting them into a repo somewhere and
linking them to the correct places. However, this approach has problems:
The links refer to the version in the current worktree, which might not
be the latest (possibly uncommitted) one due to branching or stashing.
The solution is to get multiple worktrees, either by using the `git
worktree` command or by using multiple clones.

Personally I prefer to create a `--bare` clone LOCAL of REMOTE and
multiple local `sparse-checkout --no-cone` CLONES which only reveal
files of a certain topic. Then I link to the CLONES, which have two
branches: `dev`, receiving all commits, often undoing and redoing the
same changes when experimenting, and `master`, fetching from LOCAL,
cherry-picking from `dev` to create a nice history, and pushing
back to LOCAL. LOCAL is used to push and pull to/from REMOTE.

**`setup.sh`**

The `setup.sh` script not only handles setting up the dotfiles,
including creating the necessary files, folders and clones, but **also
sets up the HOME directory how I like it.** Here is to to use it:

~~~
PLATFORM=myplatform ./setup.sh      # setting PLATFORM is required!
~~~
