CXXFLAGS = -Wall -Wextra -g -I.
LDFLAGS  = -L.
LDLIBS   = -lz

OUTPUTS = libcansam.a samcat samcount samsort test/runtests
all: $(OUTPUTS)

lib: libcansam.a

LIBOBJS = lib/alignment.o lib/collection.o lib/header.o lib/sambamio.o \
	  lib/samstream.o lib/ostream.o lib/rawfilebuf.o \
	  lib/exception.o lib/utilities.o

libcansam.a: $(LIBOBJS)
	$(AR) cr $@ $(LIBOBJS)
	ranlib $@


sam_alignment_h = sam/alignment.h sam/types.h sam/header.h
sam_header_h    = sam/header.h sam/types.h
lib_sambamio_h  = lib/sambamio.h sam/stream.h
lib_utilities_h = lib/utilities.h sam/types.h

lib/alignment.o: lib/alignment.cpp $(sam_alignment_h) sam/exception.h \
		 $(sam_header_h) $(lib_utilities_h) lib/wire.h
lib/collection.o: lib/collection.cpp $(sam_header_h) sam/exception.h
lib/exception.o: lib/exception.cpp sam/exception.h
lib/header.o: lib/header.cpp $(sam_header_h) sam/exception.h $(lib_utilities_h)
lib/ostream.o: lib/ostream.cpp $(sam_alignment_h) $(sam_header_h) \
	       $(lib_utilities_h)
lib/rawfilebuf.o: lib/rawfilebuf.cpp sam/streambuf.h sam/exception.h
lib/sambamio.o: lib/sambamio.cpp $(lib_sambamio_h) $(sam_alignment_h) \
		sam/exception.h sam/stream.h $(lib_utilities_h) lib/wire.h
lib/samstream.o: lib/samstream.cpp sam/stream.h $(sam_alignment_h) \
		 sam/exception.h sam/streambuf.h $(lib_sambamio_h)
lib/utilities.o: lib/utilities.cpp lib/utilities.h


MISC_OBJS = utilities/samcat.o utilities/samcount.o utilities/samsort.o \
	    examples/simplecat.o

samcat: utilities/samcat.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ utilities/samcat.o -lcansam $(LDLIBS)

samcount: utilities/samcount.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ utilities/samcount.o -lcansam $(LDLIBS)

samsort: utilities/samsort.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ utilities/samsort.o -lcansam $(LDLIBS)

simplecat: examples/simplecat.o libcansam.a
	$(CXX) $(LDFLAGS) -o $@ examples/simplecat.o -lcansam $(LDLIBS)

utilities/samcat.o: utilities/samcat.cpp $(sam_alignment_h) $(sam_header_h) \
		    sam/stream.h
utilities/samcount.o: utilities/samcount.cpp $(sam_alignment_h) \
		      $(sam_header_h) sam/stream.h
utilities/samsort.o: utilities/samsort.cpp utilities/samsort.h
examples/simplecat.o: examples/simplecat.cpp sam/header.h sam/alignment.h


test: test/runtests
	test/runtests

TEST_OBJS = test/runtests.o test/alignment.o test/header.o test/sam.o \
	    test/wire.o

test/runtests: $(TEST_OBJS) libcansam.a
	$(CXX) $(LDFLAGS) -o $@ $(TEST_OBJS) -lcansam $(LDLIBS)

test/runtests.o: test/runtests.cpp test/test.h sam/exception.h
test/alignment.o: test/alignment.cpp test/test.h $(sam_alignment_h)
test/header.o: test/header.cpp test/test.h $(sam_header_h)
test/sam.o: test/sam.cpp test/test.h $(sam_alignment_h) sam/stream.h
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

install: libcansam.a samcat samcount samsort
	mkdir $(DESTDIR)$(includedir)
	mkdir $(DESTDIR)$(includedir)/sam
	for sam_hdr in sam/*.h; do \
	    $(INSTALL_DATA) $$sam_hdr $(DESTDIR)$(includedir)/$$sam_hdr; \
	done
	mkdir $(DESTDIR)$(libdir)
	$(INSTALL_DATA) libcansam.a $(DESTDIR)$(libdir)/libcansam.a
	mkdir $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) samcat $(DESTDIR)$(bindir)/samcat
	$(INSTALL_PROGRAM) samcount $(DESTDIR)$(bindir)/samcount
	$(INSTALL_PROGRAM) samsort $(DESTDIR)$(bindir)/samsort
	# FIXME mkdir $(DESTDIR)$(prefix)/share
	mkdir $(DESTDIR)$(mandir)
	mkdir $(DESTDIR)$(man1dir)
	$(INSTALL_DATA) utilities/samcat.1 $(DESTDIR)$(man1dir)/samcat.1
	$(INSTALL_DATA) utilities/samsort.1 $(DESTDIR)$(man1dir)/samsort.1
	mkdir $(DESTDIR)$(man3dir)
	$(INSTALL_DATA) utilities/cansam.3 $(DESTDIR)$(man3dir)/cansam.3

uninstall:
	for sam_hdr in sam/*.h; do rm $(DESTDIR)$(includedir)/$$sam_hdr; done
	-rmdir $(DESTDIR)$(includedir)/sam
	-rm $(DESTDIR)$(libdir)/libcansam.a
	-rm $(DESTDIR)$(bindir)/samcat
	-rm $(DESTDIR)$(BINDIR)/samcount
	-rm $(DESTDIR)$(BINDIR)/samsort
	cd utilities; for man in *.1; do rm $(DESTDIR)$(man1dir)/$$man; done
	rm $(DESTDIR)$(man3dir)/cansam.3

doc:
	doxygen doc/Doxyfile
	@echo "Remove <p></p> from enum (see namespacesam.html)" >&2

tags:
	@#ctags -o TAGS */*.h */*.cpp
	ctags -o TAGS {examples,lib,sam,test,utilities}/*.[ch]*

clean:
	-rm -f $(OUTPUTS) $(LIBOBJS) $(MISC_OBJS) $(TEST_OBJS) TAGS

docclean:
	-rm -rf doc/html doc/latex
