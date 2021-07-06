
#ifndef CTestHelpers_Common_h
#define CTestHelpers_Common_h

typedef struct {
    unsigned long long value;
} CTestHelpers_ValueStruct;

typedef struct {
    void * ptr;
} CTestHelpers_VoidPtrStruct;

typedef struct {
    void * const ptr;
} CTestHelpers_VoidPtrConstStruct;

typedef struct {
    void * ClientData;
} CTestHelpers_Options;

typedef struct {
    const char * cString;
    void * ClientData;
} CTestHelpers_CallbackInfo;


typedef struct {
    const int * const * const ConstIntPtrConstPtrConst;

    const int ** const ConstIntPtrPtrConst;
    const int * const ConstIntPtrConst;

    const int ** ConstIntPtrPtr;
    const int * ConstIntPtr;

    int ** IntPtrPtr;
    int * IntPtr;
} CTestHelpers_IntPtr;


#endif 
