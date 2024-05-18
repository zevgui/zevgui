const std = @import("std");
const WebView = @import("./webview/webview.zig").WebView;
const Zev = @import("./zev/lib.zig");

// Currently we're in test phase. i.e, this project will soon be a lib by itself.
pub fn main() !void {
    var allocator = std.heap.c_allocator;

    var window = Zev.init(.{ .allocator = &allocator, .frame = false });
    defer window.deinit();

    window.full_screen(null);

    window.internal.webview.navigate("https://youtube.com/");
    window.internal.webview.run();
}