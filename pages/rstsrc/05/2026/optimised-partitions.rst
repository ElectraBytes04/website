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
