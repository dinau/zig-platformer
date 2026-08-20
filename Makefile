PART_NUMS_SDL2  = 1 2 3 4 5 6 7 8
PART_NUMS_SDL3  = 1 2 3 4 5 6 7 8

ifeq ($(OS),Windows_NT)
all: sdl2 sdl3
else
all: sdl2
endif

fmt: sdl2_fmt sdl3_fmt

sdl2:
	@echo --------------------
	@echo    $@ compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL2), $(call def_make_$@,part$(exdir),all))

sdl2_clean:
	@echo --------------------
	@echo    SDL2 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL2), $(call def_make_sdl2,part$(exdir),clean))

sdl3:
	@echo
	@echo
	@echo --------------------
	@echo    $@ compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL3), $(call def_make_$@,part$(exdir),all))

sdl3_clean:
	@echo --------------------
	@echo    SDL3 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL3), $(call def_make_sdl3,part$(exdir),clean))

sdl3_fmt:
	@echo --------------------
	@echo    fmt for SDL3
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL3), $(call def_make_sdl3,part$(exdir),fmt))

sdl2_fmt:
	@echo --------------------
	@echo    fmt for SDL2
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL2), $(call def_make_sdl2,part$(exdir),fmt))


ifeq ($(OS),Windows_NT)
clean: sdl2_clean sdl3_clean
else
clean: sdl2_clean
endif

define def_make_sdl2
	@$(MAKE) -C tutorial/sdl2/$(1) $(2)
	@$(MAKE) -C tutorial/sdl2/$(1) cleancache

endef

define def_make_sdl3
	@$(MAKE) -C tutorial/sdl3/$(1) $(2)
	@$(MAKE) -C tutorial/sdl3/$(1) cleancache

endef

MAKEFLAGS += --no-print-directory
