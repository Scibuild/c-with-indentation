const std = @import("std");

var lineBuffer = [_]u8{0} ** 1024;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    if (args.len != 2) {
        std.log.err("Please provide exactly one file name.", .{});
        return;
    }

    const infile = std.fs.cwd().openFile(args[1], .{}) catch {
        std.log.err("Could not open file \"{s}\".", .{args[1]});
        return;
    };
    defer infile.close();

    const reader = std.io.bufferedReader(infile.reader()).reader();
    const firstLine = try reader.readUntilDelimiter(lineBuffer[0..], '\n');
    for (firstLine) |*c| {
        c.* = std.ascii.toLower(c.*);
    }

    if (!std.mem.startsWith(u8, firstLine, "#tabsize ")) {
        std.log.err("File does not declare tab size, please prefix file with \"#tabsize <number>\".", .{});
        return;
    }
    var startOfNumber: u32 = 9;
    while (startOfNumber < firstLine.len and firstLine[startOfNumber] == ' ') startOfNumber += 1;

    const tabSize = std.fmt.parseInt(u8, firstLine[startOfNumber..], 10) catch {
        std.log.err("#tabsize takes a single positive non-zero integer.", .{});
        return;
    };

    while (startOfNumber < firstLine.len and std.ascii.isDigit(firstLine[startOfNumber])) startOfNumber += 1;
    while (startOfNumber < firstLine.len and firstLine[startOfNumber] == ' ') startOfNumber += 1;

    if (tabSize == 0 or startOfNumber != firstLine.len) {
        std.log.err("#tabsize takes a single positive non-zero integer.", .{});
        return;
    }

    var outfileName = try gpa.allocator().alloc(u8, args[1].len + 2);
    std.mem.copy(u8, outfileName, args[1]);
    outfileName[outfileName.len - 2] = '.';
    outfileName[outfileName.len - 1] = 'c';
    defer gpa.allocator().free(outfileName);
    const outfile = try std.fs.cwd().createFile(outfileName, .{});
    defer outfile.close();

    const writer = std.io.bufferedWriter(outfile.writer()).writer();

    var prevLineIndent: u32 = 0;
    var currLineIndent: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(lineBuffer[0..], '\n')) |line| {
        var locInBuffer: u32 = 0;
        currLineIndent = 0;
        while (true) {
            if (locInBuffer >= line.len) break;

            if (line[locInBuffer] == ' ') {
                currLineIndent += 1;
            } else if (line[locInBuffer] == '\t') {
                currLineIndent += tabSize;
            } else {
                break;
            }
            locInBuffer += 1;
        }
        if (locInBuffer >= line.len) {
            try writer.writeByte('\n');
            continue;
        }

        currLineIndent = @divFloor(currLineIndent, tabSize);

        if (currLineIndent > prevLineIndent) {
            try writer.writeByteNTimes('{', currLineIndent - prevLineIndent);
        }

        if (currLineIndent < prevLineIndent) {
            try writer.writeByteNTimes('}', prevLineIndent - currLineIndent);
        }
        try writer.writeByte('\n');
        try writer.writeAll(line);

        prevLineIndent = currLineIndent;
    }
    if (prevLineIndent > 0) {
        try writer.writeByteNTimes('}', prevLineIndent);
        try writer.writeByte('\n');
    }
    try writer.context.flush();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
