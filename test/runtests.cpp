#include <iostream>
#include <cstdlib>

#include "test/test.h"

void test_harness::check(bool expr, const string& title) {
  if (expr) {
    npass++;
  }
  else {
    std::cerr << "FAILED\t" << title << '\n';
    nfail++;
  }
}

void test_harness::check(const string& a, const string& b, const string& title){
  if (a == b) {
    npass++;
  }
  else {
    std::cerr << "FAILED\t" << title << " (\"" << a << "\" != \"" << b
	      << "\")\n";
    nfail++;
  }
}

void test_harness::check(size_t a, size_t b, const string& title) {
  if (a == b) {
    npass++;
  }
  else {
    std::cerr << "FAILED\t" << title << " (" << a << " != " << b << ")\n";
    nfail++;
  }
}

extern void test_alignments(test_harness&);
extern void test_headers(test_harness&);
extern void test_wire(test_harness&);

int main() {
  test_harness t;

  test_headers(t);
  test_alignments(t);
  test_wire(t);

  if (t.nfail > 0) {
    std::cerr << "\nTotal failures: " << t.nfail << '\n';
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
