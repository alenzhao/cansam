# Makefile for the Cansam library, which provides tools for SAM/BAM files.
#
#    Copyright (C) 2010-2012 Genome Research Ltd.
#
#    Author: John Marshall <jm18@sanger.ac.uk>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the names Genome Research Ltd and Wellcome Trust Sanger Institute
#    nor the names of its contributors may be used to endorse or promote
#    products derived from this software without specific prior written
#    permission.
#
# THIS SOFTWARE IS PROVIDED BY GENOME RESEARCH LTD AND ITS CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL GENOME RESEARCH LTD OR ITS CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

srcdir = .
VPATH  = $(srcdir)

CXX      = g++
CXXFLAGS = -Wall -Wextra -g -O2 -I$(srcdir)
LDFLAGS  =
LDLIBS   = -lz
AR       = ar
RANLIB   = ranlib

OUTPUTS = libcansam.a samcat samcount samgroupbyname samsort samsplit test/runtests
all: $(OUTPUTS)

lib: libcansam.a

LIBOBJS = lib/alignment.o lib/collection.o lib/header.o lib/sambamio.o \
	  lib/samstream.o lib/ostream.o lib/rawfilebuf.o \
	  lib/interval.o lib/intervalmap.o \
	  lib/exception.o lib/system.o lib/utilities.o lib/version.o

libcansam.a: $(LIBOBJS)
	-rm -f $@
	$(AR) rc $@ $(LIBOBJS)
	-$(RANLIB) $@


sam_alignment_h = cansam/sam/alignment.h cansam/types.h cansam/sam/header.h
sam_header_h    = cansam/sam/header.h cansam/types.h
sam_interval_h  = cansam/interval.h cansam/types.h
sam_intervalmap_h=cansam/intervalmap.h cansam/interval.h cansam/types.h
lib_sambamio_h  = lib/sambamio.h cansam/sam/stream.h
lib_utilities_h = lib/utilities.h cansam/types.h

lib/alignment.o: lib/alignment.cpp $(sam_alignment_h) cansam/exception.h \
		 $(sam_header_h) $(lib_utilities_h) lib/wire.h
lib/collection.o: lib/collection.cpp $(sam_header_h) cansam/exception.h
lib/exception.o: lib/exception.cpp cansam/exception.h
lib/header.o: lib/header.cpp $(sam_header_h) cansam/exception.h $(lib_utilities_h)
lib/interval.o: lib/interval.cpp $(sam_interval_h)
lib/intervalmap.o: lib/intervalmap.cpp $(sam_intervalmap_h)
lib/ostream.o: lib/ostream.cpp $(sam_alignment_h) $(sam_header_h) \
	       $(lib_utilities_h)
lib/rawfilebuf.o: lib/rawfilebuf.cpp cansam/streambuf.h cansam/exception.h
lib/sambamio.o: lib/sambamio.cpp $(lib_sambamio_h) $(sam_alignment_h) \
		cansam/exception.h cansam/sam/stream.h $(lib_utilities_h) lib/wire.h
lib/samstream.o: lib/samstream.cpp cansam/sam/stream.h $(sam_alignment_h) \
		 cansam/exception.h cansam/streambuf.h $(lib_sambamio_h)
lib/system.o: lib/system.cpp
lib/utilities.o: lib/utilities.cpp lib/utilities.h
lib/version.o: lib/version.cpp cansam/version.h


MISC_OBJS = tools/samcat.o tools/samcount.o tools/samgroupbyname.o \
	    tools/samsort.o tools/samsplit.o \
	    tools/utilities.o examples/simplecat.o

samcat: tools/samcat.o tools/utilities.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ tools/samcat.o tools/utilities.o libcansam.a $(LDLIBS)

samcount: tools/samcount.o tools/utilities.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ tools/samcount.o tools/utilities.o libcansam.a $(LDLIBS)

samgroupbyname: tools/samgroupbyname.o tools/utilities.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ tools/samgroupbyname.o tools/utilities.o libcansam.a $(LDLIBS)

samsort: tools/samsort.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ tools/samsort.o libcansam.a $(LDLIBS)

samsplit: tools/samsplit.o tools/utilities.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ tools/samsplit.o tools/utilities.o libcansam.a $(LDLIBS)

simplecat: examples/simplecat.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ examples/simplecat.o libcansam.a $(LDLIBS)


tools/samcat.o: tools/samcat.cpp $(sam_alignment_h) $(sam_header_h) \
		cansam/sam/stream.h tools/utilities.h
tools/samcount.o: tools/samcount.cpp $(sam_alignment_h) $(sam_header_h) \
		  cansam/sam/stream.h tools/utilities.h
tools/samgroupbyname.o: tools/samgroupbyname.cpp cansam/sam/algorithm.h \
			$(sam_alignment_h) cansam/exception.h $(sam_header_h) \
			cansam/sam/stream.h tools/utilities.h
tools/samsort.o: tools/samsort.cpp tools/samsort.h $(sam_alignment_h)
tools/samsplit.o: tools/samsplit.cpp $(sam_alignment_h) cansam/exception.h \
		  $(sam_header_h) cansam/sam/stream.h $(lib_utilities_h) \
		  tools/utilities.h
tools/utilities.o: tools/utilities.cpp tools/utilities.h cansam/version.h
examples/simplecat.o: examples/simplecat.cpp cansam/sam/header.h cansam/sam/alignment.h


test: test/runtests
	test/runtests test $(srcdir)/test

TEST_OBJS = test/runtests.o test/alignment.o test/header.o test/sam.o \
	    test/wire.o test/interval.o

test/runtests: $(TEST_OBJS) libcansam.a
	$(CXX) $(LDFLAGS) -o $@ $(TEST_OBJS) libcansam.a $(LDLIBS)

test/runtests.o: test/runtests.cpp test/test.h cansam/exception.h
test/alignment.o: test/alignment.cpp test/test.h $(sam_alignment_h)
test/header.o: test/header.cpp test/test.h $(sam_header_h)
test/interval.o: test/interval.cpp test/test.h $(sam_intervalmap_h)
test/sam.o: test/sam.cpp test/test.h $(sam_alignment_h) cansam/sam/stream.h
test/wire.o: test/wire.cpp test/test.h lib/wire.h

.PHONY: all clean doc docclean install lib tags test uninstall

prefix      = /usr
exec_prefix = $(prefix)
bindir      = $(exec_prefix)/bin
includedir  = $(prefix)/include
libdir      = $(exec_prefix)/lib
mandir      = $(prefix)/share/man
man1dir     = $(mandir)/man1
man3dir     = $(mandir)/man3

INSTALL_DATA = install -p
INSTALL_PROGRAM = install -p

install: libcansam.a samcat samcount samgroupbyname samsort samsplit
	mkdir $(DESTDIR)$(includedir)
	mkdir $(DESTDIR)$(includedir)/cansam
	$(INSTALL_DATA) cansam/*.h $(DESTDIR)$(includedir)/cansam
	mkdir $(DESTDIR)$(includedir)/cansam/sam
	$(INSTALL_DATA) cansam/sam/*.h $(DESTDIR)$(includedir)/cansam/sam
	mkdir $(DESTDIR)$(libdir)
	$(INSTALL_DATA) libcansam.a $(DESTDIR)$(libdir)/libcansam.a
	mkdir $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) samcat $(DESTDIR)$(bindir)/samcat
	$(INSTALL_PROGRAM) samcount $(DESTDIR)$(bindir)/samcount
	$(INSTALL_PROGRAM) samgroupbyname $(DESTDIR)$(bindir)/samgroupbyname
	$(INSTALL_PROGRAM) samsort $(DESTDIR)$(bindir)/samsort
	$(INSTALL_PROGRAM) samsplit $(DESTDIR)$(bindir)/samsplit
	# FIXME mkdir $(DESTDIR)$(prefix)/share
	mkdir $(DESTDIR)$(mandir)
	mkdir $(DESTDIR)$(man1dir)
	$(INSTALL_DATA) tools/samcat.1 $(DESTDIR)$(man1dir)/samcat.1
	$(INSTALL_DATA) tools/samgroupbyname.1 \
	                $(DESTDIR)$(man1dir)/samgroupbyname.1
	$(INSTALL_DATA) tools/samsort.1 $(DESTDIR)$(man1dir)/samsort.1
	$(INSTALL_DATA) tools/samsplit.1 $(DESTDIR)$(man1dir)/samsplit.1
	mkdir $(DESTDIR)$(man3dir)
	$(INSTALL_DATA) tools/cansam.3 $(DESTDIR)$(man3dir)/cansam.3

uninstall:
	for sam_hdr in cansam/*.h cansam/sam/*.h; do rm $(DESTDIR)$(includedir)/$$sam_hdr; done
	-rmdir $(DESTDIR)$(includedir)/cansam/sam $(DESTDIR)$(includedir)/cansam
	-rm $(DESTDIR)$(libdir)/libcansam.a
	-rm $(DESTDIR)$(bindir)/samcat
	-rm $(DESTDIR)$(BINDIR)/samcount
	-rm $(DESTDIR)$(bindir)/samgroupbyname
	-rm $(DESTDIR)$(BINDIR)/samsort
	-rm $(DESTDIR)$(BINDIR)/samsplit
	cd tools; for man in *.1; do rm $(DESTDIR)$(man1dir)/$$man; done
	rm $(DESTDIR)$(man3dir)/cansam.3

doc:
	doxygen doc/Doxyfile
	@echo "Remove <p></p> from enum (see namespacesam.html)" >&2

tags:
	ctags -f TAGS [clt]*/*.h [cl]*/*/*.h [clt]*/*.cpp

clean:
	-rm -f $(OUTPUTS) $(LIBOBJS) $(MISC_OBJS) $(TEST_OBJS) TAGS

docclean:
	-rm -rf doc/html doc/latex
