const std = @import("std");
const c = @import("c.zig").c;
const Window = @import("window.zig").Window;
const Renderer = @import("renderer.zig").Renderer;
const v = @import("vector.zig");
const Vector3 = v.Vector3;
const Vector2 = v.Vector2;
const Camera = @import("camera.zig").Camera;

const FPS = 60;
const FRAME_TARGET_TIME: u32 = 1000 / FPS;
var cube_rotation = Vector3{ .x = 0, .y = 0, .z = 0 };
var previous_frame_time: u32 = 0;

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

fn setup(cube_points: []Vector3) void {
    var index: usize = 0;
    var x: f32 = -1;
    var y: f32 = -1;
    var z: f32 = -1;

    while (x <= 1) : (x += 0.25) {
        y = -1;
        while (y <= 1) : (y += 0.25) {
            z = -1;
            while (z <= 1) : (z += 0.25) {
                cube_points[index] = Vector3{ .x = x, .y = y, .z = z };
                index += 1;
            }
        }
    }
}

fn update(cube_points: []Vector3, projected_points: []Vector2, camera: *Camera) !void {
    var time_to_wait: isize = @intCast(isize, previous_frame_time + FRAME_TARGET_TIME) - c.SDL_GetTicks();
    if (time_to_wait > 0) {
        c.SDL_Delay(@intCast(u32, time_to_wait));
    }
    previous_frame_time = c.SDL_GetTicks();

    cube_rotation = cube_rotation.add_scalar(0.005);

    for (cube_points) |point, index| {
        var transformed = point.rotate(cube_rotation).sub(camera.position);
        projected_points[index] = Vector2.from_vec3(transformed).mult_scalar(camera.fov).div_scalar(transformed.z);
    }
}

fn render(
    renderer: *Renderer,
    projected_points: []Vector2,
) !void {
    try renderer.clear_screen(0xFF303030);
    renderer.draw_grid(0xFFBBBBBB, 10);
    // renderer.draw_rect(0xFFFF0000, 10, 20, 40, 30);
    // renderer.draw_pixel(0xFFFF0000, 100, 100);

    for (projected_points) |point| {
        renderer.draw_rect(
            0xFF00FF00,
            @floatToInt(isize, point.x) + @divExact(@intCast(isize, renderer.window.width), 2),
            @floatToInt(isize, point.y) + @divExact(@intCast(isize, renderer.window.height), 2),
            4,
            4,
        );
    }

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
    var camera = Camera{ .position = Vector3{ .x = 0, .y = 0, .z = -5 }, .fov = 640 };

    const vertices = 9 * 9 * 9;
    var cube_points: [vertices]Vector3 = undefined;
    var cube_points_slice = cube_points[0..];
    var projected_points: [vertices]Vector2 = undefined;
    var projected_points_slice = projected_points[0..];

    setup(cube_points_slice);
    defer {
        renderer.deinit();
        window.deinit();
    }

    while (is_running) {
        try process_events(&is_running);
        try update(cube_points_slice, projected_points_slice, &camera);
        try render(&renderer, projected_points_slice);
    }
}
