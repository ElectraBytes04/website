=====================
SLATE Package Manager
=====================
.. class:: sub

2026-01-27

------

::

      /~~~\     /         /~~~\     /~~~\     /~~~\
      |         |         |   |       |       |
      \\\\\     |         >===<       |       >===
          |     |         |   |       |       |
      \~~~/     \~~~/     \   /       |       \~~~/

SLATE is a package manager that allows users to install packages without
requiring root privilege.


Environment
```````````
``$SLATE_DATA_DIR`` (%slate/): ``/var/slate/`` for system and
``$HOME/.local/slate/`` for users by default.

``$SLATE_CONFIG_DIR`` (%conf/): ``/etc/slate/`` for system and
``$HOME/.config/slate/`` for users by default.

%slate/ hierarchy::

      |-> ./book/ (recipe files (.slate or .rec) are stored here.)
      | '-> ./example.slate (file showing examples of recipes.)
      |
      |-> ./install/ (packages are unpacked here, built, and then cleared out.)
      |-> ./buildfs/ (tier 2 packages are built here before moving to host.)
      |-> ./runtimefs/ (tier 3 packages are built / installed here.)
      |
      |-> ./infos (file containing package metadata.)
      '-> ./lock (lock file)


System
``````
Tiers:

- 1: (Native) Built and installed on host.
- 2: (Hybrid) Built in container, installed on host.
- 3: (Container) Built and installed in container.

Scopes:

- public: Everyone (with access to parent directory) can see and execute.
  Installed executables have 755.

- private: Only owner and members of owner's group can execute. Installed
  executables have 750. This does not this does not affect user configs.

Infos file::

      # %slate/infos: Package information
      #
      # package version tier scope {
      # runtime_dependency version
      # runtime_dependency version
      # }

Example recipe file for a tier 1 package::

      NAME="BusyBox 1.36.1"
      SOURCE="https://busybox.net/downloads/busybox-1.36.1.tar.bz2"

      TIER=1
      SCOPE="public"

      BDEPS="musl GCC Make"

      patch()
      {
            return 0
      }

      build()
      {
            make defconfig
            sed -i 's/^CONFIG_TC/#CONFIG_TC/' .config
            make
            return 0
      }

      install()
      {
            make install
            return 0
      }

If SLATE cannot find recipe files corresponding to the BDEPS / RDEPS, it will
stop and ask the user if the dependencies are already installed. If the user
says no, then SLATE will request that the user provide recipe files or install
the dependencies manually.
