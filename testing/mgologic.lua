local logic = {}

local mongoc


function logic.init(mgoc)
	mongoc = mgoc
	mongoc.hello()
end


return logic
