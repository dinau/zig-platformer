ifeq ($(OS),Windows_NT)
	EXE = .exe
PHONY: sdl2 sdl3 sdl2_clean sdl3_clean
else
PHONY: sdl2 sdl2_clean
endif

PART_NUMS_SDL2  = 1 2 3 4 5 6 7 8
PART_NUMS_SDL3  = 1 2 3 4 5 6 7

all: sdl2 sdl3

sdl2:
	@echo --------------------
	@echo    $@ compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL2), $(call def_make_$@,part$(exdir),all))

ifeq ($(OS),Windows_NT)
sdl3:
	@echo
	@echo
	@echo --------------------
	@echo    $@ compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL3), $(call def_make_$@,part$(exdir),all))
endif

sdl2_clean:
	@echo --------------------
	@echo    SDL2 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL2), $(call def_make_sdl2,part$(exdir),clean))

ifeq ($(OS),Windows_NT)
sdl3_clean:
	@echo --------------------
	@echo    SDL3 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS_SDL3), $(call def_make_sdl3,part$(exdir),clean))
endif

define def_make_sdl2
	@$(MAKE) -C tutorial/sdl2/$(1) $(2)

endef

define def_make_sdl3
	@$(MAKE) -C tutorial/sdl3/$(1) $(2)

endef

MAKEFLAGS += --no-print-directory
