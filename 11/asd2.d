// dmd asd1.d && ./asd1
import std.stdio;
import std.range;
import std.algorithm.searching; // count
import std.math;
import std.conv;

struct point {
    long x;
    long y;
    this(long x, long y){
        this.x = x;
        this.y = y;
    }
}

ulong manhattan(point a, point b){
    return abs(a.x - b.x) + abs(a.y - b.y);
}

point expand_coords(point p, const ulong []erows, const ulong[]ecols, ulong multiplier){
    point ret = p; // copy
    ulong dx = 0;
    ulong dy = 0;
    foreach(i,r; erows){//y
        if(p.y < r ) break;
        dy++;
    }
    foreach(i,c; ecols){//x
        if(p.x < c ) break;
        dx++;
    }
    ret.x += dx*(multiplier-1);
    ret.y += dy*(multiplier-1);
    return ret;
}

void main(){
    immutable string fname = "input";
    writeln("input file: `",fname,"`");

    auto file = File(fname, "rb");

    // Parsing the input
    auto line_range = file.byLine();
    ulong line_len = line_range.front.length; // does not count the new line char
    //ulong n_lines = line_range.count;
    //line_range = file.byLine();
    writeln("input file: line_len: ", line_len);
    
    bool[] empty_cols_mask = new bool[line_len];
    empty_cols_mask[] = true;
    ulong[] empty_rows;
    ulong[] empty_cols;

    string[] lines;

    // read line by line
    int n_galaxies = 0;
    int li = 0;
    foreach(line; line_range){
        lines ~= to!string(line); // save for second pass
        ulong n = count(line, '#');
        if(n==0) {empty_rows ~= li;} // appends li to empty_rows, same as: empty_rows = empty_rows ~ li
        n_galaxies+=n;
        int ci = 0;
        foreach(ch; line){
            if(ch!='.') empty_cols_mask[ci] = false;
            ci++;
        }
        li++;
    }
    foreach (i,c; empty_cols_mask){
        if(c)empty_cols ~= i;
    }

    // foreach (l; empty_rows){writeln("empty_row: ",l);}
    // foreach (c; empty_cols){writeln("empty_col: ",c);}
    writeln("n_galaxies: ", n_galaxies);
    writeln("number of pairs: ", n_galaxies*(n_galaxies-1)/2);

    point[] galaxies;
    // pass the file again now that we know the expanded rows and cols
    foreach(y, line; lines){
        for(ulong x = 0; x < line_len; ++x){
            if(line[x]!='.'){
                point p = point(x,y);
                p = expand_coords(p,empty_rows, empty_cols, 1_000_000);
                galaxies ~= p;

                write(" (",p.x,",",p.y,")");
            }
        }
        writeln("");
    }
    writeln(" galaxies len ", galaxies.length);

    ulong sum_of_dists = 0;
    for(int i = 0; i < galaxies.length-1; i++){
        for(int j = i + 1; j < galaxies.length; j++){
            sum_of_dists += manhattan(galaxies[i],galaxies[j]);
        }
    }
    writeln("sum_of_dists: ",sum_of_dists);
}