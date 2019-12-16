PLAT ?= none
PLATS = linux freebsd macosx

CC ?= gcc
CFLAGS = -g -O2 -Wall
SHARED := -fPIC --shared
EXPORT := -Wl,-E

# lua
LUA_STATICLIB := skynet/3rd/lua/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= skynet/3rd/lua
LUA_DIR ?= skynet/3rd/lua

# dynamic-link library
LUA_CLIB_PATH ?= luaclib
CSERVICE_PATH ?= cservice
LUA_CLIB = protobuf
CSERVICE = 


.PHONY : none $(PLATS) clean cleanall update3rd skynet pbc pbc-binding
none :
	@echo "Please do 'make PLATFORM' where PLATFORM is one of these:"
	@echo "   $(PLATS)"

linux : PLAT = linux
macosx : PLAT = macosx
freebsd : PLAT = freebsd

macosx : SHARED := -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup
macosx : EXPORT :=

linux macosx freebsd : | $(CSERVICE_PATH) $(LUA_CLIB_PATH)
	$(MAKE) all PLAT=$@ SHARED="$(SHARED)" EXPORT="$(EXPORT)"

skynet:
	cd skynet && $(MAKE) $(PLAT)

update3rd :
	rm -rf 3rd/pbc && git submodule update --init

pbc:
	cd 3rd/pbc && $(MAKE) lib

all :  \
  $(foreach v, $(CSERVICE), $(CSERVICE_PATH)/$(v).so) \
  $(foreach v, $(LUA_CLIB), $(LUA_CLIB_PATH)/$(v).so) 

clean :
	rm -rf $(LUA_CLIB_PATH) $(CSERVICE_PATH)

cleanall: clean
	cd 3rd/pbc && $(MAKE) clean
	cd 3rd/pbc/binding/lua53 && $(MAKE) clean
	cd skynet && $(MAKE) cleanall


$(CSERVICE_PATH) :
	mkdir $(CSERVICE_PATH)
$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

# generate all service-src/*.so
define CSERVICE_TEMP
$$(CSERVICE_PATH)/$(1).so : service-src/service_$(1).c | $$(CSERVICE_PATH)
	$$(CC) $$(CFLAGS) $$(SHARED) $$< -o $$@ -Iskynet-src
endef
$(foreach v, $(CSERVICE), $(eval $(call CSERVICE_TEMP,$(v))))

$(LUA_CLIB_PATH)/protobuf.so : pbc
	cd 3rd/pbc/binding/lua53; \
		$(MAKE) CFLAGS="$(CFLAGS) $(SHARED)" LUADIR=../../../../../$(LUA_DIR)
	cp -r 3rd/pbc/binding/lua53/protobuf.so* $(@D)/; \
		rm -rf 3rd/pbc/binding/lua53/protobuf.so*
	cp 3rd/pbc/binding/lua/parser.lua ./lualib/tm/pb/
	cp 3rd/pbc/binding/lua53/protobuf.lua ./lualib/tm/pb/
