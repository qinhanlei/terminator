echo server and client.

## [Socket](https://github.com/cloudwu/skynet/wiki/Socket)
- more method see `skynet/test/testsocket.lua` and `testudp.lua`
- read `skynet/lualib/socket.lua` see how socketAPI works.
- how to handle massive connection see: `skynet/lualib/gate.lua`
    + also have C low level version `skynet/service-src/service_gate.c`

## [SocketChannel](https://github.com/cloudwu/skynet/wiki/SocketChannel)
- usage detail see `skynet/lualib/socketchannle.lua`
- `skynet/lualib/redis.lua` and `skynet/lualib/mongo.lua` also recommended.


## Run
#### Mac OS X
1. run two shells `$ skynet/skynet training/echo/config.lua`
2. one shell type `server` in console
3. other type `client xxx`
4. see what happened.
