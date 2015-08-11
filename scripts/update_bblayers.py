#!/usr/bin/env python

import os
import sys

def main():
	if len(sys.argv) != 3:
		print "Error: incorrect number of args passed"
		return 1

	bblayers = open(os.sys.argv[1], "r").read()
	topdir = sys.argv[2]

	parts = bblayers.split("BBLAYERS ")

	if len(parts) < 2:
		print "Error: BBLAYERS line not found"
		return 1
	if len(parts) > 2:
		print "Error: BBLAYERS occurs more than once in file"
		return 1

	bottom = '"'.join(parts[1].split('"')[2:])

	newlines ='''BBLAYERS ?= " \\
  {0}/openembedded-core/meta \\
  {1}/meta-qualcomm \\
  {2}/meta-openembedded/meta-oe \\
  {3}/meta-openembedded/meta-gnome \\
  {4}/meta-96boards \\
  {5}/meta-easy-oe \\
  "'''.format(topdir, topdir, topdir, topdir, topdir, topdir)
	
	updated_contents = parts[0]+newlines+bottom
	open(os.sys.argv[1], "w").write(updated_contents)
	return 0
	
if __name__ == "__main__":
	ret = main()
	sys.exit(ret)
