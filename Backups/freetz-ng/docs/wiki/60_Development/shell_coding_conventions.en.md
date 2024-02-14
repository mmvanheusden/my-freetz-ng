# Shell Language

The shell language for any shell scripts is the bourne shell language.
An adequate technical manual to the (posix) shell seems to be
[http://www.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html](http://www.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html).

### Basic Format

The basic format is that all lines are indented by TABs (4 spaces!), and
continuation lines (which in the shell end with "\\") are indented by
an equivalent number of TABs and then an additional two spaces, e.g.

```
    cp foo bar
    cp some_realllllllllllllllly_realllllllllllllly_long_path \
      to_another_really_long_path_with_er-ror
```

### If, For, and While

The sh token equivalent to the C "{" should appear on the same line,
separated by a ";", as in:

```
    if [ "$x" = hello ]; then
        echo $x
    fi

    for i in 1 2 3; do
        echo $i
    done

    i=0
    while [ $i -le 20 ]; do
        echo $i
        i=$(($i + 1))
    done
```

### Test Built-in

DO NOT use the test built-in. Instead, use the \[ builtin.

So, instead of

```
    if test $1 -gt 0; then
```

use:

```
    if [ "$1" -gt 0 ]; then
```

### Single-line conditional statements

It is permissible to use `&&` and `||` to construct shorthand for an
"if" statement in the case where the if statement has a single
consequent line:

```
    [ "$1" -eq 0 ] && exit 0
```

instead of the longer:

```
    if [ $1 -eq 0 ]; then
        exit 0
    fi
```

DO NOT combine `&&` with `{ }`, as in:

```
    [ "$1" -eq 0 ] && {
        do something
        do something else
    }
```

Use a complete "if-then-fi" construct for this instead.

Remark by kriegaex (2012-01-21): Nobody ever asked me for my opinion,
yet I get bugged by one or two people whenever I do this:

```
    [ $foo -eq 0 ] \
        && echo "tea"
        || echo "coffee"

    [ $foo -eq 0 ] && [ "$bar" != "oops" ] \
        && command1 | grep "xxx" \
        || command2
```

I will continue to use this as a shorthand for if-else as long as there
are no nested `&&` or `||` constructs or brackets involved. Whenever I
use it, I indent it cleanly and use it exactly analogous to if-else, so
it is always `condition && true-case || false-case`, never anything more
complicated. I am even putting `&&` or `||` to the beginning of the
indented lines on purpose so as to document the condition for executing
the statements.

I also think that this

```
    while condition; do
        command1 &&
        command2 &&
        command3 &&
        command4 &&
        echo "result"
    done
```

should be permitted because it is more readable than (and still trivial
enough)

```
    while condition; do
        command1 || continue
        command2 || continue
        command3 || continue
        command4 || continue
        echo "result"
    done
```

There is a reason why `&&` and `||` were invented, and I believe that
this case does not look obfuscated in any way.

### Infinite Loops

*This should be discussed:* The original solaris sh style guide says not
to use "true", as this is normally not a shell builtin, and instead
use :, which also evaluates to true. In the busybox sh used with freetz,
"true" is also a shell builtin, and as it is more readable, it should
be prefered over ":":

```
    while true; do
        echo infinite loop
    done
```

### Exit Status and If/While Statements

Recall that "if" and "while" operate on the exit status of the
statement to be executed. In the shell, zero (0) means true and non-zero
means false. The exit status of the last command which was executed is
available in the \$? variable. When using "if" and "while", it is
typically not necessary to use \$? explicitly, as in:

```
    grep foo /etc/passwd >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo found
    fi
```

Instead, you can more concisely write:

```
    if grep foo /etc/passwd >/dev/null 2>&1; then
        echo found
    fi
```

Or, when appropriate:

```
    grep foo /etc/passwd >/dev/null 2>&1 && echo found
```

### Variable References

Variable references begin with \$ and \*may\* have their name enclosed
in {}'s. They should only be used when required.

Braces are required around variable names in two specific cases:

\(1) when you are forming the string concatenation of your variable with
another string:

```
    [ "$install" = yes ] && root="/a/" || root="/"
    hosts=${root}etc/inet/hosts
```

and (2) when you are using one of the various substitution/assignment
operators:

```
    echo ${BASEDIR:-/a}
```

### Variable Naming

Shell variables should usually be all lower case, except for a few
exceptions, where CAPTITAL letters are to be used:

\(1) variables that are exported into the environment:

```
    BASEDIR=/a; export BASEDIR
```

\(2) variables that are used like constants

```
    TMP=/var/tmp
    FLASH=$TMP/flash
```

This helps your reader immediately understand the implication of
modifying a given variable (i.e. whether it will be inherited by child
processes).

### Quoting

Quick review of the quoting basics:

```
single quotes ('') mean quote but do not expand variable or backquote substitutions.
Double quotes ("") mean quote but allow expansion.
Backquotes () mean execute the command and substitute its standard output
(note: stderr is unchanged and may "leak" through unless properly redirected)''
```

Use quotes wherever they *could* be necessary, even when knowing that
for example a variable does only expand to one word at the moment. This
can save us from possible side effects of later code changes.

But please do not unnecessarily quote everything. Literals should
usually not be quoted:

```
    [ -r /path/to/some/file ] && rm /path/to/some/file
```

The usage of backquotes (\`\`) is discouraged in favor of the "new"
form \$().

### Variable Assignments

Variable assignments should not be quoted if unnecessary:

```
    variable=yes
    variable=$(ls)
    variable="some text"
```

### Testing for (Non-)Empty Strings

DO NOT test for non-/empty strings by comparing to "" or *. ALWAYS use
the test operators -n (non-zero-length string) and -z (zero-length
string):*

```
    if [ -z "$foo" ]; then
        echo 'you forgot to set $foo'
    fi

    if [ -n "$BASEDIR" ]; then
        echo "\$BASEDIR is set to $BASEDIR"
    fi
```

### Commenting

As usual, comments are mainly intended for maintainers of the files, that
means probably not you but someone else. Comments should describe why
something is done the way it is done, or explain complicated statements
that are not obvious. A summary for a whole block of code or the
synopsis of a function are also useful. Comments should **not** explain
what a simple line of code does, as it should be assumed that the reader
is familiar with the language.

Shell comments are preceded by the '\#' character. Both single and
multi-line comments are to be placed at line begin. Use an extra '\#'
above and below the comment in the case of multi-line comments:

```
    # Copy foo to bar (this is an example of a useless comment, the purpose of cp should be known).
    cp foo bar

    #
    # Modify the permissions on bar. (This is obvious from the code and not necessary.)
    # We need to set them to root/sys in order to match the package prototype.
    # (This information is useful because it is not contained in the code.)
    #
    chown root bar
    chgrp sys bar
```

### Pathnames

It is always a good idea to be careful about \$PATH settings and
pathnames when writing shell scripts. This allows them to function
correctly even when the user invoking your script has some strange
\$PATH set in their environment.

There are two acceptable ways to do this:

\(1) make *all* command references in your script use explicit pathnames:

```
    /usr/bin/chown root bar
    /usr/bin/chgrp sys bar
```

or (2) explicitly reset \$PATH in your script:

```
    PATH=/usr/bin; export PATH

    chown root bar
    chgrp sys bar
```

DO NOT use a mixture of (1) and (2) in the same script. Pick one method
and use it consistently.

### Interpreter Magic

The proper interpreter magic (aka shebang) for shell script is:

```
    #!/bin/sh
```


