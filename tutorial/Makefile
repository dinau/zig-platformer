ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

PART_NUMS  = 1 2 3 4 5 6 7 8

all:
	zig version
	$(foreach exdir,$(PART_NUMS), $(call def_make,part$(exdir),$@))

PHONY: clean

clean:
	$(foreach exdir,$(PART_NUMS), $(call def_make,part$(exdir),$@))


define def_make
	@echo === $(1) ===
	$(MAKE) -C $(1) $(2)

endef
