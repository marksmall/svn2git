# VCS Migration to Git

## Dependencies

* grep
* sort
* perl
* Subversion
* GIT
* git-svn bridge

## Migrate a single SVN repository

Before starting the migration process the person running the scripts need to ensure they have the privileges to access the SVN repository and push new repositories to the GitLab instance.

**NOTE:** If using another GIT server, there should be no difference, but I can't guarantee that.

1. Get list of SVN Committers: `svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' > users.txt`
1. Clone SVN repo using git-svn: `git svn clone [SVN repo URL] --no-metadata -A users.txt --stdlayout ~/[repo nam]`
1. Convert svn:ignore to .gitignore:
```
cd ~/[repo name]
git svn show-ignore > .gitignore
git add .gitignore
git commit -m "Convert svn:ignore to .gitignore"
```
4. Push repository to a bare git repository:
```
git init --bare ~/new-bare.git
cd ~/new-bare.git
git symbolic-ref HEAD refs/heads/trunk
```
5. Rename trunk branch to master:
```
cd ~/new-bare.git
git branch -m trunk master`
```
6. Clean up branches and tags:
```
cd ~/new-bare.git
git for-each-ref --format='%(refname)' refs/heads/tags |
cut -d / -f 4 |
while read ref
do
  git tag "$ref" "refs/heads/tags/$ref";
  git branch -D "tags/$ref";
done
```
7. Add remote to repository: `git remote add origin git@[git server]:[group]/[repository].git`
1. Push branches and tags to remote:
```
git push origin --all
git push origin --tags
```


## Migrate multiple SVN repositories

The steps defined in [Migrate a single SVN repository](#migrate-a-single-svn-repository) can be turned into a re-usable script to migrate a single repository, but what if you have many? It is wasteful to expect someone to run this against every repository. The better option is to write another script that will execute the above for a number of repositories. These repositories will likely come from a text file mapping:

    [SVN repo url]=[GIT repo url]


## References

* [GIT SCM Book](https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git)
* [Converting a Subversion repository to Git](https://john.albin.net/git/convert-subversion-to-git)
