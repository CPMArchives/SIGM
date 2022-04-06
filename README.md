# SIGM
### PREFACE

The **Special Interest Group/Microcomputers** is a still-active users' group of the **_Amateur Computer Club_ of New Jersey**. Originally formed in the late 1970s, through 1988 it frequently released software distribution disks of software dedicated to 8-bit computing, primparily under the **CP/M** operating system and its later derivatives. Its software library eventually became one of the most important of the era.

Versions of the SIG/M library are still available from a number of sources on the Internet, subject, however, to a large number of accretions and corruptions, and none of the collections is complete (nearly all, for example, omit volumes 184-192). This project, therefore, aims to recreate as closely and cleanly as possible an "original" version of the library, with as many of the various accretions, omissions and corruptions fixed as possible.

This is a BASH shell script which will create a series of directories -- sigmv001/, sigmv002/, etc. -- each of which holds the contents of the corresponding SIG/M volume, as well as .ARK and .LBR CP/M archives, and .DSK files, which are IBM-3740-format disk images intended for use in **CP/M** emulators.

### USAGE

To run this script, place **buildvol** somewhere on your system. Read its comments for details. Download the ISO images and make sure you have all the required utilities installed and available in your system path. Then edit two variables in the VARIABLES section: **$iso_loc** and **$buildroot**. You can now build a single volume; e.g.:
```
./buildvol 228
```
Or the entire collection (on my system this takes a bit over five minutes):
```
for i in {1..310}; do ./buildvol $i; done
```
