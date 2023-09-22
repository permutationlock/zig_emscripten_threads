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

pub fn main() void {
    // calling join or detach from main browser thread causes issues
    _ = Thread.spawn(.{}, update, .{}) catch unreachable;
}
