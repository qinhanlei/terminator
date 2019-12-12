local conf = {}


-- multiple database on single or multiple mysql instances.
conf.mysql = {
    -- default values
    host = "127.0.0.1",
    port = 3306,
    user = "terminator",
    password = "I am not root",
    database = "tconf",
    connects = 4,
    max_packet_size = 2 * 1024 * 1024, -- default is 1MB
    -- another database info table
    {
        database = "tgame",
        connects = 8,
        -- others as default values
    },
    -- yet another database info table
    {
        database = "tlogs" -- prior identify
        -- others as default values
    },
    -- { database = "tlogs" } -- duplicated will cause assert fail!
}


-- multiple databases on single mongodb instance
conf.mongo = {
    host = "127.0.0.1",
    port = 27017,
    username = "test",
    password = "test",
    authdb = "admin",
    connects = 4,
}


-- single db on single redis instance
conf.redis = {
    host = "127.0.0.1",
    port = 6379,
    auth = "",
    connects = 4,
}


return conf
