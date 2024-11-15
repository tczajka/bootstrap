---
layout: home
title: Bootstrapping a compiler
---
This is a tutorial about building a compiler for a high level programming language.
Not in another programming language. Not even in assembly. We are going to
build it from scratch!

Before we get there, it will take lots of little steps. And we will learn a lot
in the process.

Where do we start? We assume we have a Linux terminal running `bash`:

```console
$ echo 'hello'
hello
```


We will use basic Linux command line utilities such as `echo` and `cat` and a text editor
such as `VI` or `emacs` or `gedit`.

Our ultimate goal is to build a programming language compiler, and then build a console
Tetris clone in our language.

All the code is available in the [github repository](https://github.com/tczajka/bootstrap).
The [`Makefile`](https://github.com/tczajka/bootstrap/blob/main/Makefile) has all the steps.
So if you want to see a program in action rather than repeat the whole process yourself,
you can build any step in the tutorial using `make`:

```console
$ make hello.1.0.0.e
[...]
$ ./hello.1.0.0.e
$ echo $?
17
```

Test

```c++
int main() {}
```
