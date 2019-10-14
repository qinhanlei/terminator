local conf = {}


conf.mysql = {
	-- default value
	host = "127.0.0.1",
	port = 3306,
	user = "terminator", -- "root"
	pass = "I am not root",
	connects = 8,

	tgame = { -- database
		host = "127.0.0.1",
		port = 3306,
		user = "terminator", -- "root"
		pass = "I am not root",
		connects = 4,
	},

	tlogs = {
		-- all as default value
	},
}


conf.mongo = {
}


conf.redis = {
	host = "127.0.0.1",
	port = 6379,
	db = 0,
}


return conf
