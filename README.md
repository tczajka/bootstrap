# Bootstrapping a compiler

Follow the full story on the [project page](https://tczajka.github.io/bootstrap/).

## The goal

We are going to bootstrap a compiler for a high level programming language
without using another programming language. Not even assembly. We are going to
build our tools from scratch!

Before we get there, it will take us a lot of little steps. And we will learn a lot
in the process.

Where do we start? We assume we have a computer with a Linux operating system with a command line terminal.
We will use some basic Linux commands such as `echo` and `cat` and a plain text
editor such as `vi`, `emacs` or `gedit`.

We *could* make do without even these tools and build our own operating system and a text
editor from scratch. Maybe some day.

## The plan

We will build our tools in phases:

* Our first programs will be built from the command line using `echo`.
* **Assembler**. We will progressively develop a simple assembler.
* **Forth**. A simple stack-based interpreted programming language.
* **Brooklyn**. A higher level compiled programming language we will make up on the fly,
  similar to C or Pascal.
* **Tetris**. The game.

As we develop our programming languages, we will *bootstrap* the compilers to use their own language!
So the assembler will be written in assembly, Forth will be written in Forth, and Brooklyn will be written
in Brooklyn.

## The code

All the code is available in the [`src`](https://github.com/tczajka/bootstrap/tree/main/src) directory
of the [github](https://github.com/tczajka/bootstrap) repository.
The [`Makefile`](https://github.com/tczajka/bootstrap/blob/main/Makefile) has all the build steps.
So if you want to see a program in action rather than repeat the whole process yourself,
you can build any step in the tutorial using `make`:

```bash
$ make bin/hello.1
[...]
$ bin/hello.1
Hello, world!
```
