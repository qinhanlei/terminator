## Run
#### Mac OS X
1. go root directory xxx/terminator/
2. run in `shell1`
    ```
    $ skynet/skynet training/snax-console/config.lua
    ```

3. type in current shell `my-console` and `debug_console 7343` see what happened.
4. open another `shell2` type `$ telnet 127.0.0.1 7342` will see:
    ```
    ...
    Trying 127.0.0.1...
    Connected to localhost.
    Escape character is '^]'.
    Welcome to skynet console
    ```

5. then type `help`, try something in the help list.
6. go `shell1` type `snax my-snax`.
7. go `shell2` type `list`, may see informations like below:
    ```
    ...
    list
    ... ...
    ... ...
    :0000000d	snlua snaxd my-snax
    OK
    ```

8. in `shell2` type:
    ```
    inject :d training/snax-console/my-snax-call.lua
    ```

9. see what happened in `shell1`
10. in `shell2` type:
    ```
    inject :d training/snax-console/my-snax-hotfix.lua
    inject :d training/snax-console/my-snax-call.lua
    ```

11. see what happened in `shell1` again.
12. type `abort` in `shell1` to exit.
13. more about `clearcache` see [`abort`](https://github.com/qinhanlei/terminator/blob/master/training/common/abort.lua)  
14. try some other commands like 'logon/logoff address' ...
15. change `logger` in config.lua, use `tail -f snax-console.log` trace logging.

###### quit telnet
1. press `ctrl+']'`
2. type `quit`
