const std = @import("std");
const Thread = std.Thread;
const ResetEvent = Thread.ResetEvent;

fn testIncrementNotify(v: *usize, e: *ResetEvent) void {
    v.* += 1;
    e.set();
}

pub fn update() callconv(.C) void {
    var event = ResetEvent{};
    var value: usize = 0;
    const thread = Thread.spawn(.{}, testIncrementNotify, .{ &value, &event })
        catch unreachable;
    thread.detach();
    event.wait();
    std.debug.print("value: {}\n", .{ value });
}

pub fn main() void { 
    _ = Thread.spawn(.{}, update, .{}) catch unreachable;
}
