TARGET = $(notdir $(CURDIR))

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif


all:
	zig build --release=fast

run:
	(cd zig-out/bin; ./$(TARGET)$(EXE))

.PHONY: fmt

fmt:
	zig fmt src/main.zig

clean:
	-rm -rf .zig-cache zig.cache
	-rm -rf zig-out
