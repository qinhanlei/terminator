
## Run
#### Mac OS X
1. go root directory xxx/terminator/
2. run `master service` in a shell  
   ```
   $ skynet/skynet training/master-slave/config-master.lua
   ```
3. open another shell run `slave service`
   ```
   $ export slave_harbor=2
   $ skynet/skynet training/master-slave/config-slave.lua
   ```
4. run more `slave service` set different `slave_harbor` see what happened
