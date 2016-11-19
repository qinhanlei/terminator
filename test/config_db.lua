print("this is test config_db.")

local conf = {}

-- default value
conf.common = {
    user = "terminator", -- "root"
    pass = "I am not root",
    connects = 8,
}

conf.mysql = {
    tm_test = {
        addr = "127.0.0.1",
        port = 3306,
        -- user = conf.common.user, -- this is default
        -- pass = conf.common.pass,
        -- connects = conf.common.connects,
    },
    tm_game = {
        addr = "127.0.0.1",
        port = 3306,
    },
    tm_logs = {
        addr = "127.0.0.1",
        port = 3306,
    },
}

conf.mongodb = {
}

conf.redis = {
    
}


return conf