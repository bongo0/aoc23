
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "utils.h"

#include <limits.h>

typedef enum {
    STR2INT_SUCCESS,
    STR2INT_OVERFLOW,
    STR2INT_UNDERFLOW,
    STR2INT_INCONVERTIBLE
} sv2int_errno;

// TODO: dont use malloc ...
sv2int_errno sv2int(int *out, String_View *sv, int base) {
    sv2int_errno ret = STR2INT_SUCCESS;
    if (sv->data[0] == '\0' || isspace(sv->data[0])){
        return STR2INT_INCONVERTIBLE;
    }

    errno = 0;
    char *str = malloc(sv->count+1);
    memcpy(str,sv->data, sv->count);
    str[sv->count]=0;
    char *end;
    long l = strtol(str, &end, base);
    /* Both checks are needed because INT_MAX == LONG_MAX is possible. */
    if (l > INT_MAX || (errno == ERANGE && l == LONG_MAX)){
        ret = STR2INT_OVERFLOW;
        goto defer;
    }
    if (l < INT_MIN || (errno == ERANGE && l == LONG_MIN)){
        ret = STR2INT_UNDERFLOW;
        goto defer;
    }
    if (*end != '\0'){
        ret = STR2INT_INCONVERTIBLE;
        goto defer;
    }
    *out = l;
defer:
    free(str);
    return ret;
}

typedef struct {
    int red;
    int green;
    int blue;
} Draw;

typedef struct {
    Draw *items;
    size_t count;
    size_t capacity;
    int game_id;
} Game;

typedef struct {
    Game *items;
    size_t count;
    size_t capacity;
} Games;

int main(void){

    String_Builder input = {0};
    read_entire_file("input", &input);
    sb_append_null(&input);

    //printf("%s \n", input.items);

    
    String_View token = {.data=input.items, .count=0};

    Games gs = {0};
    Game g = {0};
    Draw d = {0};

    char *c = input.items;
    int last_int=0;
    bool first = true;
    while(c <= input.items+input.count){
        
        while(c<=input.items+input.count&& !isspace(*c) && *c!=';' && *c!=':') ++c; // oopsie, dese are dangerous af

        token.count = c - token.data;
        
        printf("    "SV_Fmt" ",SV_Arg(token));
        
               if(token.count>=3 && strncmp(token.data,"red"  , 3)==0 ){
                printf("  RED\n");
                d.red = last_int;
        } else if(token.count>=4 && strncmp(token.data,"blue" , 4)==0 ){
                printf("  BLUE\n");
                d.blue = last_int;
        } else if(token.count>=4 && strncmp(token.data,"Game" , 4)==0 ){
            if(!first){
                da_append(&g,d);
                d.blue=0;
                d.green=0;
                d.red=0;
                da_append(&gs,g);
            }
            first=false;

            printf("new game:  ");
            g.capacity=0;
            g.count=0;
            g.items=NULL;
            g.game_id=0;
            // meh.. 
            while(c<=input.items+input.count&& isspace(*c) ) ++c;
            token.count=0;
            token.data=c;
            while(c<=input.items+input.count&& !isspace(*c) && *c!=';' && *c!=':') ++c; // oopsie, dese are dangerous af
            token.count = c - token.data;
            int i = 0;
            sv2int(&i, &token, 10);
            g.game_id = i;
            printf("    int %d  \n", i);

        } else if(token.count>=5 && strncmp(token.data,"green", 5)==0 ){
                printf("  GREEN\n");
                d.green = last_int;
        } else {
            sv2int(&last_int, &token, 10);
            printf("    int %d  \n", last_int);
        }

        if(*c==';'){
            da_append(&g,d);
            printf("  new set:\n");
            d.red=0;
            d.green=0;
            d.blue=0;
            last_int=0;
            ++c;
        }
        if(*c==':')++c;

        while(c<=input.items+input.count&& isspace(*c) ) ++c;
        token.count=0;
        token.data=c;

    }
    da_append(&g,d);
    da_append(&gs,g);
    
    printf("---------------------\n");
    printf(" gs: %zu \n", gs.count);
    int id_sum=0;
    for(size_t i = 0; i < gs.count; ++i){
        printf("  g: %zu id: %d   ", gs.items[i].count, gs.items[i].game_id);
        bool possible = true;
        for(size_t j=0; j < gs.items[i].count; ++j){
            Draw tmp = gs.items[i].items[j];
            printf("r%d g%d b%d; ",tmp.red,tmp.green,tmp.blue);
            if( tmp.red   > 12 ||
                tmp.green > 13 ||
                tmp.blue  > 14
            ) possible = false;
        }
        if(possible) id_sum += gs.items[i].game_id;
        printf("\n");
    }
    printf("  id_sum: %d\n", id_sum);

}