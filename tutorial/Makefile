ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

TARGET = platformer_part

PART = 8


# Specify C compiler
#OPT += --cc gcc           # clang or tcc

OPT += -r                 # Release compilation: faster speed, no runtime checking
# Set cache folder
NELUA_CACHE = .neluacache
OPT += --cache-dir $(NELUA_CACHE)

# Optimize level is -O2, strip debug symbols("-Wl,-s")
CFLAGS += --cflags="-O2 -Wl,-s"
#LDFLAGS += --ldflags="-L. -lSDL2 -lSDL2_image"
OPT += $(CFLAGS)
OPT += $(LDFLAGS)
#OPT += --no-cache
#OPT += --verbose

all:
	$(call def_make,$(PART))

PHONY: run clean build r

run: all
	./$(TARGET)$(PART)$(EXE)
r: run

clean:
	@-rm -f *$(EXE)
	@-rm -fr $(NELUA_CACHE)

%.o:%.c
	$(CC) -c -O2 -o $@ $<

build: 1 2 3 4 5 6 7 8

PHONY: 1 2 3 4 5 6 7 8 9
PHONY: 1r 2r 3r 4r 5r 6r 7r 8r 9r

1:
	$(call def_make,$@)
1r: 1
	./$(TARGET)$(<)$(EXE)
2:
	$(call def_make,$@)
2r: 2
	./$(TARGET)$(<)$(EXE)
3:
	$(call def_make,$@)
3r: 3
	./$(TARGET)$(<)$(EXE)
4:
	$(call def_make,$@)
4r: 4
	./$(TARGET)$(<)$(EXE)
5:
	$(call def_make,$@)
5r: 5
	./$(TARGET)$(<)$(EXE)
6:
	$(call def_make,$@)
6r: 6
	./$(TARGET)$(<)$(EXE)
7:
	$(call def_make,$@)
7r: 7
	./$(TARGET)$(<)$(EXE)
8:
	$(call def_make,$@)
8r: 8
	./$(TARGET)$(<)$(EXE)
9:
	$(call def_make,$@)
9r: 9
	./$(TARGET)$(<)$(EXE)

define def_make
	@echo === Part$(1) ===
	zig $(OPT) -o $(TARGET)$(1) $(TARGET)$(1).nelua

endef
