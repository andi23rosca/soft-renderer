const std = @import("std");
const c = @import("c.zig").c;
const Window = @import("window.zig").Window;
const Renderer = @import("renderer.zig").Renderer;

fn process_events(is_running: *bool) !void {
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event) == 1) {
        switch (event.type) {
            c.SDL_QUIT => {
                is_running.* = false;
            },
            c.SDL_KEYDOWN => {
                if (event.key.keysym.sym == c.SDLK_ESCAPE) {
                    is_running.* = false;
                }
            },
            else => {},
        }
    }
}

fn update() !void {}

fn render(
    renderer: *Renderer,
) !void {
    try renderer.clear_screen(0xFF303030);
    renderer.draw_grid(0xFFBBBBBB, 10);
    renderer.draw_rect(0xFFFF0000, 10, 20, 40, 30);
    try renderer.render();
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var width: usize = 800;
    var height: usize = 600;
    var window = try Window.init(width, height, false);
    var renderer = try Renderer.init(&allocator, &window);
    var is_running = true;

    defer {
        renderer.deinit();
        window.deinit();
    }

    // Wait for the user to close the window.
    while (is_running) {
        try process_events(&is_running);
        try update();
        try render(&renderer);
    }
}
