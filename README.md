<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Zig-Platformer](#zig-platformer)
  - [Support OS](#support-os)
  - [Build and run](#build-and-run)
  - [Key operation](#key-operation)
  - [Tutorial sources](#tutorial-sources)
  - [Other SDL game tutorial platfromer project](#other-sdl-game-tutorial-platfromer-project)
  - [Other project](#other-project)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Zig-Platformer

---

![alt](https://github.com/dinau/zig-platformer/actions/workflows/windows.yml/badge.svg)  ![alt](https://github.com/dinau/zig-platformer/actions/workflows/rel.yml/badge.svg)  
![alt](https://github.com/dinau/zig-platformer/actions/workflows/linux.yml/badge.svg)

Now work in progress.

Tutorial: Writing a 2D Platform Game in [Zig language](https://ziglang.org) with SDL2.

This repository has been inherited from
[Nim-Platformer](https://github.com/def-/nim-platformer), [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer) and [Nelua-Platformer](https://github.com/dinau/nelua-platformer)  project.
   - Document  
   English:  https://hookrace.net/blog/writing-a-2d-platform-game-in-nim-with-sdl2/  
   Japanese: https://postd.cc/writing-a-2d-platform-game-in-nim-with-sdl2/  

Skin database [https://ddnet.org/skins](https://ddnet.org/skins)

### Prerequisites

#### Zig version

---

- [x] Windows:  [zig-0.14.0-dev.3445+6c3cbb0c8.zip](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.3445+6c3cbb0c8.zip) (2025/03/02)  
- [x] Linux Debian: [zig-0.14.0-dev.3445+6c3cbb0c8.tar.xz](https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.3445+6c3cbb0c8.tar.xz)
- [x] zig-0.13.0

#### Support OS

---

- Windows10 or later  
   - MSys2/MinGW basic commands (make, rm, cp, strip ...)
- Linux: Debian families

  ```sh
  $ sudo apt install xorg-dev libopengl-dev libgl1-mesa-dev
  $ sudo apt install libsdl2-dev
  ```

#### Build and run

---

```sh
git clone https://github.com/dinau/zig-platformer
cd zig-platformer
```
For instance,

```sh
cd part3
make run       # or zig build --release=fast run
```

#### Key operation

---

| Key            | Function |
| :---:          | :---     |
| Up,Space, J, K | Jump     |
| Left, A, H     | Left     |
| Right, D, L    | Right    |
| R              | Restart  |
| Q              | Quit     |

#### Tutorial sources  

---

[platformer_part1](https://github.com/dinau/zig-platformer/blob/main/tutorial/part1/src/main.zig)  
[platformer_part2](https://github.com/dinau/zig-platformer/blob/main/tutorial/part2/src/main.zig)  
[platformer_part3](https://github.com/dinau/zig-platformer/blob/main/tutorial/part3/src/main.zig)  
[platformer_part4](https://github.com/dinau/zig-platformer/blob/main/tutorial/part4/src/main.zig)  
[platformer_part5](https://github.com/dinau/zig-platformer/blob/main/tutorial/part5/src/main.zig) : From here it can move the item with key operation.  
[platformer_part6](https://github.com/dinau/zig-platformer/blob/main/tutorial/part6/src/main.zig)  
[platformer_part7](https://github.com/dinau/zig-platformer/blob/main/tutorial/part7/src/main.zig)  
[platformer_part8]

#### Other SDL game tutorial platfromer project

---

![ald](https://github.com/dinau/luajit-platformer/raw/main/img/platformer-luajit-sdl2.gif)

| Language             |          | Project                                                                                                   |
| -------------------: | :---:    | :----------------------------------------------------------------:                                        |
| **Nim**              | Compiler | [Nim-Platformer](https://github.com/dinau/nim-platformer) / [sdl3_nim](https://github.com/dinau/sdl3_nim) |
| **LuaJIT**           | Script   | [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer)                                           |
| **Nelua**            | Compiler | [NeLua-Platformer](https://github.com/dinau/nelua-platformer)                                             |
| **Zig**              | Compiler | [Zig-Platformer](https://github.com/dinau/zig-platformer) WIP                                             |
| **C3**               | Compiler | [C3-Platformer](https://github.com/dinau/c3-platformer) WIP                                               |

#### Other project

---

| Language             |          | Project                                                                                                                                         |
| -------------------: | :---:    | :----------------------------------------------------------------:                                                                              |
| **Nim**              | Compiler | [ImGuin](https://github.com/dinau/imguin), [Nimgl_test](https://github.com/dinau/nimgl_test), [Nim_implot](https://github.com/dinau/nim_implot) |
| **Lua**              | Script   | [LuaJITImGui](https://github.com/dinau/luajitImGui)                                                                                             |
| **Zig**, C lang.     | Compiler | [Dear_Bindings_Build](https://github.com/dinau/dear_bindings_build)                                                                             |
| **Zig**              | Compiler | [ImGuinZ](https://github.com/dinau/imguinz)                                                                                                     |
| **NeLua**            | Compiler | [NeLuaImGui](https://github.com/dinau/neluaImGui)                                                                                               |
| **Python**           | Script   | [DearPyGui for 32bit WindowsOS Binary](https://github.com/dinau/DearPyGui32/tree/win32)                                                         |
