
#include "CTestHelpers_VoidPointer.h"

extern void * CTestHelpers_VoidPointer(void * ptr) {
    return ptr;
}

extern void * CTestHelpers_VoidPointerValue(unsigned long long value) {
    return (void *) value;
}

extern const void * CTestHelpers_ConstVoidPointer(const void * ptr) {
    return ptr;
}

extern const void * CTestHelpers_ConstVoidPointerValue(unsigned long long value) {
    return (const void *) value;
}

extern const void * const CTestHelpers_ConstVoidConstPointer(const void * const ptr) {
    return ptr;
}

extern const void * const CTestHelpers_ConstVoidConstPointerValue(unsigned long long value) {
    return (const void * const) value;
}

extern void * const CTestHelpers_VoidConstPointer(void * const ptr) {
    return ptr;
}

extern void * const CTestHelpers_VoidConstPointerValue(unsigned long long value) {
    return (void * const) value;
}
