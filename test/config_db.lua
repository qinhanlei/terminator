print("this is test config_db.")

local conf = {}

-- default value
conf.common = {
    user = "terminator", -- "root"
    pass = "I'm not root.",
    connect_num = 8,
}

conf.mysql = {
    gamedb = {
        addr = "127.0.0.1",
        port = 3306,
        -- user = conf.common.user, -- this is default
        -- pass = conf.common.pass,
        -- connect_num = conf.common.connect_num,
    },
    logdb = {
        addr = "127.0.0.1",
        port = 3306,
    },
}

conf.mongodb = {
}

conf.redis = {
    
}


return conf