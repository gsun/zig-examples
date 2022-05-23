# zig-examples
zig 8.0 examples 


tcpserver.zig
example from Andy Kelly's talk in https://events.redislabs.com/sessions/modeling-data-concurrency-asynchronous-o-zig/.
revised and tested with zig 8.0.

compiling:
zig build

cross compiling for Linux:
zig build -Dtarget=x86_64-linux

terminal 1:
./tcpserver
warning: listening at 127.0.0.1:65356

terminal 2:
nc 127.0.0.1 65356


go implementation:
https://github.com/mactsouk/opensource.com/blob/master/concTCP.go
