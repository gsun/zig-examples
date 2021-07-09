const std = @import("std");
const net = std.net;
const fs = std.fs;
const os = std.os;
const builtin = @import("builtin");

pub const io_mode = .evented;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var server = net.StreamServer.init(.{});
    defer server.deinit();

    var room = Room{.clients =  std.AutoHashMap(*Client, void).init(allocator)};

    const addr = try net.Address.parseIp("127.0.0.1", 0);
    try server.listen(addr);

    std.debug.warn("listening at {}\n", .{server.listen_address});

    while (true) {
        std.debug.print("Waiting for connection\n", .{});
        const client = try allocator.create(Client);
        client.* = Client{
            .conn = try server.accept(),
            .handle_frame = async client.handle(&room),
        };
        try room.clients.putNoClobber(client, {});
    }
}

const Client = struct {
    conn: net.StreamServer.Connection,
    handle_frame: @Frame(handle),

    fn handle(self: *Client, room: *Room) !void {
         const l = try self.conn.stream.write("server: welcome to the chat server\n");

        while (true) {
            var buf: [100]u8 = undefined;
            const amt = try self.conn.stream.read(&buf);
            if (amt == 0)
                break; // We're done, end of connection
            const msg = buf[0..amt];
            try room.broadcast(msg, self);
        }
    }
};

const Room = struct {
    clients: std.AutoHashMap(*Client, void),    

    fn broadcast(room: *Room, msg: []const u8, sender: *Client) !void {
        var it = room.clients.iterator();
        while (it.next()) |entry| {
            const client = entry.key_ptr.*;
            if (client == sender) continue;
            const l = try client.conn.stream.write(msg);
        }
    }
};
