//started with chatGPT template Tue 23 July 2024
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include "string_buffer.h"

#define INITIAL_CAPACITY 1024

// Initialize the string builder
StringBuilder *sb_init() {
    StringBuilder *sb = malloc(sizeof(StringBuilder));
    if (sb == NULL) {
        return NULL;
    }
    sb->str = malloc(INITIAL_CAPACITY);
    if (sb->str == NULL) {
        free(sb);
        return NULL;
    }
    sb->str[0] = '\0'; // Empty string
    sb->length = 0;
    sb->capacity = INITIAL_CAPACITY;
    return sb;
}

// Free the string builder
void sb_free(StringBuilder *sb) {
    if (sb) {
        free(sb->str);
        free(sb);
    }
}

// Ensure there is enough space to append more data
int sb_ensure_capacity(StringBuilder *sb, size_t additional_length) {
    if (sb->length + additional_length + 1 > sb->capacity) {
        size_t new_capacity = sb->capacity * 2;
        while (new_capacity < sb->length + additional_length + 1) {
            new_capacity *= 2;
        }
        char *new_str = realloc(sb->str, new_capacity);
        if (new_str == NULL) {
            return -1; // Allocation failed
        }
        sb->str = new_str;
        sb->capacity = new_capacity;
    }
    return 0;
}

// Append a string to the string builder
int sb_append(StringBuilder *sb, const char *suffix) {
    size_t suffix_length = strlen(suffix);
    if (sb_ensure_capacity(sb, suffix_length) != 0) {
        return -1; // Allocation failed
    }
    strcat_safe(sb->str, sb->capacity, suffix);
    sb->length += suffix_length;
    return 0;
}

/*
int main() {
    StringBuilder *sb = sb_init();
    if (sb == NULL) {
        fprintf(stderr, "Failed to initialize string builder\n");
        return 1;
    }

    // Append some strings
    sb_append(sb, "This is the first part.\n");
    sb_append(sb, "This is the second part.\n");

    // Print the result
    printf("%s", sb->str);

    // Clean up
    sb_free(sb);

    return 0;
}
*/