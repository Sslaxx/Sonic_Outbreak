# Git and Sonic Outbreak

## Stating the obvious...

Sonic Outbreak is hosted on [GitHub](https://github.com/), and uses [Git](https://git-scm.com/) as a version control system (which allows branches, reverting to earlier versions etc). This is *not* a tutorial on Git - https://git-scm.com/docs/gittutorial may be more useful there - this is just (minimally) how to use Git on this project.

https://guides.github.com/activities/hello-world/ can help with using GitHub in general as well.

## So how do I add my stuff to Sonic Outbreak?

**PM or message me (Sslaxx) on Discord if at any point you're stuck! I'll do my best to help.**

It's not going to be massively straightforward, sorry, but I hope I can get across what you need to do.

First of all, **never commit directly to master**. The master branch is what's going to be used for stable builds of the game. Though it can never be guaranteed, avoiding merging everything into master straight off reduces the likelihood of it being unstable/making unplayable builds. Branches are only merged into master when they're working as expected, reliably.

There are GUIs like [TortoiseGit](https://tortoisegit.org/) or [Fork](https://git-fork.com/) out there if you don't want to have to deal with the command line. [Git itself](https://git-scm.com/download/) comes with a GUI. If you use a GUI, you should familiarise yourself with it; this guide only talks about doing things from the command line.

## So what do I do, then?

First of all, clone the repository (i.e., create a local copy of it that you can work on). From the command line, something like `git clone https://github.com/Sslaxx/Sonic_Outbreak` would create a directory called Sonic_Outbreak, wherever you ran the command.

`git pull` will allow you to see updates from other people working on the same branch, so it might be a good idea to do that from time to time to make sure you either don't get your work overwritten, or theirs.

If you want to add a new feature (new gimmick, new badnik or zone, etc.) or fix one of the (plenty of) bugs in the code, first of all create a new branch, giving it a name that (hopefully!) describes what you want it to do. From the command line this *should* work: `git checkout -b fix_backwards_flying_hedgehogs`

Normally, you'll want to create your branch from master; Git will create a branch that is based on whatever branch you're currently on, so *remember to switch to master (or the desired branch) before creating a branch*.

You should have a new branch called `fix_backwards_flying_hedgehogs`. Everything you add or commit to the repo from this point will then be to that branch. Do `git checkout master` to switch back to master at any point if you need (or, indeed, any other branch). https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging has more info on this.

If you want to work on a branch that someone else has created, check out https://git-scm.com/book/en/v2/Git-Branching-Remote-Branches for more info about how (and why) this works and how to do it.

*Note*: Don't use any other symbols in a branch name other than dashes `-` or underscores `_`, please; this also means no spaces ` `.

Make sure to add the files you've changed to the commit you want to make. `git add` is the way from the command line; https://git-scm.com/docs/git-add is the documentation for this.

You'll need to commit and then push your changes to the branch. https://git-scm.com/docs/git-push tells you how to do this from the command line. **Make sure you're pushing to the branch you want!**

Don't worry so much about pushing broken code to any branch (that isn't master). **But** if you do, *please* make it clear (as much as you're able to) why and/or how the code is broken.

When you think it's ready to be merged into master (or some other branch), go to https://github.com/Sslaxx/Sonic_Outbreak/pulls and create a new pull request. Describe what the changes to the branch are in general. https://help.github.com/articles/about-pull-requests/ has more info too.

When it's all good, the changes will be merged in, and the branch will be deleted after - so remember to switch back to master or another branch on your local copy!
