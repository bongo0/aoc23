// zig build-exe asd2.zig
const std = @import("std");

const fname = "input";
const input = @embedFile(fname); // cool

const Node = struct {
    left:  [3]u8 = std.mem.zeroes([3]u8),
    right: [3]u8 = std.mem.zeroes([3]u8)
};

fn found_end(starts: std.ArrayList([3]u8) ) bool {
    for(0..starts.items.len)|i|{
        if(starts.items[i][2]!='Z') return false;
    }
    return true;
}



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
    var starts = std.ArrayList([3]u8).init(gpa);
    defer starts.deinit();

    var graph_it = graph.keyIterator();
    while(graph_it.next())|k|{
        if(k[2]=='A') {
            try starts.append(k.*);
            std.debug.print(" start: {s}\n", .{k});
        }
        if(k[2]=='Z') {
            std.debug.print("   end: {s}\n", .{k});
        }
    }

    var first_ends = std.ArrayList(u64).init(gpa);
    defer first_ends.deinit();

    // const end   = [3]u8 {'Z','Z','Z'};
    // var curr : [3]u8 = [3]u8{'A','A','A'};
// try if least common multiple works for the data.. might not work in general
    var counter : u64 = 0;
    var ip : u64 = 0;
    for(0..starts.items.len)|i|{
        std.debug.print("Number of steps for {s}:{d}\n", .{starts.items[i],i});
        counter = 0;
        while( starts.items[i][2]!='Z' ){
            counter+=1;
            const n = graph.get( starts.items[i] );
            if(n==null){ std.debug.print("did not find the node {s}\n", .{starts.items[i]}); break; }
            const c = instructions[ip];
            if(c=='L'){
                starts.items[i] = n.?.left;
            } else if (c=='R'){
                starts.items[i] = n.?.right;
            } else {
                std.debug.print("unknown instruction {c}\n", .{c});
            }
            ip=(ip+1)%(instructions.len);
        }
        try first_ends.append(counter);
        std.debug.print("   count: {d}\n", .{counter});
    }
    var res : u64 = first_ends.items[0];
    for(1..first_ends.items.len)|i|{
        res = lcm(res, first_ends.items[i]);
    }
    std.debug.print("Number of steps {d}\n", .{res});
}

fn gcd(a:u64, b:u64) u64 {
    if(b==0) return a;
    return gcd(b, a%b);
}

fn lcm(a:u64,b:u64) u64 {
    return a*(b / gcd(a,b));
}