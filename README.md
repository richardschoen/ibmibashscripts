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

## Editing IBM i Source Members using Visual Studio Code or other editors
IBM i developers who are using Visual Studio Code, Notepad++ and other PC based editors to edit source code can now more easily edit source members that originate from an IBM i source file instead of directly out of the IFS.

The **cpysrctoifs.sh** bash script can be used to quickly copy a library based source member to an IFS file where it can be directly edited with VS Code, etc. Simply change to the directory where the source member resides and run te script with the source member IFS file name.

Example to copy a source file member from QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing 
```
Sample bash/PASE command line sequence to copy from source file to IFS location:
cd /gitrepos/QGPL/QCLSRC
cpysrctoifs.sh SAMPLE.CLP

Note: Once your current directory is set to the appropriate directory in the terminal (via cd /dirpath)   
you don't need to use the cd operation again until you want to change to another source directory in the IFS.
```
The **cpyifstosrc.sh** bash command can be used to copy an IFS file edited by VS Code, etc back to a library based source member after editing. Simply change to the directory where the source member resides and run te script with the source member IFS file name.

Example to copy an IFS file named: /gitrepos/QGPL/QCLSRC/SAMPLE.CLP to source file member QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing
```
Sample bash/PASE command line sequence to copy from IFS location to source file:
cd /gitrepos/QGPL/QCLSRC
cpyifstosrc.sh SAMPLE.CLP

Note: Once your current directory is set to the appropriate directory in the terminal (via cd /dirpath)   
you don't need to use the cd operation again until you want to change to another source directory in the IFS.
```

## cpysrctoifs.sh - Copy Source Member from Library to IFS File
Easily copy source member to IFS file path from library with minimal parameter entry for editing with Visual Studio Code, Notespad++ or other editors that can open and save IFS files.

**P1** - Destination IFS file name (no dir path needed) entered in bash or other PASE shell. Source from library/file.member is automatically derived from the IFS directory path structure.  
(Ex: /gitrepos/srclibrary/srcfile/srcmember.srctype = Source Library: srclibrary, Source File: srcfile, Source member: srcmember, Source type: srctype )  
Note: The IFS directory used, does NOT have to be a Git repository unless you are using Git in the IFS.  

**P2-Optional** - Replace destination IFS file. [Y/N] Default :Y

Example to copy a source file member from QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing 
```
Sample bash/PASE command line sequence to copy from source file to IFS location:
cd /gitrepos/QGPL/QCLSRC
cpysrctoifs.sh SAMPLE.CLP

Note: Once your current directory is set to the appropriate directory in the terminal (via cd /dirpath)   
you don't need to use the cd operation again until you want to change to another source directory in the IFS.
```

## cpyifstosrc.sh - Copy IFS File to Source Member in Library
Easily copy IFS source member to source member in library with minimal parameter entry after editing with Visual Studio Code, Notepad++ or other editors that can open and save IFS file. 

**P1** - From IFS file name (no dir path needed) entered in bash or other PASE shell. Source from library/file.member is automatically derived from the IFS directory path structure.  
(Ex: /gitrepos/srclibrary/srcfile/srcmember.srctype = Source Library: srclibrary, Source File: srcfile, Source member: srcmember, Source type: srctype )  
Note: The IFS directory used, does NOT have to be a Git repository unless you are using Git in the IFS.  

**P2-Optional** - Replace source member in library. [Y/N] Default :Y

Example to copy an IFS file named: /gitrepos/QGPL/QCLSRC/SAMPLE.CLP to source file member QGPL/QCLSRC(SAMPLE), Type: CLP to relative IFS output path for editing
```
Sample bash/PASE command line sequence to copy from IFS location to source file:
cd /gitrepos/QGPL/QCLSRC
cpyifstosrc.sh SAMPLE.CLP

Note: Once your current directory is set to the appropriate directory in the terminal (via cd /dirpath)   
you don't need to use the cd operation again until you want to change to another source directory in the IFS.

```
