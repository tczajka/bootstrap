# Brooklyn

Follow the full story on the [project page](https://tczajka.github.io/brooklyn).

## The goal

We are going to build a compiled programming language
starting from nothing but a Linux terminal.
We are not going to use existing compilers, not even an assembler!

Before we get there, we will have to take us a lot of little steps. And we will learn a lot
in the process.

Where do we start? We assume we have a computer with a Linux operating system,
an [x86-64](https://en.wikipedia.org/wiki/X86-64) CPU and a command line terminal.
We will use some basic Linux commands such as `echo` and `cat` and a plain text
editor such as `vi`, `emacs` or `gedit`.

We *could* make do without even these tools and build our own operating system and a text
editor from scratch on a raw machine. That would be much harder for the readers to reproduce.
Maybe some day.

## The plan

We will build our tools in phases:

* **Octal**. An octal byte parser build in machine code.
* **Bytes**. A slightly more sophisticated binary file language.
* **Stack-SL**. A stack-based programming language with single-letter commands.
* **Stack**. A more sophisticated stack-based programming language inspired by Forth.
* **Assembly**. An assembly language for x86-64.
* **Brooklyn**. A compiled programming language inspired by C.

As we build our tools, we will bootstrap and make our lives easier. Eventually we
want to be able to run the Brooklyn compiler in Brooklyn.

## The code

All the code is available in the [`src`](https://github.com/tczajka/brooklyn/tree/main/src) directory
of the [github](https://github.com/tczajka/brooklyn) repository.
The [`Makefile`](https://github.com/tczajka/brooklyn/blob/main/Makefile) has all the build steps.
So if you want to see a program in action rather than repeat the whole process yourself,
you can build any step in the tutorial using `make`:

```bash
$ make build/hello.1
[...]
$ build/hello.1
Hello, world!
```
