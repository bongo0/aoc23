// zig build-exe asd1.zig
const std = @import("std");

const fname = "input";
const input = @embedFile(fname); // cool

const Node = struct {
    left:  [3]u8 = std.mem.zeroes([3]u8),
    right: [3]u8 = std.mem.zeroes([3]u8)
};


pub fn main() !void {
    std.debug.print("input file: `{s}`\n", .{fname});

    var gpa_ = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_.allocator();

    // graph:
    // node_key = Node(left_node_key, right_node_key)
    var graph = std.AutoHashMap([3]u8, Node).init(gpa);
    defer graph.deinit();

    // do simple dumb parsing of the input
    var lines = std.mem.split(u8, input, "\n");
    const instructions : []const u8 = lines.next() orelse "";
    std.debug.print(" instructions: {s} \n", .{instructions});
    // ...
    while(lines.next()) |line| {
        if(line.len == 0)continue;
        var name : [3]u8 = undefined;
        var node : Node = undefined;
        var f : u32 = 0;
        var i : u32 = 0;
        while(i < line.len) : (i+=1){
            if(line[i]=='=' or 
               line[i]==',' or 
               line[i]=='(' or 
               line[i]==')' or 
               line[i]==' ' or 
               line[i]=='\t'){ continue;}
            else{
                switch (f){
                    0 => {@memcpy(&name,       line[i..(i+3)] ); f+=1; i+=3; },
                    1 => {@memcpy(&node.left,  line[i..(i+3)] ); f+=1; i+=3; },
                    2 => {@memcpy(&node.right, line[i..(i+3)] ); f+=1; i+=3; },
                    else => {std.debug.print("parse error {s}\n", .{line}); break;}
                }
            }
        }
        if(f==3){
            //std.debug.print(" line: n:{s}, l:{s}, r:{s}      <= {s}\n", .{name, node.left, node.right, line});
            try graph.put(name, node);
        } else {
            std.debug.print("parse error {s}\n", .{line});
        }
    }
    
    // var graph_it = graph.iterator();
    // while(graph_it.next()) |kv| {
    //     std.debug.print("key {s} val ({s}, {s})\n", .{kv.key_ptr.*, kv.value_ptr.left, kv.value_ptr.right});
    // }
    
    /////////////////
    //const start : [3]u8 = [3]u8{'A','A','A'};
    const end   = [3]u8 {'Z','Z','Z'};
    var curr : [3]u8 = [3]u8{'A','A','A'};

    var counter : u64 = 0;
    var ip : u64 = 0;
    while( !std.mem.eql(u8, &curr, &end) ){
        counter+=1;
        const n = graph.get(curr);
        if(n==null){ std.debug.print("did not find the node {s}\n", .{curr}); break; }
        const c = instructions[ip];
        if(c=='L'){
            curr = n.?.left;
        } else if (c=='R'){
            curr = n.?.right;
        } else {
            std.debug.print("unknown instruction {c}\n", .{c});
        }
        ip=(ip+1)%(instructions.len);
    }
    std.debug.print("Number of steps {d}\n", .{counter});


}

