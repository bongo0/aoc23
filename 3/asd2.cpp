#include <iostream>
#include <fstream>
#include <filesystem>

#include <string_view>
#include <charconv>

#include <vector>
 #include <numeric>

static inline bool is_num(const char c){
    return (c >= '0' && c <= '9');
}

static inline bool has_nb_sym(size_t p, char *buf){
    const constexpr size_t cols = 141;
    const constexpr size_t rows = 140;
    size_t x = p%cols;
    size_t y = p/cols;

    //x-1 y-1
    if(x!=0 && y!=0){
        char c = buf[(x-1)+(y-1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //y-1
    if(y!=0){
        char c = buf[(x  )+(y-1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //x+1 y-1
    if(y!=0 && x!=cols-2){
        char c = buf[(x+1)+(y-1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //x-1
    if(x!=0){
        char c = buf[(x-1)+(y  )*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //x+1
    if(x!=cols-2){
        char c = buf[(x+1)+(y  )*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //x-1 y+1
    if(x!=0&&y!=rows){
        char c = buf[(x-1)+(y+1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //y+1
    if(y!=rows){
        char c = buf[(x  )+(y+1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    //x+1 y+1
    if(y!=rows&&x!=cols-2){
        char c = buf[(x+1)+(y+1)*cols];
        if( !is_num(c) && c!='.') return true;
    }
    return false;
}


static inline int parse_num_at(size_t p, const char* buf, size_t f_size){
    size_t start=p;
    size_t stop=p;
    while(start-1 >= 0 && is_num(buf[start-1]) )start--;
    while(stop+1 <= f_size && is_num(buf[stop+1]) )stop++;
    int i=0;
    std::string_view sv(buf+start, stop-start+1);
    auto result = std::from_chars(sv.data(), sv.data() + sv.size(), i);
    if (result.ec == std::errc::invalid_argument) {
        std::cout << "could not convert " << sv << " to int\n";
    }
    return i;
}

static inline int gear_adjacent_numbers(size_t p, const char *buf, size_t f_size, size_t &gear_ratio){
    const constexpr size_t cols = 141;
    const constexpr size_t rows = 140;
    size_t x = p%cols;
    size_t y = p/cols;

    int n_adj=0;
    int ratio=1;
    // first check cardinal directions
    //   x
    //  xpx
    //   x
    // if these dont have numbers need to check diagonals 

    //y-1
    if(y!=0){
        char c = buf[(x  )+(y-1)*cols];
        if( is_num(c)){
            ratio *= parse_num_at((x  )+(y-1)*cols, buf,f_size);
            n_adj+=1;
        } else {
            //x-1 y-1
            if(x!=0 && y!=0){
                char c = buf[(x-1)+(y-1)*cols];
                if( is_num(c)){
                    ratio *= parse_num_at((x-1)+(y-1)*cols, buf,f_size);
                    n_adj+=1;
                }
            }
            //x+1 y-1
            if(y!=0 && x!=cols-2){
                char c = buf[(x+1)+(y-1)*cols];
                if( is_num(c)){
                    ratio *= parse_num_at((x+1)+(y-1)*cols, buf,f_size);
                    n_adj+=1;
                }
            }
        }
    }

    //y+1
    if(y!=rows){
        char c = buf[(x  )+(y+1)*cols];
        if( is_num(c)){
            ratio *= parse_num_at((x  )+(y+1)*cols, buf,f_size);
            n_adj+=1;
        } else {
            //x-1 y+1
            if(x!=0&&y!=rows){
                char c = buf[(x-1)+(y+1)*cols];
                if( is_num(c)){
                    ratio *= parse_num_at((x-1)+(y+1)*cols, buf,f_size);
                    n_adj+=1;
                }
            }
            //x+1 y+1
            if(y!=rows&&x!=cols-2){
                char c = buf[(x+1)+(y+1)*cols];
                if( is_num(c)){
                    ratio *= parse_num_at((x+1)+(y+1)*cols, buf,f_size);
                    n_adj+=1;
                }
            }
        }
    }
    
    //x-1
    if(x!=0){
        char c = buf[(x-1)+(y  )*cols];
        if( is_num(c)){
            ratio *= parse_num_at((x-1)+(y  )*cols, buf,f_size);
            n_adj+=1;
        }
    }
    //x+1
    if(x!=cols-2){
        char c = buf[(x+1)+(y  )*cols];
        if( is_num(c)){
            ratio *= parse_num_at((x+1)+(y  )*cols, buf,f_size);
            n_adj+=1;
        }
    }


    gear_ratio=ratio;
    return n_adj;
}

int main(){
    // Get size of file to know how much memory to allocate
    std::uintmax_t f_size = std::filesystem::file_size("input");
    char* buf = new char[f_size]; // should use vector....
    std::ifstream fin("input", std::ios::binary);
    fin.read(buf, f_size);
    if(!fin) {
        std::cerr << "Error reading file, could only read " << fin.gcount() << " bytes" << std::endl;
    }
    fin.close();
    std::cout << f_size << "\n";


    std::vector<int> nums;
    const constexpr size_t cols = 141;
    const constexpr size_t rows = 140;

    size_t start=0;
    size_t stop=0;

    size_t p = 0;
    while(p <= f_size){
        size_t gear_ratio=0;
        while(p <= f_size && buf[p]!='*' ) p++;
        if( gear_adjacent_numbers(p,buf,f_size, gear_ratio) == 2)
            nums.push_back(gear_ratio);
        p++;
    }

    std::cout << "sum: " << std::accumulate(nums.begin(), nums.end(), 0);

}