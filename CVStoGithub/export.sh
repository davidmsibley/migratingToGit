#!/bin/bash
CVS_HOSTNAME=$1
REPOSITORY=$3
REPOSITORY_DIR=$2$REPOSITORY
GIT_REPO_NAME=$4
MAKE_AUTHORMAP=$(echo $0 | sed -r s/export\.sh$/mkAuthormap.sh/)
CVS_FAST_EXPORT_DIR=$5

ssh $CVS_HOSTNAME "tar cvf - $REPOSITORY_DIR | gzip > export.tar.gz"
ssh $CVS_HOSTNAME "bash -s" < $MAKE_AUTHORMAP $REPOSITORY_DIR
scp $CVS_HOSTNAME:~/export.tar.gz .
scp $CVS_HOSTNAME:~/authormap .
ssh $CVS_HOSTNAME "rm -f export.tar.gz"
ssh $CVS_HOSTNAME "rm -f authormap"
tar xzvf export.tar.gz
find .$REPOSITORY_DIR -name '*,v' -print | $CVS_FAST_EXPORT_DIR/cvs-fast-export -A authormap > web-fast-export
mkdir $GIT_REPO_NAME
cd $GIT_REPO_NAME
git init
cat ../web-fast-export | git fast-import
git checkout