# Zig threads in Emscripten

A toy example showing Zig threads working in the browser with Emscripten.
Requires the standard library patch
[#17210](https://github.com/ziglang/zig/pull/17210).

A go webserver is provided to host the Emscripten app with cross-origin
isolation turned on. Threading in Emscripten uses the experimental shared memory
browser features which can only run in pages with cross-origin isolation.

To build and host the application:

```Shell
zig build --sysroot [emsdk]/upstream/emscripten
go run server.go
```

Then go to [http://127.0.0.1:8083](http://127.0.0.1:8083) in a browser to
hopefully see the printout and no console errors.
