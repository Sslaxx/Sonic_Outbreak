# So how do I add my stuff to Sonic Outbreak?

**PM or message me (Sslaxx) on Discord if at any point you're stuck! I'll do my best to help. Or use the issue tracker on GitHub.**

First of all, **never commit directly to master**. The master branch is what's going to be used for stable builds of the game. Though it can never be guaranteed, obviously, avoiding merging everything into master straight off reduces the likelihood of it being unstable/making unplayable builds.

## So what do I do, then?

If you want to add a new feature (new gimmick, new badnik or zone, etc.) or fix one of the (plenty of) bugs in the code, first of all create a new branch, giving it a name that (hopefully!) describes what you want it to do. How you create branches in a GUI depends on what Git client you're using, but from the command line this *should* work: `git checkout -b fix_backwards_flying_hedgehogs`

And then you'll have a new branch called `fix_backwards_flying_hedgehogs`. Everything you add or commit to the repo will then be to that branch. Do `git checkout -b master` to switch to master at any point if you need (or, indeed, any other branch). https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging has more info on this.

When you think it's ready, go to https://github.com/Sslaxx/Sonic_Outbreak/pulls and create a new pull request. Describe what your changes are. https://help.github.com/articles/about-pull-requests/ has more info too.

When it's all good, the changes will be merged into master, and the branch you created after will be deleted (so remember to switch back to master on your local copy!).
