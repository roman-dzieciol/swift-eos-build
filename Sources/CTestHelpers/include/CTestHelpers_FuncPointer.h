
#ifndef CTestHelpers_FuncPointer_h
#define CTestHelpers_FuncPointer_h

#include "CTestHelpers_Common.h"

typedef unsigned long long(*CTestHelpers_FPTR_Void_Type)(void);
typedef unsigned long long(*CTestHelpers_FPTR_ValueStruct_Type)(CTestHelpers_ValueStruct *options);
typedef unsigned long long(*CTestHelpers_FPTR_VoidPtrStruct_Type)(CTestHelpers_VoidPtrStruct *options);

extern CTestHelpers_FPTR_Void_Type CTestHelpers_FPTR_Pass_IntFromVoid(CTestHelpers_FPTR_Void_Type ptr);
extern CTestHelpers_FPTR_ValueStruct_Type CTestHelpers_FPTR_Pass_IntFromValueStruct(CTestHelpers_FPTR_ValueStruct_Type ptr);

extern void CTestHelpers_FPTR_Call_WithOptions(CTestHelpers_Options *options, void(*callback)(CTestHelpers_CallbackInfo *));

#endif
