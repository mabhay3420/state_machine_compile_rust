# State Machine Compiler

A compiler for state machines written in Rust.

Read about it on [Blog](https://mabhay3420.github.io/2024-05-07-state-machine-compiler-a-small-language/)

## Syntax Details

Look at the example below:

```
STATES: [b], o, q, p, f

SYMBOLS: 0, 1, e, x

TRANSITIONS:
b, *, P(e)-R-P(e)-R-P(0)-R-R-P(0)-L-L, o
o, 1, R-P(x)-L-L-L, o
o, 0, X, q
q, 0 | 1, R-R, q
q, X, P(1)-L, p
p, x, P(X)-R, q
p, e, R, f
p, X, L-L, p
f, *, R-R, f
f, X, P(0)-L-L, o
```

This state machine when run will generate following output:

```
001011011101111....
```

i.e. `0(1^n)` where `n` is from `0` to `infinity`.

### Rules

1. Each statement should be in a newline.
2. Each transition is in a newline.
3. `[b]` -> `b` is the initial state.
4. Action `X` means do nothing.
5. Print `X` amounts to erasing the content of the current head.
6. Condition `*` means that the transition will happen irrespective of the current symbol, but it cannot be empty.

## Usage

The best way to get started is to use `nix` to install required packages.
Assuming you can run `nix-shell` do this:

``` bash
nix-shell --pure # takes some time in the beginning
cargo run_example
```

Clone the repository and run the following commands:

1. Try with the [example.txt](examples/example.txt) file:

   ```bash
   cargo run --bin state_machine_compiler_rust -- -i example.txt
   ```

2. Alternatively, pass the file path as an argument following the `-i` flag.

3. To enable debug logging, set the `RUST_LOG` environment variable to `debug`.

   ```bash
   RUST_LOG=debug cargo run --bin state_machine_compiler_rust -- -i examples/example.txt
   ```

If you are working with executable, then refer to following doc

```bash
Usage: state_machine_compiler_rust --input-file-path <INPUT_FILE_PATH>

Options:
   -i, --input-file-path <INPUT_FILE_PATH>
   -h, --help Print help
```

## Output

Few files:

1. `src/bin/state_machine.rs`

   To test the the generated Rust code: `cargo run --bin state_machine`

   Inputs:

   - `num_steps` - The number of steps to run the state machine.
   - `max_len` - The maximum length of the tape.

   Outputs:

   - The transitions
   - The full tape content
   - The cleaned tape content ( erasing the `X` symbol which stands for empty tape content)

2. `state_machine.dot` is the state machine diagram.
3. `state_machine.ll` is the LLVM IR code implementing similar functionality

To run the generated IR code, simply take a look at [run_output.sh](./run_output.sh) script.

```bash
./run_output.sh
```

## Implementation

1. Parse the input file and generate the state machine. The data is stored in a `ParseTree` struct.

   ```rust
   struct ParseTree {
      states: Vec<String>,
      initial_state: String,
      symbols: Vec<String>,
      transitions: Vec<Transition>,
   }
   ```

2. Generate the Rust code for the state machine.

## Implementation via Rust Macros

Instead of building a custom language, we can also use Rust macros to generate the code. However, due to some limitations of macros, the approach is a little verbose.

Find the implementation [here](src/bin/state_machine_macro.rs).

You can directly run the macro by running the following command:
   ```bash
   cargo run --bin state_machine_macro
   ```

If you want to see the expanded code, you can run the following command:
   ```bash
   rustc +nightly -Zunpretty=expanded src/bin/state_machine_macro.rs
   ```


## References

- Inspired from discussion in [Alan Turing's 1936 paper](https://www.cs.virginia.edu/~robins/Turing_Paper_1936.pdf).
- [Writing a compiler in python](https://austinhenley.com/blog/teenytinycompiler1.html)
- [Rust Book](https://doc.rust-lang.org/book/ch19-06-macros.html)
- [Claude](https://claude.ai/)


## Editor Setup
1. I am developing the project inside a nix shell environment in VS code editor. The main advantage is i don't need to play around with LLVM installations. Here are the steps:
   a. Install `nix`. Make sure you can run `nix-shell --pure` in your terminal.
   b. Install `Nix Environment Selector` [extension](https://marketplace.visualstudio.com/items?itemName=arrterian.nix-env-selector) in VS code.
   c. In VS Code, On command pallete ( cmd + shift + p ) type `Nix-Env: Select Environment` and select `shell.nix` as the environment.
2. Otherwise, you will need to install LLVM 18 and have it in your path. The errors will point you to the right direction.

 