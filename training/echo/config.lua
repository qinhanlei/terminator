
-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
-- the project path
local proj_name = 'echo'
local proj_path = './training/'..proj_name..'/'
local common_lib = './training/common/'

-- need export, not a local variable anymore
echo_server = "0.0.0.0:7000"

-- --------------------  Boostrap --------------------
thread = 2
bootstrap = "snlua bootstrap"	-- The service for bootstrap
start = "main"	-- main script


-- --------------------  Connection --------------------
harbor = 0


-- --------------------  Logger --------------------
logger = nil -- output log to console.


-- -------------------- Path --------------------
cpath = root.."cservice/?.so"
lua_cpath = root.."luaclib/?.so;"..proj_path.."?.so"

lualoader = root.."lualib/loader.lua"
luaservice = root.."service/?.lua;"..common_lib.."?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/?.lua;"..common_lib.."?.lua;"..proj_path..'?.lua'

-- run preload.lua before every lua service run
--preload = "./examples/preload.lua"


-- -------------------- Snax --------------------
-- snax = root.."service/?.lua;"..proj_path.."?.lua"
--snax_interface_g = "snax_g"


-- -------------------- Others --------------------
-- backgroud mode, need config 'logger'
--daemon = "./skynet.pid"
