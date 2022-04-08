const std = @import("std");
const sin = std.math.sin;
const cos = std.math.cos;

pub const Vector2 = struct {
    x: f32,
    y: f32,

    pub fn from_vec3(vec3: Vector3) Vector2 {
        return Vector2{ .x = vec3.x, .y = vec3.y };
    }

    pub fn mult_scalar(v: Vector2, scalar: f32) Vector2 {
        return Vector2{ .x = v.x * scalar, .y = v.y * scalar };
    }
    pub fn add_scalar(v: Vector2, scalar: f32) Vector2 {
        return Vector2{ .x = v.x + scalar, .y = v.y + scalar };
    }
    pub fn sub_scalar(v: Vector2, scalar: f32) Vector2 {
        return Vector2{ .x = v.x - scalar, .y = v.y - scalar };
    }
    pub fn div_scalar(v: Vector2, scalar: f32) Vector2 {
        return Vector2{ .x = v.x / scalar, .y = v.y / scalar };
    }
    pub fn mult(v: Vector2, vec: Vector2) Vector2 {
        return Vector2{ .x = v.x * vec.x, .y = v.y * vec.y };
    }
    pub fn add(v: Vector2, vec: Vector2) Vector2 {
        return Vector2{ .x = v.x + vec.x, .y = v.y + vec.y };
    }
    pub fn sub(v: Vector2, vec: Vector2) Vector2 {
        return Vector2{ .x = v.x - vec.x, .y = v.y - vec.y };
    }
    pub fn div(v: Vector2, vec: Vector2) Vector2 {
        return Vector2{ .x = v.x / vec.x, .y = v.y / vec.y };
    }
};

pub const Vector3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn mult_scalar(v: Vector3, scalar: f32) Vector3 {
        return Vector3{ .x = v.x * scalar, .y = v.y * scalar, .z = v.z * scalar };
    }
    pub fn add_scalar(v: Vector3, scalar: f32) Vector3 {
        return Vector3{ .x = v.x + scalar, .y = v.y + scalar, .z = v.z + scalar };
    }
    pub fn sub_scalar(v: Vector3, scalar: f32) Vector3 {
        return Vector3{ .x = v.x - scalar, .y = v.y - scalar, .z = v.z - scalar };
    }
    pub fn div_scalar(v: Vector3, scalar: f32) Vector3 {
        return Vector3{ .x = v.x / scalar, .y = v.y / scalar, .z = v.z / scalar };
    }
    pub fn mult(v: Vector3, vec: Vector3) Vector3 {
        return Vector3{ .x = v.x * vec.x, .y = v.y * vec.y, .z = v.z * vec.z };
    }
    pub fn add(v: Vector3, vec: Vector3) Vector3 {
        return Vector3{ .x = v.x + vec.x, .y = v.y + vec.y, .z = v.z + vec.z };
    }
    pub fn sub(v: Vector3, vec: Vector3) Vector3 {
        return Vector3{ .x = v.x - vec.x, .y = v.y - vec.y, .z = v.z - vec.z };
    }
    pub fn div(v: Vector3, vec: Vector3) Vector3 {
        return Vector3{ .x = v.x / vec.x, .y = v.y / vec.y, .z = v.z / vec.z };
    }

    pub fn rotate(v: Vector3, axis: Vector3) Vector3 {
        return v.rotate_x(axis.x).rotate_y(axis.y).rotate_z(axis.z);
    }

    pub fn rotate_x(v: Vector3, angle: f32) Vector3 {
        return Vector3{
            .x = v.x,
            .y = v.y * cos(angle) - v.z * sin(angle),
            .z = v.y * sin(angle) + v.z * cos(angle),
        };
    }
    pub fn rotate_y(v: Vector3, angle: f32) Vector3 {
        return Vector3{
            .x = v.x * cos(angle) - v.z * sin(angle),
            .y = v.y,
            .z = v.x * sin(angle) + v.z * cos(angle),
        };
    }
    pub fn rotate_z(v: Vector3, angle: f32) Vector3 {
        return Vector3{
            .x = v.x * cos(angle) - v.y * sin(angle),
            .y = v.x * sin(angle) + v.y * cos(angle),
            .z = v.z,
        };
    }
};
