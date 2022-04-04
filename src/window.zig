const c = @import("c.zig").c;

pub const Window = struct {
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
