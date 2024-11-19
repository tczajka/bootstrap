# Bootstrapping a compiler

We are going to bootstrap a compiler for a high level programming language
without using another programming language. Not even assembly. We are going to
build our tools from scratch!

Before we get there, it will take a lot of little steps. And we will learn a lot
in the process.

Where do we start? We assume we have a computer with a Linux operating system and a terminal
running `bash`. We will use some basic Linux command line utilities such as `echo` and `cat` and a text
editor such as vi, emacs or gedit.

We *could* make do even without these tools and build our own operating system and a text
editor from scratch. But we'll not tie our hands *that* much. Maybe some day.

We will build our tools in phases:
* We have to start somewhere. Our first programs will be built from the command line
  using `echo`.
* **Octal**. This will let us write code as a sequence of numbers in
  octal (base 8) in a text file and get them translated to a binary file.
  Why base 8? It is simple to parse, and x86 machine
  code opcodes are easiest to understand in base 8.
* **Bytes**. This will make our lifes somewhat easier. It will allow us to use
  octal and hexadecimal, comments, and refer to addresses by labels.
* **Stack**. A stack-based programming language inspired by Forth.
* **Brooklyn**. A programming language similar to C or Pascal.
* **Tetris**. The game.

All the code is available in the [`src` directory](https://github.com/tczajka/bootstrap/tree/main/src)
of the [github repository](https://github.com/tczajka/bootstrap).
The [`Makefile`](https://github.com/tczajka/bootstrap/blob/main/Makefile) has all the build steps.
So if you want to see a program in action rather than repeat the whole process yourself,
you can build any step in the tutorial using `make`:

```bash
$ make bin/hello.1
[...]
$ bin/hello.1
Hello, world!
```
