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

pub const Cube = struct {
    geometry: [8]Vector3,
    faces: [12]Face,

    pub fn init(size: f32) Cube {
        var geometry = [8]Vector3{
            Vector3{ .x = size * -1, .y = size * -1, .z = size * -1 },
            Vector3{ .x = size * -1, .y = size * 1, .z = size * -1 },
            Vector3{ .x = size * 1, .y = size * 1, .z = size * -1 },
            Vector3{ .x = size * 1, .y = size * -1, .z = size * -1 },
            Vector3{ .x = size * 1, .y = size * 1, .z = size * 1 },
            Vector3{ .x = size * 1, .y = size * -1, .z = size * 1 },
            Vector3{ .x = size * -1, .y = size * 1, .z = size * 1 },
            Vector3{ .x = size * -1, .y = size * -1, .z = size * 1 },
        };

        var faces = [12]Face{
            // front
            Face{ .a = 1, .b = 2, .c = 3 },
            Face{ .a = 1, .b = 3, .c = 4 },
            // right
            Face{ .a = 4, .b = 3, .c = 5 },
            Face{ .a = 4, .b = 5, .c = 6 },
            // back
            Face{ .a = 6, .b = 5, .c = 7 },
            Face{ .a = 6, .b = 7, .c = 8 },
            // left
            Face{ .a = 8, .b = 7, .c = 2 },
            Face{ .a = 8, .b = 2, .c = 1 },
            // top
            Face{ .a = 2, .b = 7, .c = 5 },
            Face{ .a = 2, .b = 5, .c = 3 },
            // bottom
            Face{ .a = 6, .b = 8, .c = 1 },
            Face{ .a = 6, .b = 1, .c = 4 },
        };

        return Cube{
            .geometry = geometry,
            .faces = faces,
        };
    }
};
