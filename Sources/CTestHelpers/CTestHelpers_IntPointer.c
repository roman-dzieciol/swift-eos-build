
#include "CTestHelpers_IntPointer.h"


extern unsigned long long * CTestHelpers_IntPointer(unsigned long long * ptr) {
    return ptr;
}

extern unsigned long long * CTestHelpers_IntPointerValue(unsigned long long value) {
    return (unsigned long long *) value;
}

extern const unsigned long long * CTestHelpers_ConstIntPointer(const unsigned long long * ptr) {
    return ptr;
}

extern const unsigned long long * CTestHelpers_ConstIntPointerValue(unsigned long long value) {
    return (const unsigned long long *) value;
}

extern const unsigned long long * const CTestHelpers_ConstIntConstPointer(const unsigned long long * const ptr) {
    return ptr;
}

extern const unsigned long long * const CTestHelpers_ConstIntConstPointerValue(unsigned long long value) {
    return (const unsigned long long * const) value;
}

extern unsigned long long * const CTestHelpers_IntConstPointer(unsigned long long * const ptr) {
    return ptr;
}

extern unsigned long long * const CTestHelpers_IntConstPointerValue(unsigned long long value) {
    return (unsigned long long * const) value;
}
