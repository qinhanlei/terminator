local snax = require "snax"


local src_code = [[

	local snax
	local handler
	function response.echo(...)
		return handler.name .. " --echo-> " .. ...
	end

	function hotfix(...)
		snax.printf("perform hotfix ...")
	end

]]


snax.hotfix(snax.self(), src_code)
