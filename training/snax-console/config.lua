
-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
-- the project path
local proj_name = 'snax-console'
local proj_path = './training/'..proj_name..'/'
local common_lib = './training/common/'

-- --------------------  Boostrap --------------------
thread = 2
bootstrap = "snlua bootstrap"	-- The service for bootstrap
start = "main"	-- main script


-- --------------------  Connection --------------------
harbor = 0


-- --------------------  Logger --------------------
logpath = './training/logs' -- for debug_console do cmd:'logon address'

logger = nil -- output log to console
--logger = logpath..'/'..proj_name..'.log' -- try this logger destination
logservice = 'logger' -- default is 'logger'


-- -------------------- Path --------------------
cpath = root.."cservice/?.so"
lua_cpath = root.."luaclib/?.so;"..proj_path.."?.so"

lualoader = root.."lualib/loader.lua"
luaservice = root.."service/?.lua;"..common_lib.."?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/?.lua;"..common_lib.."?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/compat10/?.lua;"..lua_path --TODO: remove me

-- run preload.lua before every lua service run
--preload = "./examples/preload.lua"


-- -------------------- Snax --------------------
snax = root.."service/?.lua;"..proj_path.."?.lua"
--snax_interface_g = "snax_g"


-- -------------------- Others --------------------
-- backgroud mode, need config 'logger'
--daemon = "./skynet.pid"
