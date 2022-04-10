const std = @import("std");
const c = @import("c.zig").c;
const ArrayList = std.ArrayList;
const Window = @import("window.zig").Window;
const Renderer = @import("renderer.zig").Renderer;
const v = @import("vector.zig");
const Vector3 = v.Vector3;
const Vector2 = v.Vector2;
const Camera = @import("camera.zig").Camera;
const Cube = @import("geometry.zig").Cube;
const Triangle = @import("geometry.zig").Triangle;

const FPS = 60;
const FRAME_TARGET_TIME: u32 = 1000 / FPS;
var cube_rotation = Vector3{ .x = 0, .y = 0, .z = 0 };
var previous_frame_time: u32 = 0;
var triangles_to_render: ArrayList(Triangle) = undefined;

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

fn setup(allocator: std.mem.Allocator) void {
    triangles_to_render = ArrayList(Triangle).init(allocator);
}

fn update(cube: *Cube, camera: *Camera) !void {
    var delta: isize = c.SDL_GetTicks() - previous_frame_time;
    var time_to_wait: isize = FRAME_TARGET_TIME - delta;
    if (time_to_wait > 0 and time_to_wait < FRAME_TARGET_TIME) {
        c.SDL_Delay(@intCast(u32, time_to_wait));
    }
    previous_frame_time = c.SDL_GetTicks();

    try triangles_to_render.resize(0);

    cube_rotation = cube_rotation.add_scalar(0.005);

    for (cube.faces) |face| {
        var face_vertices: [3]Vector3 = undefined;
        face_vertices[0] = cube.geometry[face.a - 1];
        face_vertices[1] = cube.geometry[face.b - 1];
        face_vertices[2] = cube.geometry[face.c - 1];

        var projected_triangle: Triangle = undefined;
        for (face_vertices) |vertex, face_index| {
            var transformed = vertex.rotate(cube_rotation).sub(camera.position);
            var projected = Vector2.from_vec3(transformed).mult_scalar(camera.fov).div_scalar(transformed.z);
            projected_triangle.points[face_index] = projected;
        }
        try triangles_to_render.append(projected_triangle);
    }

    // for (cube_points) |point, index| {
    //     var transformed = point.rotate(cube_rotation).sub(camera.position);
    //     projected_points[index] = Vector2.from_vec3(transformed).mult_scalar(camera.fov).div_scalar(transformed.z);
    // }
}

fn render(renderer: *Renderer) !void {
    try renderer.clear_screen(0xFF303030);
    // renderer.draw_grid(0xFFBBBBBB, 10);

    for (triangles_to_render.items) |triangle| {
        var projected_points: [3]Vector2 = undefined;

        for (triangle.points) |point, index| {
            projected_points[index] = point.add(Vector2{
                .x = @intToFloat(f32, renderer.window.width) / 2,
                .y = @intToFloat(f32, renderer.window.height) / 2,
            });
        }

        for (projected_points) |point| {
            renderer.draw_rect(
                0xFF00FF00,
                @floatToInt(isize, point.x),
                @floatToInt(isize, point.y),
                4,
                4,
            );
        }

        renderer.draw_triangle(
            0xFFFFFFFF,
            @floatToInt(isize, projected_points[0].x),
            @floatToInt(isize, projected_points[0].y),
            @floatToInt(isize, projected_points[1].x),
            @floatToInt(isize, projected_points[1].y),
            @floatToInt(isize, projected_points[2].x),
            @floatToInt(isize, projected_points[2].y),
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

    var cube = Cube.init(1);

    setup(allocator);
    defer {
        renderer.deinit();
        window.deinit();
    }

    while (is_running) {
        try process_events(&is_running);
        try update(&cube, &camera);
        try render(&renderer);
    }
}
