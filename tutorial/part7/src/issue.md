I can successfully generated Windows exe file using your idea and it works well on Windows OS.

> it can't find GLFW/glfw3.h (however everything works fine when I compile from Linux to Linux).

This error can silent by changing `cimgui.nim` line 56,

from 

```nim
{.passC:"-I" & joinPath(staticExec("nimble path nimgl").strip,"nimgl","private","glfw","include").}
```

to 

```nim
{.passC:"-I" & joinPath(staticExec("nimble path nimgl").strip,"nimgl","private","glfw","include").replace("\\", "/").}
```

I've executed this command,

```sh
nim c -d:release -d:strip -d:mingw --passL:-lstdc++ glfw_opengl3.nim 
```
