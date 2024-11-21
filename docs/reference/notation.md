# Notation

We write sequences of bytes as follows:

notation | base | bytes | notes
------ | ---: | ----: | 
xxx    | 10   |  any  | Decimal numbers of unspecified byte length.
`%ooo` | 8    |    1  | 8-bit octal number.
`$xxx` | 16   |    1  | 8-bit hexadecimal number.
`#xxx` | 16   |    4  | 32-bit hexadecimal numbers.
`"xxx"` | 256  | length | A sequence of [ASCII](ascii.md) bytes.

For example: `$41` = `%101` = `"A"` = one 65 byte.
