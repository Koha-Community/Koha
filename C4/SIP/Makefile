#
# There's not a lot to "make", but this simplifies the usual
# sorts of tasks
#

PODFLAGS = --htmlroot=. --podroot=.

.SUFFIXES: .pod .html

.pod.html:
	pod2html $(PODFLAGS) --outfile=$@ --infile=$<

all:
	@echo Nothing to make.  Use make test.

# just run the server from the command line
# run:
# 	perl SIPServer.pm SIPconfig.xml

test:
	cd t; $(MAKE) test

tags:
	find . -name '*.pm' -print | etags -

html: ILS.html ILS/Item.html ILS/Patron.html
