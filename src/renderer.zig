const std = @import("std");
const c = @import("c.zig").c;
const Window = @import("window.zig").Window;

pub const Renderer = struct {
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
                self.draw_pixel(color, @intCast(isize, x), @intCast(isize, y));
            }
        }
    }

    pub fn draw_rect(self: *Renderer, color: u32, x: isize, y: isize, w: usize, h: usize) void {
        var init_y = y;
        var x1 = x;
        var y1 = y;
        var x2 = x + @intCast(isize, w);
        var y2 = y + @intCast(isize, h);
        while (x1 < x2) : (x1 += 1) {
            y1 = init_y;
            while (y1 < y2) : (y1 += 1) {
                self.draw_pixel(color, x1, y1);
            }
        }
    }

    pub fn draw_pixel(self: *Renderer, color: u32, x: isize, y: isize) void {
        if (x < 0 or x >= self.window.width or y < 0 or y >= self.window.height) {
            return;
        }
        self.color_buffer[@intCast(usize, y) * self.window.width + @intCast(usize, x)] = color;
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
