# CVS To git Migration

## Usage

```console
export.sh <CVS Hostname> <Project Parent Directory> <Project Root Directory Name> <github username> <git repo name> <cvs_fast_export directory>
```

First create an empty repository in your user on github, and run the export.sh with the repository name.

you may have to edit export.sh

```console
mkdir corenwis-migration
cd corenwis-migration
../export.sh nwiscvs.er.usgs.gov /nwiscvs/nwis/NwisJava/ corenwis davidmsibley corenwis ../../cvs-fast-export-1.29
```