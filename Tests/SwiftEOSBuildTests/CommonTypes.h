
#pragma once





void * _void_ptr;
void ** _void_ptr_ptr;
const void * _const_void_ptr;
const void ** _const_void_ptr_ptr;
const void *const * _const_void_ptr_const_ptr;

char _char;
char * _char_ptr;
char ** _char_ptr_ptr;
const char * _const_char_ptr;
const char ** _const_char_ptr_ptr;
const char *const * _const_char_ptr_const_ptr;

int _int;
int * _int_ptr;
int ** _int_ptr_ptr;
const int * _const_int_ptr;
const int ** _const_int_ptr_ptr;
const int *const * _const_int_ptr_const_ptr;

typedef void * _void_ptr_typedef;
typedef void ** _void_ptr_ptr_typedef;
typedef const void * _const_void_ptr_typedef;
typedef const void ** _const_void_ptr_ptr_typedef;
typedef const void *const * _const_void_ptr_const_ptr_typedef;

typedef char _char_typedef;
typedef char * _char_ptr_typedef;
typedef char ** _char_ptr_ptr_typedef;
typedef const char * _const_char_ptr_typedef;
typedef const char ** _const_char_ptr_ptr_typedef;
typedef const char *const * _const_char_ptr_const_ptr_typedef;

typedef int _int_typedef;
typedef int * _int_ptr_typedef;
typedef int ** _int_ptr_ptr_typedef;
typedef const int * _const_int_ptr_typedef;
typedef const int ** _const_int_ptr_ptr_typedef;
typedef const int *const * _const_int_ptr_const_ptr_typedef;

typedef struct {

    void * _void_ptr;
    void ** _void_ptr_ptr;
    const void * _const_void_ptr;
    const void ** _const_void_ptr_ptr;
    const void *const * _const_void_ptr_const_ptr;

    char _char;
    char * _char_ptr;
    char ** _char_ptr_ptr;
    const char * _const_char_ptr;
    const char ** _const_char_ptr_ptr;
    const char *const * _const_char_ptr_const_ptr;

    int _int;
    int * _int_ptr;
    int ** _int_ptr_ptr;
    const int * _const_int_ptr;
    const int ** _const_int_ptr_ptr;
    const int *const * _const_int_ptr_const_ptr;
} _typedef_struct;


void * _func(
             void * _void_ptr,
             void ** _void_ptr_ptr,
             const void * _const_void_ptr,
             const void ** _const_void_ptr_ptr,
             const void *const * _const_void_ptr_const_ptr,

             char _char,
             char * _char_ptr,
             char ** _char_ptr_ptr,
             const char * _const_char_ptr,
             const char ** _const_char_ptr_ptr,
             const char *const * _const_char_ptr_const_ptr,

             int _int,
             int * _int_ptr,
             int ** _int_ptr_ptr,
             const int * _const_int_ptr,
             const int ** _const_int_ptr_ptr,
             const int *const * _const_int_ptr_const_ptr
             );

typedef void (* _func_ptr_typedef)(
                           void * _void_ptr,
                           void ** _void_ptr_ptr,
                           const void * _const_void_ptr,
                           const void ** _const_void_ptr_ptr,
                           const void *const * _const_void_ptr_const_ptr,

                           char _char,
                           char * _char_ptr,
                           char ** _char_ptr_ptr,
                           const char * _const_char_ptr,
                           const char ** _const_char_ptr_ptr,
                           const char *const * _const_char_ptr_const_ptr,

                           int _int,
                           int * _int_ptr,
                           int ** _int_ptr_ptr,
                           const int * _const_int_ptr,
                           const int ** _const_int_ptr_ptr,
                           const int *const * _const_int_ptr_const_ptr
                           );
