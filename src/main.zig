const WebView = @import("./webview/webview.zig").WebView;

pub fn main() void {
    const w = WebView.create(false, null);
    defer w.destroy();
    w.setTitle("Discord App");
    w.setSize(1024, 720, .None);
    w.navigate("https://nano.gift/");
    w.run();
}