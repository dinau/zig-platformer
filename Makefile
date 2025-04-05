ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

PART_NUMS  = 1 2 3 4 5 6 7

all:
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl2,part$(exdir),$@))
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl3,part$(exdir),$@))

PHONY: clean

clean:
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl2,part$(exdir),$@))
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl3,part$(exdir),$@))


define def_make_sdl2
	@$(MAKE) -C tutorial/sdl2/$(1) $(2)

endef

define def_make_sdl3
	@$(MAKE) -C tutorial/sdl3/$(1) $(2)

endef

MAKEFLAGS += --no-print-directory
