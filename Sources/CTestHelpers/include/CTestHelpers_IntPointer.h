
#ifndef CTestHelpers_IntPointer_h
#define CTestHelpers_IntPointer_h

extern unsigned long long * CTestHelpers_IntPointer(unsigned long long * ptr);
extern unsigned long long * CTestHelpers_IntPointerValue(unsigned long long value);

extern const unsigned long long * CTestHelpers_ConstIntPointer(const unsigned long long * ptr);
extern const unsigned long long * CTestHelpers_ConstIntPointerValue(unsigned long long value);

extern const unsigned long long * const CTestHelpers_ConstIntConstPointer(const unsigned long long * const ptr);
extern const unsigned long long * const CTestHelpers_ConstIntConstPointerValue(unsigned long long value);

extern unsigned long long * const CTestHelpers_IntConstPointer(unsigned long long * const ptr);
extern unsigned long long * const CTestHelpers_IntConstPointerValue(unsigned long long value);

#endif
