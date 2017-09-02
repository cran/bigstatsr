#ifndef UTILS_H
#define UTILS_H

#include <Rcpp.h>

const char* const ERROR_TYPE =
  "Unknown type detected for Filebacked Big Matrix";
const char* const ERROR_DIM =
  "incompatibility between dimensions";
const char* const ERROR_BOUNDS =
  "Subscript out of bounds";
const char* const ERROR_USHORT =
  "Try to fill an 'unsigned short' with a value outside [0:65535]";

inline void myassert(bool cond, const char *msg) {
  if (!cond) throw Rcpp::exception(msg);
}

#endif // UTILS_H
