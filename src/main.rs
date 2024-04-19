use state_machine_compiler_rust::{
    lexer::{Lexer, TokenType},
    parser::{Parser, ToDot},
};
use std::{
    fs::File,
    io::{Read, Write},
};

fn main() {
    //     let source = r#"
    // # State machine configuration

    // STATES: [b], o, q, p, f

    // # Input symbols
    // SYMBOLS: 0, 1, e, x

    // TRANSITIONS:
    // b, *, P(e)-R-P(e)-R-P(0)-R-R-P(0)-L-L, o
    // o, 1, R-P(x)-L-L-L, o
    // o, 0, X, q
    // q, 0 | 1, R-R, q
    // q, X, P(1)-L, p
    // p, x, P(X)-R, q
    // p, e, R, f
    // p, X, L-L, p
    // f, *, R-R, f
    // f, X, P(0)-L-L, o
    // "#;

    // Read source from file
    // Get the file path from the command line arguments
    let args: Vec<String> = std::env::args().collect();
    let file_path = &args[1];
    // Open the file and read its contents
    let mut file = File::open(file_path).unwrap();
    let mut source = String::new();
    file.read_to_string(&mut source).unwrap();
    let lexer = Lexer::new(&source);
    let mut parser = Parser::new(lexer);

    parser.program();
    println!("{:?}", parser.tree);

    // Save the dot file
    let dot = parser.tree.to_dot();
    let mut file = File::create("state_machine.dot").unwrap();
    // file.write_all(dot.as_bytes()).unwrap();
    file.write_all(dot.as_bytes()).unwrap();

    let code = parser.tree.to_rust_code();
    // println!("{}", code);
    let mut file = File::create("src/bin/state_machine.rs").unwrap();
    file.write_all(code.as_bytes()).unwrap();
}
