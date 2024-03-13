# Zig threads in Emscripten

A toy example showing Zig threads working in the browser with Emscripten.

Currently requires the standard library patch [#19287](https://github.com/ziglang/zig/pull/19287). Also, there are issues with allocators in Emscripten release builds when not using
the `emcc` flag `-s USE_OFFSET_CONVERTER`, see [here](https://ziggit.dev/t/state-of-concurrency-support-on-wasm32-freestanding/1465/9?u=permutationlock).

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
