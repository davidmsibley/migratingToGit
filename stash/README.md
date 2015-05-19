# Migrating your project from SVN to Git on Internal Stash

### Setting Up

In order to commit and pull from Stash, your development machine will need ssh keys.  Follow this tutorial:
https://help.github.com/articles/generating-ssh-keys

Once you've generated your ssh key, you'll need to add it to your Stash account.  Click your picture in the upper right, and select Manage Account.  In the left menu, select SSH Keys and add your key.

Now you'll need your development machine to be able to connect to Stash.  Follow the Accepting the Certificate instructions at the bottom of this wiki

### Migration

You can follow instructions here: http://git-scm.com/book/en/Git-and-Other-Systems-Migrating-to-Git
Or you can follow along with my example import of gcmrc-ui-parent below.

#### Step 1: Pull your repo from SVN

```
git svn clone https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/ --authors-file=cidaSvnUsers.txt --no-metadata -s gcmrc-ui-parent
```

This is a standard git svn clone with a couple of extras on here.  

* [The Authors file](#the-authors-file) is a compiled list of SVN users with their email addresses mapped.
  * You can pick up a complete list here: [cidaSvnUsers.txt](../cidaSvnUsers.txt)
* `--no-metadata` just removes the ugly git-svn-id hash from every commit message.
* `-s` means standard layout.  CIDA projects usually have a standard layout.  Standard layout means these folders exist:

```
https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/trunk/
https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/tags/
https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/branches/
```

* if those folders don't actually match up to the folders you use you may want to use the `--trunk <arg> --tags <arg> --branches <arg>` options

#### Step 2: Clean up your tags and branches

```
cd gcmrc-ui-parent/
git for-each-ref refs/remotes/tags | cut -d / -f 4- | grep -v @ | while read tagname; do git tag "$tagname" "tags/$tagname"; git branch -r -d "tags/$tagname"; done
git for-each-ref refs/remotes | cut -d / -f 3- | grep -v @ | while read branchname; do git branch "$branchname" "refs/remotes/$branchname"; git branch -r -d "$branchname"; done
```

Change directory to your project's root directory, then run those two commands verbatim.  The first one move the svn tags from the `refs/remotes/tags/im-a-tag` ref to being actual tags within git, then removes those old refs.  The second one just renames the branches to normal branch names and removes the old ones.  This is where the magic happens, and makes your project look like it's always been tracked by git.

#### Step 3: Create A Project and a Repository in Internal Stash

Go to http://cida-eros-stash.er.usgs.gov:7990/stash/projects and create your project using the "Create Project" button at the top.  I'll create the GCMRC Project.  Click on the link to your project, and now you're here http://cida-eros-stash.er.usgs.gov:7990/stash/projects/GCMRC  Click on the "Create Repository" button at the top.  It will ask for a name for your repository.  I'll use the same name as was used in SVN: gcmrc-ui-parent.  You'll now be greeted by a "You have an empty repository" page.  Now we're ready to push our local git repository to Stash.

#### Step 4: Push your local git repository to Stash

In your projects root directory we'll want to run these commands:

```
git remote add origin ssh://git@cida-eros-stash.er.usgs.gov:7999/gcmrc/gcmrc-ui-parent.git
git push origin --all
git push origin --tags
```

You'll notice that we got that first line from the "You have an empty repository" page,  Feel free to grab yours from there too.  just don't grab the one down at the bottom where it says "git remote set-url origin" as you don't have a remote yet.

#### Step 5: Bask in your success

http://cida-eros-stash.er.usgs.gov:7990/stash/projects/GCMRC/repos/gcmrc-ui-parent/browse

Look at it.  It's beautiful.  You did that.  Take a moment, explore and enjoy that.

#### Step 6: Set up your new repository for development

Alright, get off your butt, we're not done yet.  That repository on your local computer is still set up under git-svn, let's get rid of that and set it up under Stash.

```
cd ..
rm -rf gcmrc-ui-parent/
```

Your fancy new Stash repository page has a couple of essential buttons at the top left: Clone, Fork and Pull Request.  If you're familiar with GitHub, these do the same things.  Right now we're interested in the Fork button.  We want to fork this repository to our personal account.  I've clicked the fork button and gotten myself to 

http://cida-eros-stash.er.usgs.gov:7990/stash/users/dmsibley/repos/gcmrc-ui-parent/browse

now when I click the clone button it gives me the address of `ssh://git@cida-eros-stash.er.usgs.gov:7999/~dmsibley/gcmrc-ui-parent.git`  We'll use that to set up our new local repo

```
git clone ssh://git@cida-eros-stash.er.usgs.gov:7999/~dmsibley/gcmrc-ui-parent.git
```

Oh sweet, there it is!  Lets get in there and set it up to be able to pull from the canonical repo

```
cd gcmrc-ui-parent
git remote add upstream ssh://git@cida-eros-stash.er.usgs.gov:7999/gcmrc/gcmrc-ui-parent.git
```

And we're done.
Note: Don't forget about Jenkins jobs and Maven plugins!
Odds are there are some Jenkins jobs relating to the project you just moved. They'll need to be updated to pull from the git repository! Also, as most of these SVN projects are older, they may have outdated maven plugins in their build. The maven-release-plugin in Jenkins now handles the entire process so you won't need maven-build-number and other plugins defined in your POM anymore. Also, the SCM tag in the POM should be updated to point to the git repo instead of the SVN one.

### Full process from the command line:

```
git svn clone https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/ --authors-file=cidaSvnUsers.txt --no-metadata -s gcmrc-ui-parent
cd gcmrc-ui-parent/
git for-each-ref refs/remotes/tags | cut -d / -f 4- | grep -v @ | while read tagname; do git tag "$tagname" "tags/$tagname"; git branch -r -d "tags/$tagname"; done
git for-each-ref refs/remotes | cut -d / -f 3- | grep -v @ | while read branchname; do git branch "$branchname" "refs/remotes/$branchname"; git branch -r -d "$branchname"; done
git remote add origin ssh://git@cida-eros-stash.er.usgs.gov:7999/gcmrc/gcmrc-ui-parent.git
git push origin --all
git push origin --tags
cd ..
rm -rf gcmrc-ui-parent/
git clone ssh://git@cida-eros-stash.er.usgs.gov:7999/~dmsibley/gcmrc-ui-parent.git
cd gcmrc-ui-parent
git remote add upstream ssh://git@cida-eros-stash.er.usgs.gov:7999/gcmrc/gcmrc-ui-parent.git
```

### Accepting the Certificate
In order for your Jenkins machine to contact stash via ssh, you'll need Stash to know your tomcat's ssh public key.
Ask someone who has the Jenkins user credentials for stash to add your tomcat's public key (Sibley or Ivan are your best bets).
Next run this command from the Jenkins machine terminal:

```
ssh -T -p 7999 git@cida-eros-stash.er.usgs.gov
```

It will ask you to type 'yes' and hit enter, then give you this message

```
shell request failed on channel 0
```

That means success.
 
### The Authors File

 The git svn clone will fail if there is a committer in history that is not in that authors file, so we would have to edit this file every time there is a new committer to svn.
 
the file attached to this document was generated using

```
svn log https://cida-svn.er.usgs.gov/repos/dev/usgs/ --xml | grep -P "^<author" | sort -u | perl -pe 's/<author>(.*?)<\/author>/$1 = /' > users.txt
```

and then manually edited to add in emails and names.
 
The thing about this is that you don't necessarily have to use/edit the file of the whole repo.  If I'm importing gcmrc-ui-parent and I notice that a new guy has made some commits to it, I can run my own users file (that will run a LOT quicker) on the project.

```
svn log https://cida-svn.er.usgs.gov/repos/dev/usgs/gcmrc/gcmrc-ui-parent/ --xml | grep -P "^<author" | sort -u | perl -pe 's/<author>(.*?)<\/author>/$1 = /' > users.txt
```

and then manually edit that for the 5 or 6 users that are in there.
