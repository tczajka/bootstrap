# Assembler overview

Writing bytes with `echo` is fun, but it is a lot of work. To write our
[Hello, world](../hello-world.md) program we had to do a lot of things manually and
the resulting [code](https://github.com/tczajka/echo-to-tetris/blob/main/src/hello.1.echo) is not
easy to read. Any changes we want to make require a lot of work to make sure everything still
fits in correctly.

Let's create an **assembler**: a tool that will let us write machine code in a nicer format.

What do we want from our assembler? We want to:

* split our code into many lines and use whitespace freely
* put comments in the code
* write 32-bit (dword) numbers, rather than just individual bytes
* addresses and offsets to be calculated automatically
* machine instruction [opcodes](../reference/x86.md) to be calculated automatically

Let's start creating it!
