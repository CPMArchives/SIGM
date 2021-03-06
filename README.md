# SIGM
### PREFACE

The **Special Interest Group/Microcomputers** is a still-active users' group of the **_Amateur Computer Club_ of New Jersey**. Originally formed in the late 1970s, through 1988 it frequently released software distribution disks of software dedicated to 8-bit computing, primarily under the **CP/M** operating system and its later derivatives. Its software library eventually became one of the most important of the era.

Versions of the SIG/M library are still available from a number of sources on the Internet, subject, however, to a large number of accretions and corruptions, and none of the collections is complete (nearly all, for example, omit volumes 184-192). This project, therefore, aims to recreate as closely and cleanly as possible an "original" version of the library, with as many of the various accretions, omissions and corruptions fixed as possible.

### BUILDVOL

This is a BASH shell script which will rebuild SIG/M volumes, pulling from the extant sources. It creates a series of directories -- sigmv001/, sigmv002/, etc. -- for each volume, as well as .ARK and .LBR CP/M archives, and .DSK files, which are IBM-3740-format disk images intended for use in **CP/M** emulators.

#### USAGE

Before running this script, you must download the required iso files (read the script source for download links) and place them all in a directory on your system. By default, this script will look for the ISOs, and build SIGM, in the currently logged directory. To change this, set two environment variables: 

```
export iso_loc=/path/to/ISOs
export buildroot=/where/to/build/SIGM
```

You can now build a single volume; e.g.:
```
./buildvol 228
```
Or the entire collection (on my system this takes a bit over five minutes):
```
for i in {1..310}; do ./buildvol $i; done
```

### LIST

This second script will produce a file listing reminiscent of SIG/M's -CATALOG listings. This script will only run from the directory where your rebuilt SIG/M collection is. You must specify the volume:

```
./list 167
```

#### -CATALOG.ALL

-CATALOG.ALL is a cleaned-up, prettified compilation of all the individual -CATALOG.xxx files, providing details of the contents of each volume.
