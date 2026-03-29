=====================
SLATE Package Manager
=====================
.. class:: sub

2026-03-27

------

::

      /===\  /      /===\  /===\  /===\
      |      |      |   |    |    |
      \===\  |      |===|    |    |===
          |  |      |   |    |    |
      \===/  \===/  \   /    |    \===/
      
      STALE  LEMONS ALWAYS TURN   EXOTHERMIC

SLATE is a package manager that allows users to install packages without
requiring root privilege.

Synopsis
````````
``slate [-n] [-i install_to] package ...``


Options
```````
The following options shall be supported:

``-n``
      Supress interactive prompts.

``-i install_to``
      The final destination of installed files will be ``install_to``. If not
      specified then the final destination of installed files will depend on
      whether or not ``slate`` was executed as root. If not executed as root,
      then installed files should go to ``$HOME/.local/`` and in that
      directory's ``bin/``, ``lib/``, etc. If executed as root, then installed
      files will go to the root-level (``/``), in ``/bin/``, ``/lib/``, etc.


Operands
````````
The following operand shall be supported:
``package``
      The package name to be installed. If ``package`` is '-' or empty, then
      ``slate`` will accept package names from the standard input at that point
      in the sequence.


Input Files
```````````
The input file(s) shall be shell script(s). The input file(s) should contain (at
least) the variables: ``VERSION``, ``SOURCE``, ``PRIVATE``, ``BDEPS``,
``RDEPS``.


Environment Variables
`````````````````````
The following environment variable shall affect the execution of 
``slate``:
``SLATE_DATA_DIR``
      Provides the path to the folder where ``slate`` will find recipes,
      the lock file, and its database of installed packages. If not set,
      then ``slate`` will use ``$HOME/.local/slate``.
``SLATE_SOURCE_HANDLERS``
      Provides a list of file (and protocol) handlers that ``slate`` will use to
      extract package archives. If ``SLATE_SOURCE_HANDLERS`` is empty, or a tool
      that is required isn't available, then ``slate`` will treat provided
      package archives as directories. This environment variable should be in
      the form::

            key:value,key:value,key:value,...


Extended Description
````````````````````

**The Data Directory**
      ``SLATE_DATA_DIR`` must contain at least the following directories::

            |-> ./book/
            |-> ./db/
            '-> ./install/

      ``book`` stores text-based recipe files, with the file extension
      "``.slate``".

      ``db`` stores a package's installed files and metadata. Packages have
      their own directory (named after the filename of the recipe), which
      contains all files that a package installs (within relevant directories
      (``bin/``, ``lib/``, etc.). Package metadata (version, runtime
      dependencies (if specified)) is stored in a ``meta`` file in the package's
      directory. Package build dependencies are excluded, as they do not matter
      for the actual execution, and could be removed after install without
      issue. The ``meta`` file is formatted such that each item is on its own
      line::

            version
            runtime dependency 1=runtime dependency 1's version
            runtime dependency 2=runtime dependency 2's version
            runtime dependency 3=runtime dependency 3's version
            ...

      ``install`` is simply a scratchpad for installing packages. Package
      archives are moved here before operation, installed to ``db/{package}``,
      and then cleared out.

      During operation, ``slate`` shall create a lock file (named ``lock``) in
      ``SLATE_DATA_DIR``. This file is deleted when ``slate`` exits. If
      ``slate`` is executed while the ``lock`` file exists, then ``slate`` shall
      do nothing and exit with ``2``.

**Recipe Files**
      A given recipe file should contain at least the variables: ``VERSION``,
      ``SOURCE``, ``PRIVATE``, ``BDEPS``, ``RDEPS``. They are not required,
      however, as they will default to empty strings if not set, but the
      ``meta`` file will contain no, or useless, data. The variables refer to
      the following:

      - ``VERSION``: the version of this package.
      - ``SOURCE``: where this package's source can be found on the system
        (absolute path), or a remote URL pointing to this package's source.
      - ``PRIVATE``: if 1, this package's installed files will be mode 700
        (``rwx --- ---``). Else, this package's installed files will be whatever
        the ``umask`` is.
      - ``BDEPS``: a space-separated list of package names that this package
        relies on to be installed properly. Dependency versions should also be
        specified with the form ``package=version``.
      - ``RDEPS``: a space-separated list of package names that this package
        relies on to be executed properly. Dependency versions should also be
        specified with the form ``package=version``.

      A given recipe file should also define at least the functions:
      ``patch()``, ``build()``, and ``install()``. They are not required,
      however, as ``slate`` shall default to the following definitions::

            patch()
            {
                  return 0;
            }

            build()
            {
                  printf "Hello, world!\n" && return 0;
            }

            install()
            {
                  printf "I'm not installing anything.\n" && return 0;
            }

      ``slate`` shall only execute those three functions (``patch()``,
      ``build()``, ``install()``) in any given recipe and shall only execute
      them in that order.

      If ``BDEPS`` and/or ``RDEPS`` are set, and recipe files corresponding to
      those packages do not exist, then a prompt will be sent to STDOUT, asking
      the user if the dependencies are already installed. If the user responds
      no, then the user will be requested to provide the relevant recipe files
      or to install the dependencies manually. This behaviour is affected by the
      ``-n`` option, where no prompt will be sent to STDOUT and the current
      package install shall be halted.

      To verify dependency versions, a simple check akin to ``a == b`` shall be
      used.

      Circular dependencies shall be detected by keeping a running list of
      visited recipes, and their version. If a recipe matching this name and
      version has already been visited, then the package install shall be
      halted.

      ``SOURCE`` shall be checked against handlers specified in
      ``SLATE_SOURCE_HANDLERS`` such that a source like:
      ``https://example.com/file.tar.xz`` is handled in the order of: ``wget``,
      ``xz``, ``tar``, when ``SLATE_SOURCE_HANDLERS`` is::

            https:wget,xz:xz,tar:tar

Exit Status
```````````
The following exit values shall be returned:

``0``
      All packages were installed successfully.
``1``
      Some packages were installed successfully.
``2``
      No packages were installed successfully.
