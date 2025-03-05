#include <stddef.h>
#ifndef STRING_BUFFER_H
#define STRING_BUFFER_H
typedef struct {
    char* str;
    size_t length;
    size_t capacity;
} StringBuilder;
#endif

StringBuilder* sb_init();
void sb_free(StringBuilder*);
int sb_ensure_capacity(StringBuilder*, size_t);
int sb_append(StringBuilder*, const char*);