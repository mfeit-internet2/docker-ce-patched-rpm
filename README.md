# Builder for Patched Docker CE

The scripts in this directory build a patched version of the
`docker-ce` RPM for CentOS 8 that contains the patch in [this pull
request](https://github.com/moby/libnetwork/pull/2624).

The packages produced by this process append `.1` onto the version of
Docker CE being built.  This keeps it ahead of what's been officially
released.



## Building the Docker Package

 - Build an expandable CentOS 8 VM.

 - Log in as root

 - Unpack the tarball containing this README

 - Run the `system-prep` script.  This will download and install the
   RPM building utilities from perfSONAR's pScheduler (among other
   things).

 - As root, run `make`

 - Find finished RPMs in the `rpm` directory.



## New Releases

To build for a new relese, edit the `VERSION` and `RELEASE` variables
at the top of the `Makefile`.
