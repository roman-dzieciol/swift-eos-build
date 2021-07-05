
#ifndef CTestHelpers_VoidPointer_h
#define CTestHelpers_VoidPointer_h

extern void * CTestHelpers_VoidPointer(void * ptr);
extern void * CTestHelpers_VoidPointerValue(unsigned long long value);

extern const void * CTestHelpers_ConstVoidPointer(const void * ptr);
extern const void * CTestHelpers_ConstVoidPointerValue(unsigned long long value);

extern const void * const CTestHelpers_ConstVoidConstPointer(const void * const ptr);
extern const void * const CTestHelpers_ConstVoidConstPointerValue(unsigned long long value);

extern void * const CTestHelpers_VoidConstPointer(void * const ptr);
extern void * const CTestHelpers_VoidConstPointerValue(unsigned long long value);

#endif
