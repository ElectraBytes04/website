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

SLATE is a minimal, source-based package management program with an ability to
do rootless installs. It assumes users are already comfortable operating in the
underlying system and know how to build packages from source. SLATE's recipe
files are easy to read, edit, and share by design.

SLATE is intended to be small. Where the spec is silent, behaviour is
implementation-defined.

Things like querying SLATE-installed packages, removing a package, and purging
packages are not included. This is because the structure of
``SLATE_DATA_DIR/db`` and ``SLATE_DATA_DIR`` itself makes these trivially
simple. Examples of each:

- List SLATE-installed packages (also gives most recent install time): ``ls
  $SLATE_DATA_DIR/db``
- Remove a SLATE-installed package from the system::

      find "$SLATE_DATA_DIR/db/{name=version}" -type l | while read -r f
      do
            rm "$(readlink "$f")" "$f"
      done

      rm -rf "$SLATE_DATA_DIR/db/{name=version}"

- Purge a SLATE-installed package from the system::

      find "$SLATE_DATA_DIR/db/{name=version}" -type l | while read -r f
      do
            rm "$(readlink "$f")" "$f"
      done

      rm -rf "$SLATE_DATA_DIR/db/{name=version}"
      rm "$SLATE_DATA_DIR/book/{name=version}.slate"

Synopsis
````````
``slate [-n] [-i install_to] package ...``


Options
```````
The following options shall be supported:

``-n``
      Suppress interactive prompts.

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
      The package name to be installed. If ``package`` is '-', then ``slate``
      will accept package names from the standard input at that point in the
      sequence. A package name must match a ``.slate`` file in
      ``SLATE_DATA_DIR/book``, without the ``.slate`` extension. A package name
      must be something like: ``package=version``, where the version is included
      after an equals sign.


Input Files
```````````
The input file(s) shall be shell script(s). The input file(s) should contain (at
least) the variables:``SSOURCE``, ``SPRIVATE``, ``SBDEPS``, ``SRDEPS``.


Environment Variables
`````````````````````
The following environment variable shall affect the execution of 
``slate``:

``SLATE_DATA_DIR``
      Provides the path to the folder where ``slate`` will find recipes,
      the lock file, and its database of installed packages. If not set,
      then ``slate`` will use ``/var/slate`` when effective uid is 0 (root), and
      ``$HOME/.local/slate`` otherwise.
``SLATE_SOURCE_HANDLERS``
      Provides a list of file (and protocol) handlers that ``slate`` will use to
      extract package archives. If ``SLATE_SOURCE_HANDLERS`` is empty, or a
      tool that is required isn't available, then ``slate`` will treat provided
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
      their own directory (named after the filename of the recipe, excluding the
      ``.slate`` extension), which mirrors the final install layout. Package
      metadata (runtime dependencies (if specified)) is stored in a ``meta``
      file in the package's directory. Package build dependencies are excluded,
      as they do not matter for the actual execution, and could be removed after
      install without issue. The ``meta`` file is formatted such that each item
      is on its own line::

            runtime dependency 1=runtime dependency 1's version
            runtime dependency 2=runtime dependency 2's version
            runtime dependency 3=runtime dependency 3's version
            ...

      A package's installed files shall be symlinked to the final destination
      (``install_to/(bin/, lib/, etc.)``, ``$HOME/.local/(bin/, lib/, etc.)``,
      ``/(bin/, lib/, etc.)``) from ``db/{package}``.

      ``install`` is simply a scratchpad for installing packages. Package
      archives are moved here before operation, installed to ``db/{package}``,
      and then cleared out. ``install`` shall be cleared before each package
      install, too. Recipe functions are executed on a package's source
      tree here.

      During operation, ``slate`` shall atomically create a lock file (named
      ``lock``) in ``SLATE_DATA_DIR``. This file is deleted when ``slate``
      exits. If ``slate`` is executed while the ``lock`` file exists, then
      ``slate`` shall do nothing and exit with ``2``. A stale lock file can be
      safely removed by the user.

**Recipe Files**
      It is important that recipes are easy to find and edit. A user should be
      able to edit a recipe to fit their system when needed.

      A given recipe file should contain at least the variables: ``SSOURCE``,
      ``SPRIVATE``, ``SBDEPS``, ``SRDEPS``. They are not required, however, as
      they will default to empty strings if not set, but the ``meta`` file will
      contain no, or useless, data. The variables refer to the following:

      - ``SSOURCE``: where this package's source can be found on the system
        (absolute path), or a remote URL pointing to this package's source.
      - ``SPRIVATE``: if 1, ``umask`` shall be set to mode 077 during package
        installation (``- rw- --- ---``). Else, this package's installed files
        will be whatever the ``umask`` is when ``slate`` is executed.
      - ``SBDEPS``: a space-separated list of package names that this package
        relies on to be installed properly. Dependency versions should also be
        specified with the form ``package=version``. SBDEPS shall be installed
        to the currently-being-installed package's source tree, and added to a
        temporary PATH for use during the build, but not installed to the host
        system.
      - ``SRDEPS``: a space-separated list of package names that this package
        relies on to be executed properly. Dependency versions should also be
        specified with the form ``package=version``.

      A given recipe file should also define at least the functions:
      ``patch()``, ``build()``, and ``install()``. They are not required,
      however, as ``slate`` shall default to the following definitions::

            patch()
            {
                  printf "No patches to be applied.\n" && return 0;
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

      If ``SBDEPS`` and/or ``SRDEPS`` are set, and recipe files corresponding to
      those packages do not exist, or the package does not seem to be installed
      on the system, then a prompt will be sent to STDOUT, asking the user if
      the dependencies are already installed. If the user responds no, then the
      user will be requested to provide the relevant recipe files or to install
      the dependencies manually. This behaviour is affected by the ``-n``
      option, where no prompt will be sent to STDOUT and the current package
      install shall be halted.

      The method of finding dependencies on the system is
      implementation-defined. Usually, an educated guess can work.

      To verify dependency versions, a simple check akin to ``a == b`` shall be
      used.

      Circular dependencies shall be detected by keeping a running list of
      visited recipes, and their version. If a recipe matching this name and
      version has already been visited, then the package install shall be
      halted.

      ``SSOURCE`` shall be matched by substring against handlers specified in
      ``SLATE_SOURCE_HANDLERS`` such that a source like:
      ``https://example.com/file.tar.xz`` is handled in the order of: ``wget``,
      then ``xz``, then ``tar``, when ``SLATE_SOURCE_HANDLERS`` is::

            xz:xz,https:wget -q,tar:tar -x

      The flow of data between handlers in ``SLATE_SOURCE_HANDLERS`` is
      implementation-defined.

**Errors**
      Error messages are intentionally minimal, and most package errors should
      be fixable by editing the relevant package or metadata file. In the case
      where installing a package from a recipe fails, ``slate`` shall not
      attempt to fix the error, and should instead simply halt the install and
      move to the next one.


Exit Status
```````````
The following exit values shall be returned:

``0``
      All packages were installed successfully.
``1``
      One or more packages failed. Generic error.
``2``
      Program misuse. Bad option, missing operand, lock file exists, etc.
