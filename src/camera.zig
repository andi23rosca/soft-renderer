const std = @import("std");
const v = @import("vector.zig");
const Vector3 = v.Vector3;

pub const Camera = struct {
    position: Vector3 = Vector3{ .x = 0, .y = 0, .z = 0 },
    rotation: Vector3 = Vector3{ .x = 0, .y = 0, .z = 0 },
    fov: f32 = 640,
};
