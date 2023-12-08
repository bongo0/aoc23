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



int main(){
    // Get size of file to know how much memory to allocate
    std::uintmax_t f_size = std::filesystem::file_size("input");
    char* buf = new char[f_size];
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
        
        while(p <= f_size && !is_num(buf[p]) ) p++;
        // new num start
        start = p;stop = p;
        bool b = has_nb_sym(p,buf);

        while(is_num(buf[++p])){
            stop++;
            if(!b) b = has_nb_sym(p,buf);
        }
        if(b){
            //
            std::string_view sv(buf+start, stop-start+1);
            std::cout << sv << "   ";
            int i=0;
            auto result = std::from_chars(sv.data(), sv.data() + sv.size(), i);
            if (result.ec == std::errc::invalid_argument) {
                std::cout << "could not convert " << sv << " to int\n";
            }
            nums.push_back(i);
        } else {
            std::string_view sv(buf+start, stop-start+1);
            std::cout << "(" << sv << ") ";
        }

    }

    std::cout << "sum: " << std::accumulate(nums.begin(), nums.end(), 0);

}