# ASCII

Each ASCII character corresponds to a byte in the range 0-`#7F` (0-127).
Rows correspond to the first hex digit, colums to the second hex digit.

|       | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F
| -     | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | -
| **0** |   |   |   |   |   |   |   |   |   |HT |LF |VT |FF |CR |   |
| **1** |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
| **2** |SP | ! | " | # | $ | % | & | ' | ( | ) | * | + | , | - | . | /
| **3** | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | : | ; | < | = | > | ?
| **4** | @ | A | B | C | D | E | F | G | H | I | J | K | L | M | N | O
| **5** | P | Q | R | S | T | U | V | W | X | Y | Z | [ | \ | ] | ^ | _
| **6** | ` | a | b | c | d | e | f | g | h | i | j | k | l | m | n | o
| **7** | p | q | r | s | t | u | v | w | x | y | z | { |\| | } | ~ |

Whitespace characters:

* **SP**: space
* **LF**: end of line ("line feed")
* **HT**: tab ("horizontal tab")
* **CR**: alternate end of line ("carriage return").
  Windows editors commonly end lines with two characters: CR LF.
* **VT**: vertical tab, rarely used
* **FF**: end of page ("form feed"), rarely used

In our files we only use SP and LF for whitespace.

Irrelevant special characters are ommitted from the table.
