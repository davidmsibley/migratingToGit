# Migrating your project from SVN to Git on Github

### Setting Up

In order to commit and pull from Github, your development machine will need ssh keys.  Follow this tutorial:
https://help.github.com/articles/generating-ssh-keys

Once you've generated your ssh key, you'll need to add it to your Github account.  Click your username in the upper right, and click Edit Profile.  In the left menu, select SSH Keys and add your key.

Now you'll need your development machine to be able to connect to Github.  Follow the Accepting the Certificate instructions at the bottom of this wiki

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

#### Step 3: Create A Repository on Github

Go to https://github.com/ and make sure you're logged in. In the upper right hand corner of the screen, there should be a `+` icon that drops down with a choice for "New Repository".  Using that, I'll create the GCMRC Project.  Specify the name and description of your new repository, and skip the dropdowns at the bottom (we'll be importing an exisiting repo).

#### Step 4: Push your local git repository to Github

In your projects root directory we'll want to run these commands:

```
git remote add origin git@github.com:davidmsibley/gcmrc-ui-parent.git
git push origin --all
git push origin --tags
```

You can find the remote url on the right side of your repository view.

#### Step 5: Bask in your success

https://github.com/davidmsibley/gcmrc-ui-parent

Look at it.  It's beautiful.  You did that.  Take a moment, explore and enjoy that.

#### Step 6: Set up your new repository for development

Alright, get off your butt, we're not done yet.  That repository on your local computer is still set up under git-svn, let's get rid of that and set it up under Github.

```
cd ..
rm -rf gcmrc-ui-parent/
git clone git@github.com:davidmsibley/gcmrc-ui-parent.git
```

At this point, if you're importing a CIDA Project, I'd suggest letting Sibley or Ivan know, and they'll set you up on the transfer team.  You'll push your repository over to the USGS-CIDA Organization and at the end of the process, you'll be able to add that repository as an upstream remote like so:

```
cd gcmrc-ui-parent
git remote add upstream git@github.com:USGS-CIDA/gcmrc-ui-parent.git
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
git remote add origin git@github.com:davidmsibley/gcmrc-ui-parent.git
git push origin --all
git push origin --tags
cd ..
rm -rf gcmrc-ui-parent/
git clone git@github.com:davidmsibley/gcmrc-ui-parent.git
cd gcmrc-ui-parent
git remote add upstream git@github.com:USGS-CIDA/gcmrc-ui-parent.git
```

### Accepting the Certificate
In order for your Jenkins machine to contact stash via ssh, you'll need Stash to know your tomcat's ssh public key.
Ask someone who has the Jenkins user credentials for stash to add your tomcat's public key (Sibley or Ivan are your best bets).
Next run this command from the Jenkins machine terminal:

```
ssh -T git@github.com
```

It will ask you to type 'yes' and hit enter, then give you this message

```
Hi davidmsibley! You've successfully authenticated, but GitHub does not provide shell access.
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
