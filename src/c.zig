pub const c = @cImport({
    @cInclude("SDL.h");
});

pub fn sdl_init(flags: c_uint) !void {
    if (c.SDL_Init(flags) != 0) {
        return error.InitFailed;
    }
}
