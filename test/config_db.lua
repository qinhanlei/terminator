-- print("this is test config_db.")

local conf = {}


conf.mysql = {
	-- default value
	host = "127.0.0.1",
	port = 3306,
	user = "terminator", -- "root"
	pass = "I am not root",
	connects = 8,
	tm_game = { -- database
		host = "127.0.0.1",
		port = 3306,
		user = "terminator", -- "root"
		pass = "I am not root",
		connects = 4,
	},
	tm_logs = {
		-- all as default value
	},
}


conf.mongodb = {
}


conf.redis = {
}


return conf
