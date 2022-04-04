const std = @import("std");
const c = @import("c.zig").c;

const Window = struct {
    sdl_window: *c.SDL_Window,
    width: usize,
    height: usize,

    pub fn init(width: usize, height: usize, is_fullscreen: bool) !Window {
        if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
            return error.SDLInitFailed;
        }

        var display_mode: c.SDL_DisplayMode = undefined;
        if (c.SDL_GetCurrentDisplayMode(0, &display_mode) != 0) {
            return error.WindowInitFailed;
        }
        var real_w = if (is_fullscreen) @intCast(usize, display_mode.w) else width;
        var real_h = if (is_fullscreen) @intCast(usize, display_mode.h) else height;

        var window = c.SDL_CreateWindow(
            "Soft renderer",
            c.SDL_WINDOWPOS_CENTERED,
            c.SDL_WINDOWPOS_CENTERED,
            @intCast(c_int, real_w),
            @intCast(c_int, real_h),
            c.SDL_WINDOW_BORDERLESS,
        ) orelse {
            return error.WindowInitFailed;
        };

        return Window{ .sdl_window = window, .width = real_w, .height = real_h };
    }

    pub fn deinit(self: *Window) void {
        c.SDL_DestroyWindow(self.sdl_window);
        c.SDL_Quit();
    }
};

const Renderer = struct {
    window: *Window,
    sdl_renderer: *c.SDL_Renderer,
    texture: *c.SDL_Texture,
    color_buffer: []u32,

    pub fn init(allocator: *std.mem.Allocator, window: *Window) !Renderer {
        var renderer = c.SDL_CreateRenderer(window.sdl_window, -1, 0) orelse {
            return error.RendererInitFailed;
        };

        var color_buffer: []u32 = try allocator.alloc(u32, window.width * window.height);

        var color_buffer_texture = c.SDL_CreateTexture(
            renderer,
            c.SDL_PIXELFORMAT_ARGB8888,
            c.SDL_TEXTUREACCESS_STREAMING,
            @intCast(c_int, window.width),
            @intCast(c_int, window.height),
        ) orelse {
            return error.RendererInitFailed;
        };

        return Renderer{
            .window = window,
            .sdl_renderer = renderer,
            .texture = color_buffer_texture,
            .color_buffer = color_buffer,
        };
    }

    pub fn deinit(self: *Renderer) void {
        c.SDL_DestroyRenderer(self.sdl_renderer);
    }

    pub fn clear_screen(self: *Renderer, color: u32) !void {
        if (c.SDL_RenderClear(self.sdl_renderer) != 0) {
            return error.RenderError;
        }

        for (self.color_buffer) |_, index| {
            self.color_buffer[index] = color;
        }
    }

    pub fn draw_grid(self: *Renderer, color: u32, spacing: usize) void {
        var x: usize = 0;
        var y: usize = 0;

        while (x < self.window.width) : (x += spacing) {
            y = 0;
            while (y < self.window.height) : (y += spacing) {
                self.color_buffer[y * self.window.width + x] = color;
            }
        }
    }

    fn draw_rect(self: *Renderer, color: u32, x: usize, y: usize, w: usize, h: usize) void {
        var init_y = y;
        var x1 = x;
        var y1 = y;
        var x2 = x + w;
        var y2 = y + h;
        while (x1 < x2) : (x1 += 1) {
            y1 = init_y;
            while (y1 < y2) : (y1 += 1) {
                self.color_buffer[y1 * self.window.width + x1] = color;
            }
        }
    }

    pub fn render(self: *Renderer) !void {
        if (c.SDL_UpdateTexture(
            self.texture,
            null,
            self.color_buffer.ptr,
            @intCast(c_int, self.window.width * @sizeOf(u32)),
        ) != 0) {
            return error.RenderError;
        }
        if (c.SDL_RenderCopy(self.sdl_renderer, self.texture, null, null) != 0) {
            return error.RenderError;
        }

        c.SDL_RenderPresent(self.sdl_renderer);
    }
};

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

fn clear_color_buffer(color_buffer: []u32, color: u32) void {
    for (color_buffer) |_, index| {
        color_buffer[index] = color;
    }
}

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
