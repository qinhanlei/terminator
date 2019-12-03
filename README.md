# Terminator
A project based on [skynet](https://github.com/cloudwu/skynet)


## Build
- `git submodule update --init --recursive`
- `make PLAT` 
  - `PLAT` can be `linux`, `macosx`


## Test
- `sh runtest.sh`
- type `testxxx` to run any `testxxx.lua` skynet service
- run `sqls/*.sql`, before you run `testmysql`
