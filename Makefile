ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

PART_NUMS  = 1 2 3 4 5 6 7

PHONY: clean sdl2 sdl3 sdl2_clean sdl3_clean

all: sdl2 sdl3

sdl2:
	@echo --------------------
	@echo    SDL2 compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl2,part$(exdir),all))

sdl3:
	@echo
	@echo --------------------
	@echo    SDL3 compiling
	@echo --------------------
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl3,part$(exdir),all))

sdl2_clean:
	@echo --------------------
	@echo    SDL2 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl2,part$(exdir),clean))

sdl3_clean:
	@echo --------------------
	@echo    SDL3 cleaning
	@echo --------------------
	$(foreach exdir,$(PART_NUMS), $(call def_make_sdl3,part$(exdir),clean))


define def_make_sdl2
	@$(MAKE) -C tutorial/sdl2/$(1) $(2)

endef

define def_make_sdl3
	@$(MAKE) -C tutorial/sdl3/$(1) $(2)

endef

MAKEFLAGS += --no-print-directory
