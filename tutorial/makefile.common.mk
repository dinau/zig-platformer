TARGET = $(notdir $(CURDIR))

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

ZIG_VER = $(shell zig version)

OPT += --release=fast

all:
	@echo
	@echo === $(TARGET) ===  zig-$(ZIG_VER)
	zig build $(OPT)
	@#-strip zig-out/bin/$(TARGET)$(EXE)

run: all
	(cd zig-out/bin; ./$(TARGET)$(EXE))

.PHONY: fmt clean run

fmt:
	zig fmt .

clean:
	@echo Clean: $(CURDIR)
	@-rm -rf .zig-cache zig-cache
	@-rm -rf zig-out
