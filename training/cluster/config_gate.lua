
-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
-- the project path
local proj_name = 'cluster'
local proj_path = './training/'..proj_name..'/'
local common_lib = './training/common/'

-- --------------------  Boostrap --------------------
thread = 4
bootstrap = "snlua bootstrap"	-- The service for bootstrap
start = "main"	-- main script
nodename = "gate_svr"


-- --------------------  Connection --------------------
harbor = 0
cluster = proj_path.."clustername.lua"


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

debug_console_port = 9002
