const std = @import("std");
const c = @import("c.zig").c;
const ArrayList = std.ArrayList;
const Window = @import("window.zig").Window;
const Renderer = @import("renderer.zig").Renderer;
const Vector3 = @import("vector.zig").Vector3;
const Vector2 = @import("vector.zig").Vector2;
const Camera = @import("camera.zig").Camera;
const Cube = @import("geometry.zig").Cube;
const Mesh = @import("geometry.zig").Mesh;
const Entity = @import("geometry.zig").Entity;
const Triangle = @import("geometry.zig").Triangle;
const read_obj_file = @import("reader.zig").read_obj_file;

const FPS = 60;
const FRAME_TARGET_TIME: u32 = 1000 / FPS;
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

fn update(mesh: *Mesh, entity: *Entity, camera: *Camera) !void {
    var delta: isize = c.SDL_GetTicks() - previous_frame_time;
    var time_to_wait: isize = FRAME_TARGET_TIME - delta;
    if (time_to_wait > 0 and time_to_wait < FRAME_TARGET_TIME) {
        c.SDL_Delay(@intCast(u32, time_to_wait));
    }
    previous_frame_time = c.SDL_GetTicks();

    try triangles_to_render.resize(0);

    entity.rotation = entity.rotation.add(.{
        .x = 0.01,
        .y = 0.01,
        .z = 0.01,
    });

    for (mesh.faces.items) |face| {
        var face_vertices: [3]Vector3 = undefined;
        face_vertices[0] = mesh.vertices.items[face.a - 1];
        face_vertices[1] = mesh.vertices.items[face.b - 1];
        face_vertices[2] = mesh.vertices.items[face.c - 1];

        // Transforming
        for (face_vertices) |vertex, face_index| {
            face_vertices[face_index] = vertex.rotate(entity.rotation).add(.{ .x = 0, .y = 0, .z = 5 });
        }

        // Backface culling
        var face_normal = Vector3.cross(
            face_vertices[1].sub(face_vertices[0]),
            face_vertices[2].sub(face_vertices[0]),
        ).normalize();
        var camera_ray = camera.position.sub(face_vertices[0]);
        var dot_alignment = camera_ray.dot(face_normal);
        if (dot_alignment < 0) {
            continue;
        }

        // Projecting
        var projected_triangle: Triangle = undefined;
        for (face_vertices) |vertex, face_index| {
            var projected = Vector2.from_vec3(vertex).mult_scalar(camera.fov).div_scalar(vertex.z);
            projected_triangle.points[face_index] = projected;
        }

        try triangles_to_render.append(projected_triangle);
    }
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

        // for (projected_points) |point| {
        //     renderer.draw_rect(
        //         0xFF00FF00,
        //         @floatToInt(isize, point.x),
        //         @floatToInt(isize, point.y),
        //         4,
        //         4,
        //     );
        // }

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
    var camera = Camera{ .position = Vector3{ .x = 0, .y = 0, .z = 0 }, .fov = 640 };

    var mesh = try read_obj_file(allocator, "models/cube.obj");
    var entity = Entity{ .rotation = .{
        .x = 0,
        .y = 0,
        .z = 0,
    } };
    // var cube = try Cube.init(allocator, 1);

    setup(allocator);
    defer {
        // cube.deinit();
        renderer.deinit();
        window.deinit();
    }

    while (is_running) {
        try process_events(&is_running);
        try update(&mesh, &entity, &camera);
        try render(&renderer);
    }
}
