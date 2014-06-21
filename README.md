stage
=====
- a simple dependency based service manager and init system

written in and for bash (bash version >= 4.2)
inspired by minirc, serman, systemd

intented to be used w/ sinit
intented for simple, non-critical setups

Features
--------

- simple dependency resolving
- simple service files
- "stages" to group services
- parallel execution of services
- a few "convenience functions"
- no service supervision
- no inittab
- transparent (bash scripts)
- easy to debug (bash scripts)


Usage
-----

While providing init functions it could also be used to simply
manage services.

### Services

Service files are entirely optional, as are the functions in there.

By default all service files are expected in /etc/stage/service_files.

They may contain the functions start(), stop() and poll().

Expected return values:
- 0 success/running
- 1 failure/stopped

For services that are not or hardly pollable, but should execute on 
start and stop a value of >1 (likely 2) can be returned. 
These will be assigned a "special status" to always execute.
E.g. alsactl or random-seed.

Further service files may contain the variable WAITFOR, defining services 
that shall start before this service, as a space separated list.
E.g:
WAITFOR="dbus foo"
Only direct dependencies shall be defined. E.g:
sshd contains WAITFOR="wicd"
wicd contains WAITFOR="dbus"

Service file names shall not contain spaces.[^1]

[^1]: Yes, I'm using "for file in $(ls $dir); do", and yes, I've read
that this is the worst thing one could do... See issues 3).

When no service file or function is found the given name of the service
is used as fallback.

### Stages

Services can be grouped together in stages.

By default the stages are defined by directories in /etc/stage/stages.d.

Services are added to a stage by placing a link to the service file,
or, in case there is no service file, an empty file, into the respective 
stage directories.

Convenience functions are provided for doing this.

### Boot / Shutdown

The provided boot sequence is as follows:

1) pre_boot (mount api filesystems)
2) launch BOOT_STAGES
3) post_boot (spawn gettys)

The provided shutdown sequence:

1) pre_shutdown (stop gettys)
2) revert SHUTDOWN_STAGES
3) post_shudown (umount everything, spawn a debug shell)[^2]

[^2]: See issues 1).

BOOT/SHUTDOWN_STAGES are defined in /etc/stage/stage.conf.
These are executed serially, in the order given there.

pre-post functions can be found in:
/usr/lib/stage/functions/<boot/shutdown>_prepost_sequences_f


Not really issues
-----------------

1) currently I've used own stages for killing processes and unmounting,
   this works well but maybe I'll put these into the post_shutdown sequence

2) when stopping (or starting?) it happens that two (or more)  instances of
   stop_recursive() are called at the same time, the later one fails
   (not a real problem/cosmetic issue)

3) change all "for ls" loops to "ls while read" loops
   --> ran into problems, also problems with "shell globbing"

4) evtl. launch _only_ l0 services first (services that need no other service)
