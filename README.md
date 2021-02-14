# ibmibashscripts
This repository will be a home for useful bash scripts on IBM i.

This is a learning experience so gentle feedback and your favorite IBM i bash examples would be nice to put here.

One thing you will notice is that I like verbose documentation :-)

Feel free to submit requests or input in the Issues section as well

## ibmibashtemplate.sh
This bash script can serve as a good starter template for your bash scripts. 

## savlibifs.sh
Save IBM i Library to IFS based Save File

## rstlibifs.sh
Restore IBM i Library from IFS based Save File

## cpysrctoifs.sh - Copy Source Member from Library to IFS File
Copy source member to IFS file path from library with minimal parameter entry.  
**P1** - Source from IFS file name (no dir path) from within the specifed IFS directory in bash or other PASE shell.
**P2-Optional** - Replace source member in library. [Y/N] Default :Y

Example to copy a source file member from QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing

```
cd /gitrepos/QGPL/QCLSRC
cpysrctoifs.sh SAMPLE.CLP
```

## cpyifstosrc.sh - Copy IFS File to Source Member in Library
Copy IFS source member to source member in library with minimal parameter entry.  
**P1** - Source from IFS file name (no dir path) from within the specifed IFS directory in bash or other PASE shell. Destination library/file.member is automatically derived from the IFS directory path structure.  Ex: /gitrepos/srclibrary/srcfile/srcmember.srctype  
**P2-Optional** - Replace source member in library. [Y/N] Default :Y

Example to copy an IFS file to source file member QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing

```
cd /gitrepos/QGPL/QCLSRC
cpyifstosrc.sh SAMPLE.CLP
```
