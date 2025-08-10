DIRS = \
      clib \
			sdl3 \
			sdl3_ttf \
			sdl2 \
			stb

clean:
	$(foreach exdir,$(DIRS), $(call def_make,$(exdir),$@))

fmt:
	$(foreach exdir,$(DIRS), $(call def_make,$(exdir),$@))

#
define def_make
	@echo ==== Enter: $(1) ====
	@-$(MAKE) -C  $(1) $(2)

endef

MAKEFLAGS += --no-print-directory
