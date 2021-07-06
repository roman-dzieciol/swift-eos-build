
#include "CTestHelpers_FuncPointer.h"

extern CTestHelpers_FPTR_Void_Type CTestHelpers_FPTR_Pass_IntFromVoid(CTestHelpers_FPTR_Void_Type ptr) {
    return ptr;
}

extern CTestHelpers_FPTR_ValueStruct_Type CTestHelpers_FPTR_Pass_IntFromValueStruct(CTestHelpers_FPTR_ValueStruct_Type ptr) {
    return ptr;
}

extern void CTestHelpers_FPTR_Call_WithOptions(CTestHelpers_Options *options, void(*callback)(CTestHelpers_CallbackInfo *)) {

    CTestHelpers_CallbackInfo callbackInfo;
    callbackInfo.ClientData = options->ClientData;
    callbackInfo.cString = "SUCCESS";
    callback(&callbackInfo);
}
