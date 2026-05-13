====================================
[Notes] Partitioning Digital Storage
====================================
.. class:: sub

2026-05-11

------

TL;DR:

- Convert your device's capacity to binary units
- Align partitions to MiB (first partition starting at 1MiB)
  (that's *MeBi*bytes, not *Mega*bytes)
- Make sure a partition has enough space for necessary filesystem headers (LUKS2
  headers require ~16MiB).


Convert your device's capacity to binary units.
```````````````````````````````````````````````
*Computers (like that storage device of yours) work in binary units* (powers of
2), rather than decimal units (powers of 10). It's a good idea to switch your
units to binary so that you know just how much space you're working with.


Align partitions to MiB.
````````````````````````
Storage devices write and erase data based on their specific "write block size"
(WBS) and "erase block size" (EBS), respectively. If these values are known,
then storage can be aligned to the greatest common factor of the WBS and EBS.
I'll call that the "alignment unit" for now.

For example, if the storage is aligned to this "alignment unit" (let's say,
4KiB), and we do a write of 4KiB. Any data written to it lines up with erase
block *and* write block boundaries. The device would be able to write to the
exact number of blocks requested.

However, if the storage is *not* aligned, and that same write happens to
straddle two write blocks, 8KiB must be written for 4KiB of useful work. It goes
the same way for erase blocks, so when erasing that 4KiB of data, 8KiB is
erased.

Most devices don't directly tell what their WBS and EBS are, so 1MiB has been
used as a good estimate for our "allignment unit" that works for nearly all
modern devices.

Further reading `here <ref1_>`_.


Leave space for necessary filesystem headers.
`````````````````````````````````````````````
This one's self explanatory. Just make sure you know how much space your desired
filesystem requires *before* making the partition.

.. _ref1:
  https://www.reddit.com/r/linuxquestions
  /comments/18sweu7/im_very_confused_regarding_partition_alignment/
