 # State Machine Compiler

A compiler for state machines written in Rust.

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

1. Each statement should be in a newline.
2. Each transition is in a newline.
3. `[b]` -> `b` is the initial state.
4. Action `X` means do nothing.
5. Print `X` amounts to erasing the content of the current head.
6. Condition `*` means that the transition will happen irrespective of the current symbol, but it cannot be empty.

## Usage

```bash
cargo run --bin state_machine_compiler_rust -- example.txt
```

Output:

1. `src/bin/state_machine.rs`

   Run the Rust code: `cargo run --bin state_machine`

   Inputs:
   - `num_steps` - The number of steps to run the state machine.
   - `max_len` - The maximum length of the tape.

   Outputs:
   - The tape content and intermediate states and transitions.

2. `state_machine.dot` is the state machine diagram.

## Implementation

1. Parse the input file and generate the state machine.

   The data is stored in a `ParseTree` struct.

   ```rust
   struct ParseTree {
       states: Vec<String>,
       initial_state: String,
       symbols: Vec<String>,
       transitions: Vec<Transition>,
   }
   ```

2. Generate the Rust code for the state machine.

## References

- Inspired from discussion in: ON COMPUTABLE NUMBERS, WITH AN APPLICATION TO THE ENTSCHEIDUNGSPROBLEM By A. M. TURING.
- Rust Book
- Claude
