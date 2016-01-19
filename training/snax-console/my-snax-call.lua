local snax = require "snax"

snax_service = snax.self()
snax_service.post.log("send --> begin call.")

snax.printf("%s", snax_service.req.echo("hello, console!"))

snax_service.post.log("send --> after call.")
