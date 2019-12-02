local conf = {}

conf.mysql = {
    -- default values
    host = "127.0.0.1",
    port = 3306,
    user = "terminator",
    pass = "I am not root",
    connects = 2,
    database = "tconf",

    -- database info table
    tgame = {
        host = "127.0.0.1",
        port = 3306,
        user = "terminator",
        pass = "I am not root",
        connects = 4
    },

    -- database info table
    {
        database = "tlogs" -- prior identify
        -- all as default value
    }
}


conf.mongo = {
    host = "127.0.0.1",
    port = 27017,
    user = "terminator",
    pass = "I am not mongodb root",

}


conf.redis = {
    host = "127.0.0.1",
    port = 6379,
    db = 0
}


return conf
