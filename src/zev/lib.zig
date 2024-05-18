allocator: *std.mem.Allocator,
internal: Internal,

const std = @import("std");
const WebView = @import("../webview/webview.zig").WebView;

const Internal = struct { webview: WebView, size: ?WebView.WindowSizeHint };

const Options = struct {
    debug: ?bool = null,
    size: ?WebView.WindowSizeHint = null,
    allocator: *std.mem.Allocator,
    title: ?[:0]const u8 = null,
    frame: ?bool = true
};

const zev = @This();

pub fn init(opts: Options) zev {
    const webview = WebView.create(opts.debug orelse false, null);
    webview.setTitle(opts.title orelse "Zev App");

    return zev{ .allocator = opts.allocator, .internal = .{ .webview = webview, .size = opts.size.? } };
}

const ResOpts = struct { w: i32, h: i32, size: ?WebView.WindowSizeHint = null };
pub fn resize(self: zev, opts: ResOpts) void {
    if (opts.size != null) {
        return self.internal.webview.setSize(opts.w, opts.h, opts.size.?);
    } else {
        return self.internal.webview.setSize(opts.w, opts.h, .None);
    }
}

pub fn full_screen(self: zev, hint: ?WebView.WindowSizeHint) void {
    if (hint != null) {
        return self.internal.webview.setSize(1024, 1024, hint.?);
    } else {
        return self.internal.webview.setSize(1024, 1024, .None);
    }
}

pub fn destroy(self: zev) void {
    self.internal.webview.destroy();
}

pub fn deinit(self: zev) void {
    self.internal.webview.destroy();
}
