#ifndef MY_C_UTILS_H_
#define MY_C_UTILS_H_

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>

////////////////////////////////////////////////////////////////////////////////////////////////////
// String builder
// must be zero initialized for the first time
typedef struct {
    char *items;
    size_t count;
    size_t capacity;
} String_Builder;

// Append a NULL-terminated string to a string builder
#define sb_append_cstr(sb, cstr)  \
    do {                          \
        const char *s = (cstr);   \
        size_t n = strlen(s);     \
        da_append_many(sb, s, n); \
    } while (0)
// Append a sized buffer to a string builder
#define sb_append_buf(sb, buf, size) da_append_many(sb, buf, size)
// Append a single NULL character at the end of a string builder. So you can then
// use it a NULL-terminated C string
#define sb_append_null(sb) da_append_many(sb, "", 1)
// Free the memory allocated by a string builder
#define sb_free(sb) free((sb).items)

//
bool read_entire_file(const char *path, String_Builder *sb);
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// String view
typedef struct {
    size_t count;
    const char *data;
} String_View;
//
String_View sv_chop_by_delim(String_View *sv, char delim);
String_View sv_trim(String_View sv);
bool sv_eq(String_View a, String_View b);
String_View sv_from_cstr(const char *cstr);
String_View sv_from_parts(const char *data, size_t count);
// printf macros for String_View
#ifndef SV_Fmt
#define SV_Fmt "%.*s"
#endif // SV_Fmt
#ifndef SV_Arg
#define SV_Arg(sv) (int) (sv).count, (sv).data
#endif // SV_Arg
// USAGE:
//   String_View name = ...;
//   printf("Name: "SV_Fmt"\n", SV_Arg(name));

String_View sv_chop_by_delim(String_View *sv, char delim)
{
    size_t i = 0;
    while (i < sv->count && sv->data[i] != delim) {
        i += 1;
    }

    String_View result = sv_from_parts(sv->data, i);

    if (i < sv->count) {
        sv->count -= i + 1;
        sv->data  += i + 1;
    } else {
        sv->count -= i;
        sv->data  += i;
    }

    return result;
}

String_View sv_from_parts(const char *data, size_t count)
{
    String_View sv;
    sv.count = count;
    sv.data = data;
    return sv;
}

String_View sv_trim_left(String_View sv)
{
    size_t i = 0;
    while (i < sv.count && isspace(sv.data[i])) {
        i += 1;
    }

    return sv_from_parts(sv.data + i, sv.count - i);
}

String_View sv_trim_right(String_View sv)
{
    size_t i = 0;
    while (i < sv.count && isspace(sv.data[sv.count - 1 - i])) {
        i += 1;
    }

    return sv_from_parts(sv.data, sv.count - i);
}

String_View sv_trim(String_View sv)
{
    return sv_trim_right(sv_trim_left(sv));
}

String_View sv_from_cstr(const char *cstr)
{
    return sv_from_parts(cstr, strlen(cstr));
}

bool sv_eq(String_View a, String_View b)
{
    if (a.count != b.count) {
        return false;
    } else {
        return memcmp(a.data, b.data, a.count) == 0;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////








////////////////////////////////////////////////////////////////////////////////////////////////////
// macro dynamic array:
// Initial capacity of a dynamic array
#define DA_INIT_CAP 256

// Append item to a dynamic array
#define da_append(da, item)                                                          \
    do {                                                                                 \
        if ((da)->count >= (da)->capacity) {                                             \
            (da)->capacity = (da)->capacity == 0 ? DA_INIT_CAP : (da)->capacity*2;       \
            (da)->items = realloc((da)->items, (da)->capacity*sizeof(*(da)->items));     \
            assert((da)->items != NULL && "realloc fail");                               \
        }                                                                                \
        (da)->items[(da)->count++] = (item);                                             \
    } while (0)

#define da_free(da) free((da).items)

// Append several items to a dynamic array
#define da_append_many(da, new_items, new_items_count)                                      \
    do {                                                                                    \
        if ((da)->count + new_items_count > (da)->capacity) {                               \
            if ((da)->capacity == 0) {                                                      \
                (da)->capacity = DA_INIT_CAP;                                           \
            }                                                                               \
            while ((da)->count + new_items_count > (da)->capacity) {                        \
                (da)->capacity *= 2;                                                        \
            }                                                                               \
            (da)->items = realloc((da)->items, (da)->capacity*sizeof(*(da)->items));        \
            assert((da)->items != NULL && "realloc fail");                                  \
        }                                                                                   \
        memcpy((da)->items + (da)->count, new_items, new_items_count*sizeof(*(da)->items)); \
        (da)->count += new_items_count;                                                     \
    } while (0)
////////////////////////////////////////////////////////////////////////////////////////////////////











////////////////////////////////////////////////////////////////////////////////////////////////////
// ...
bool read_entire_file(const char *filepath, String_Builder *sb)
{
    bool ret = true;
    size_t buf_size = 32*1024;
    char *buf = malloc(buf_size);
    assert(buf != NULL && "malloc failed.");
    FILE *f = fopen(filepath, "rb");

    if (f == NULL) {
        fprintf(stderr, "Could not open %s for reading: %s", filepath, strerror(errno));
        ret=false;
        goto defer;
    }

    size_t n = fread(buf, 1, buf_size, f);
    while (n > 0) {
        sb_append_buf(sb, buf, n);
        n = fread(buf, 1, buf_size, f);
    }

    if (ferror(f)) {
        fprintf(stderr, "Could not read %s: %s\n", filepath, strerror(errno));
        ret=false;
        goto defer;
    }

defer:
    free(buf);
    if (f) fclose(f);
    return ret;
}
////////////////////////////////////////////////////////////////////////////////////////////////////




#endif // MY_C_UTILS_H_