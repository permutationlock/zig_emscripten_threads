const std = @import("std");
const Thread = std.Thread;
const ResetEvent = Thread.ResetEvent;

fn testIncrementNotify(v: *usize, e: *ResetEvent) void {
    v.* += 1;
    e.set();
}

pub fn update() void {
    var event = ResetEvent{};
    var value: usize = 0;
    const thread = Thread.spawn(.{}, testIncrementNotify, .{ &value, &event })
        catch unreachable;
    thread.detach();
    event.wait();
    std.io.getStdOut().writer().print("value: {}\n", .{ value })
        catch unreachable;
}

var update_thread: Thread = undefined;

pub fn main() void { 
    // can't block for join/detach on main browser thread, must spawn a pthread
    update_thread = Thread.spawn(.{}, update, .{}) catch unreachable;
}
