This is *HUMONGOUS* CP/M's restored version of the SIG/M archives.

Founded in May 1975, the Amateur Computer Group of New Jersey (ACGNJ) is
dedicated to the amateur computer hobby. For many years its Special Interest
Group/Microprocessors (SIG/M)  maintained a library of CP/M software
released on a series of disks.

The SIG/M software collection is still available today from several sources.
However, most of them are incomplete, and/or exhibit signs of accretion or
corruption (e.g., the Walnut Creek CD contains a SIG/M collection which
lacks several volumes, has additional files added to each volume, and whose
files no longer match the supplied CRC values).

This is the *HUMONGOUS* CP/M Archives' attempt to restore the SIG/M
collection to as nearly original condition as possible. In brief, the goal
is to precisely match the file lists and CRC values supplied in each
volume's -CATALOG listing.

This goal has, I believe, been almost entirely achieved, and is presented
here, in several formats: in expanded directories, and packaged as .ARK,
.LBR and IBM-3740 format .DSK images.

_SUPPORT

The _support subdirectory contains a number of files, most importantly
buildvol, the BASH shell script used to build this collection. You may use
this script to rebuild the collection yourself, if you're so inclined (read
the comments in that file for further information). But the most up-to-date
version can be obtained from Github at:

https://github.com/CPMArchives/SIGM

If you wish to rebuild the entire collection in one fell swoop, copy
_support/ to a writeable directory, download the ISO files (see notes in
buildvol), then just run _support/buildall.

Also included is -CATALOG.ALL which is a rebuilt-from-scratch version of the
individual -CATALOG listings offering a complete list of SIG/M contents.