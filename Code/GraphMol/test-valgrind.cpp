//
//  Copyright (C) 2018 Novartis Institutes Of BioMedical Research
//
//   @@ All Rights Reserved @@
//  This file is part of the RDKit.
//  The contents are covered by the terms of the BSD license
//  which is included in the file license.txt, found at the root
//  of the RDKit source tree.
//

#include <fstream>

#include <malloc.h>

#include <GraphMol/MolStandardize/Charge.h>
#include <GraphMol/SmilesParse/SmilesParse.h>

using namespace RDKit;
using namespace RDKit::MolStandardize;
using namespace std;

static CleanupParameters cleanupParameters;

void doSmilesToMol(const char* s) {
  const auto* m1 = SmilesToMol(s);
  delete m1;
}

void doUncharge(const char* s) {
  const auto m1 = SmilesToMol(s);
  const auto m2 = uncharge(*m1, cleanupParameters);
}

void doCanonicalTautomer(const char* s) {
  const auto m1 = SmilesToMol(s);
  const auto m2 = canonicalTautomer(*m1, cleanupParameters);
}

#define LIMIT 10000
#define LOG_INTERVAL 100
#define MALLOC_TRIM_INTERVAL 100

bool _check_process(const char* func, const int counter) {
  if (counter % LOG_INTERVAL == 0) {
    printf("%s: processed %d compounds\n", func, counter);
  }
  if (counter % MALLOC_TRIM_INTERVAL == 0) {
    malloc_trim(0);
    printf("malloc_trim()\n");
  }
  if (counter % LIMIT == 0) {
    return true;
  }
  return false;
}

void testSmilesToMol() {
  ifstream is("/home/mk/Documents/rdkitTest/chembl_500000.smi");
  string str;
  int counter = 0;
  while (getline(is, str)) {
    doSmilesToMol(str.c_str());
    counter += 1;
    if (_check_process(__func__, counter)) {
      break;
    }
  }
}

void testUncharge() {
  ifstream is("/home/mk/Documents/rdkitTest/chembl_500000.smi");
  string str;
  int counter = 0;
  while (getline(is, str)) {
    doUncharge(str.c_str());
    counter += 1;
    if (_check_process(__func__, counter)) {
      break;
    }
  }
}

void testCanonicalTautomer() {
  ifstream is("/home/mk/Documents/rdkitTest/chembl_500000.smi");
  string str;
  int counter = 0;
  while (getline(is, str)) {
    doCanonicalTautomer(str.c_str());
    counter += 1;
    if (_check_process(__func__, counter)) {
      break;
    }
  }
}

int main() {
  cleanupParameters.maxTautomers = 100;
  cleanupParameters.maxTransforms = 100;
  testSmilesToMol();
  testUncharge();
    testCanonicalTautomer();
}
