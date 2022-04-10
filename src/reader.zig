const std = @import("std");
const Vector3 = @import("vector.zig").Vector3;
const Mesh = @import("geometry.zig").Mesh;
const Face = @import("geometry.zig").Face;

pub fn read_obj_file(
    allocator: std.mem.Allocator,
    file_name: []const u8,
) !Mesh {
    var vertices = std.ArrayList(Vector3).init(allocator);
    var faces = std.ArrayList(Face).init(allocator);

    var content = try std.fs.cwd().readFileAlloc(allocator, file_name, std.math.maxInt(usize));
    var iter = std.mem.split(u8, content, "\n");

    while (iter.next()) |line| {
        var split_line = std.mem.split(u8, line, " ");

        var first_token = split_line.next() orelse "";
        if (std.mem.eql(u8, first_token, "v")) {
            try vertices.append(.{
                .x = try std.fmt.parseFloat(f32, split_line.next().?),
                .y = try std.fmt.parseFloat(f32, split_line.next().?),
                .z = try std.fmt.parseFloat(f32, split_line.next().?),
            });
        } else if (std.mem.eql(u8, first_token, "f")) {
            var face_indices: [3]usize = undefined;
            var index: usize = 0;
            while (split_line.next()) |face| : (index += 1) {
                var split_face = std.mem.split(u8, face, "/");
                face_indices[index] = try std.fmt.parseInt(usize, split_face.next().?, 10);
            }
            try faces.append(.{
                .a = face_indices[0],
                .b = face_indices[1],
                .c = face_indices[2],
            });
        }
    }

    return Mesh{
        .vertices = vertices,
        .faces = faces,
    };
}
