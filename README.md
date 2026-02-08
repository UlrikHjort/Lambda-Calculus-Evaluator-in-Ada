# Lambda Calculus Evaluator in Ada

A simple **[lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)** interpreter written in Ada that uses "/" as the lambda symbol.

## Features

- **AST Representation**: Variables, lambda abstractions, and applications
- **Beta-Reduction**: Evaluates lambda expressions using substitution
- **Alpha-Conversion**: Automatically renames bound variables to avoid capture
- **Parser**: Parses lambda expressions with `/` as lambda symbol
- **Interactive REPL**: Type expressions and evaluate them interactively
- **File Input**: Pipe files containing lambda expressions

## Syntax

- **Lambda abstraction**: `/x.body` (e.g., `/x.x` for identity function)
- **Application**: `f x` (juxtaposition)
- **Parentheses**: For grouping, e.g., `(/x.x) y`
- **Comments**: Lines starting with `#` are ignored

## Building

```bash
make
```
Or manually:
```bash
gnatmake -D bin src/main.adb -o bin/lambda
```

## Running

### Interactive Mode (Type Directly)

Launch the REPL and type lambda expressions directly:

```bash
make run
# or
bin/lambda
```

Type expressions and press Enter to evaluate each one:

```
Lambda Calculus REPL
Type expressions, press Enter to evaluate
Example: /x.x or (/x.x) y
Press Ctrl+D to exit

> /x.x
/x.x
> (/x.x) y
y
> (/x./y.x) a b
a
> (/n./f./x.f (n f x)) (/f./x.x)
/f./x.f x
```

Exit with Ctrl+D (or Ctrl+Z on Windows).

### File Input Mode (Pipe Files)

You can also pipe files containing multiple lambda expressions:

Run a specific test file:
```bash
bin/lambda < tests/identity.l
```

Or using make:
```bash
make test-file FILE=tests/identity.l
```

### Run All Tests

```bash
make test
```

## Makefile Targets

- `make` or `make all` - Build the project
- `make clean` - Remove all build artifacts
- `make run` - Run the interactive REPL
- `make test` - Run all test files in `tests/`
- `make test-file FILE=<path>` - Run a specific test file
- `make help` - Show help message

## Example Test Files

### tests/identity.l
```
# Identity function test
/x.x
```

### tests/booleans.l
```
# Church booleans
/x./y.x
/x./y.y
(/x./y.x) a b
(/x./y.y) a b
```

### tests/numerals.l
```
# Church numerals
/f./x.x                              # Zero
/f./x.f x                            # One
(/n./f./x.f (n f x)) (/f./x.x)      # Successor of 0
```

## Example Output

```bash
$ make test-file FILE=tests/numerals.l
Testing: tests/numerals.l
/f./x.x
/f./x.f x
/f./x.f (f x)
/f./x.f (f (f x))
/n./f./x.f (n f x)
/f./x.f x
/f./x.f (f x)
```

