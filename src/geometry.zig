const std = @import("std");
const Vector3 = @import("vector.zig").Vector3;
const Vector2 = @import("vector.zig").Vector2;

pub const Face = struct {
    a: usize,
    b: usize,
    c: usize,
};

pub const Triangle = struct {
    points: [3]Vector2,
};

pub const Mesh = struct {
    vertices: std.ArrayList(Vector3),
    faces: std.ArrayList(Face),
};

pub const Entity = struct {
    rotation: Vector3 = .{ .x = 0, .y = 0, .z = 0 },
    position: Vector3 = .{ .x = 0, .y = 0, .z = 0 },
};

pub const Cube = struct {
    mesh: Mesh,
    entity: Entity,

    pub fn init(allocator: std.mem.Allocator, size: f32) !Cube {
        var vertices = try std.ArrayList(Vector3).initCapacity(allocator, 8);
        var faces = try std.ArrayList(Face).initCapacity(allocator, 12);

        var vertices_array = [_]Vector3{
            .{ .x = size * -1, .y = size * -1, .z = size * -1 },
            .{ .x = size * -1, .y = size * 1, .z = size * -1 },
            .{ .x = size * 1, .y = size * 1, .z = size * -1 },
            .{ .x = size * 1, .y = size * -1, .z = size * -1 },
            .{ .x = size * 1, .y = size * 1, .z = size * 1 },
            .{ .x = size * 1, .y = size * -1, .z = size * 1 },
            .{ .x = size * -1, .y = size * 1, .z = size * 1 },
            .{ .x = size * -1, .y = size * -1, .z = size * 1 },
        };
        var faces_array = [_]Face{
            // front
            .{ .a = 1, .b = 2, .c = 3 },
            .{ .a = 1, .b = 3, .c = 4 },
            // right
            .{ .a = 4, .b = 3, .c = 5 },
            .{ .a = 4, .b = 5, .c = 6 },
            // back
            .{ .a = 6, .b = 5, .c = 7 },
            .{ .a = 6, .b = 7, .c = 8 },
            // left
            .{ .a = 8, .b = 7, .c = 2 },
            .{ .a = 8, .b = 2, .c = 1 },
            // top
            .{ .a = 2, .b = 7, .c = 5 },
            .{ .a = 2, .b = 5, .c = 3 },
            // bottom
            .{ .a = 6, .b = 8, .c = 1 },
            .{ .a = 6, .b = 1, .c = 4 },
        };

        try vertices.appendSlice(vertices_array[0..]);
        try faces.appendSlice(faces_array[0..]);

        return Cube{
            .mesh = .{
                .vertices = vertices,
                .faces = faces,
            },
            .entity = .{},
        };
    }
};
