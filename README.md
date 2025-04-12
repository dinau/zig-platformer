<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Zig-Platformer](#zig-platformer)
- [Prerequisites](#prerequisites)
  - [Zig version](#zig-version)
  - [Support OS](#support-os)
  - [Build and run](#build-and-run)
  - [Key operation](#key-operation)
  - [Tutorial sources](#tutorial-sources)
  - [SDL librarys](#sdl-librarys)
  - [Other SDL game tutorial platfromer project](#other-sdl-game-tutorial-platfromer-project)
  - [Other project](#other-project)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

### Zig-Platformer

---

![alt](https://github.com/dinau/zig-platformer/actions/workflows/windows.yml/badge.svg)  ![alt](https://github.com/dinau/zig-platformer/actions/workflows/rel.yml/badge.svg)  
![alt](https://github.com/dinau/zig-platformer/actions/workflows/linux.yml/badge.svg)
![alt](https://github.com/dinau/zig-platformer/actions/workflows/rel_linux.yml/badge.svg)

Tutorial: Writing a 2D Platform Game in [Zig language](https://ziglang.org) with SDL2 / SDL3 / SDL_ttf.

This repository has been inherited from
[Nim-Platformer](https://github.com/def-/nim-platformer), [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer) and [Nelua-Platformer](https://github.com/dinau/nelua-platformer)  project.
   - Document  
   English:  https://hookrace.net/blog/writing-a-2d-platform-game-in-nim-with-sdl2/  
   Japanese: https://postd.cc/writing-a-2d-platform-game-in-nim-with-sdl2/  

Skin database [https://ddnet.org/skins](https://ddnet.org/skins)

![alt](img/zig-platformer-sdl3.gif)

### Prerequisites

#### Zig version

---

- [x] Windows:  [zig-0.14.0.zip](https://ziglang.org/builds/zig-windows-x86_64-0.14.0.zip) (2025/03)  
- [x] Linux Debian families: [zig-0.14.0.tar.xz](https://ziglang.org/builds/zig-linux-x86_64-0.14.0.tar.xz)

#### Support OS

---

|      | Windows | Linux | MacOS |
| ---  | :---:   | :---: | :---: |
| SDL2 | v       | v     | v     |
| SDL3 | v       | -     | -     |

- Windows10 or later  
   - MSys2/MinGW basic commands (make, rm, cp, strip ...)
- Linux: Debian families

  ```sh
  $ sudo apt install xorg-dev libopengl-dev libgl1-mesa-dev
  $ sudo apt install libsdl2-dev libsdl2-ttf-dev
  ```
- MacOS: [P.R.](https://github.com/dinau/zig-platformer/pull/1)

#### Build and run 

---

```sh
git clone https://github.com/dinau/zig-platformer
cd zig-platformer/tutorial
```
For instance,

```sh
cd sdl2/part3
make run       
```
or 

```sh
cd sdl2/part3
zig build --release=fast
cd zig-out/bin 
platformer_part3.exe
```

You can build [SDL3](tutorial/sdl3) tutorials same as SDL2.

#### Key operation

---

| Key            | Function  |
| :---:          | :---      |
| Up,Space, J, K | Jump      |
| Left, A, H     | Left      |
| Right, D, L    | Right     |
| R              | Restart   |
| Q              | Quit, Esc |

#### Tutorial sources  

---

[sdl2p1]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part1
[sdl2p2]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part2
[sdl2p3]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part3
[sdl2p4]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part4
[sdl2p5]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part5
[sdl2p6]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part6
[sdl2p7]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part7
[sdl2p8]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part8
[sdl2p9]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl2/part9

[sdl3p1]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part1
[sdl3p2]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part2
[sdl3p3]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part3
[sdl3p4]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part4
[sdl3p5]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part5
[sdl3p6]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part6
[sdl3p7]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part7
[sdl3p8]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part8
[sdl3p9]:https://github.com/dinau/zig-platformer/blob/main/tutorial/sdl3/part9

|      | Part1           | Part2           | Part3<br> (Showing item) | Part4           | Part5 <br>(Moving item) | Part6           | Part7           | Part8<br>(Almost completed) | Part9 |
|------|-----------------|-----------------|--------------------------|-----------------|-------------------------|-----------------|-----------------|-----------------------------|-------|
| SDL2 | [part1][sdl2p1] | [part2][sdl2p2] | [part3][sdl2p3]          | [part4][sdl2p4] | [part5][sdl2p5]         | [part6][sdl2p6] | [part7][sdl2p7] | [part8][sdl2p8]             | -     |
| SDL3 | [part1][sdl3p1] | [part2][sdl3p2] | [part3][sdl3p3]          | [part4][sdl3p4] | [part5][sdl3p5]         | [part6][sdl3p6] | [part7][sdl3p7] | [part8][sdl3p8]             | -     |

#### SDL librarys

---

https://github.com/libsdl-org/SDL/releases

#### Other SDL game tutorial platfromer project

---

![ald](https://github.com/dinau/luajit-platformer/raw/main/img/platformer-luajit-sdl2.gif)

| Language             |          | Project                                                                                                   |
| -------------------: | :---:    | :----------------------------------------------------------------:                                        |
| **Nim**              | Compiler | [Nim-Platformer](https://github.com/dinau/nim-platformer) / [sdl3_nim](https://github.com/dinau/sdl3_nim) |
| **LuaJIT**           | Script   | [LuaJIT-Platformer](https://github.com/dinau/luajit-platformer)                                           |
| **Nelua**            | Compiler | [NeLua-Platformer](https://github.com/dinau/nelua-platformer)                                             |
| **Zig**              | Compiler | [Zig-Platformer](https://github.com/dinau/zig-platformer)                                                 |
| **C3**               | Compiler | [C3-Platformer](https://github.com/dinau/c3-platformer) WIP                                               |
| **Ruby**             | Script   | [Ruby-Platformer](https://github.com/dinau/ruby-platformer) WIP                                               |

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
| **Ruby**             | Script   | [IgRuby-Examples](https://github.com/dinau/igruby_examples)
