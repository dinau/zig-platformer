TARGET = platformer_$(notdir $(CURDIR))

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

ZIG_VER = $(shell zig version)

all:
	@echo
	@echo === $(TARGET) ===  zig-$(ZIG_VER)
	zig build --release=fast

run: all
	(cd zig-out/bin; ./$(TARGET)$(EXE))

.PHONY: fmt

fmt:
	zig fmt src/main.zig

clean:
	@-rm -rf .zig-cache zig.cache
	@-rm -rf zig-out
