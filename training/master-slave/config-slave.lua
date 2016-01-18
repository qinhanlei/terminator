
-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
-- the project path
local proj_name = 'master-slave'
local proj_path = './training/'..proj_name..'/'


-- --------------------  Boostrap --------------------
thread = 2
bootstrap = "snlua bootstrap"
start = "slave" -- boost slave.lua by booststrap service.


-- --------------------  Connection --------------------
harbor = $slave_harbor
address = "127.0.0.1:770"..harbor
master = "127.0.0.1:7800"
standalone = nil


-- --------------------  Logger --------------------
logger = nil -- output log to console.


-- -------------------- Path --------------------
cpath = root.."cservice/?.so"
lua_cpath = root.."luaclib/?.so;"..proj_path.."?.so"

lualoader = root.."lualib/loader.lua"
luaservice = root.."service/?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/?.lua;"..proj_path..'?.lua'
