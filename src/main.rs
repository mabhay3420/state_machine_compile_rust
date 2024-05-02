use state_machine_compiler_rust::{
    lexer::Lexer,
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
    let input_file_path = &args[1];
    // Open the file and read its contents
    let mut file = File::open(input_file_path).unwrap();
    let mut source = String::new();
    file.read_to_string(&mut source).unwrap();

    println!("\n============\n");
    let lexer = Lexer::new(&source);
    println!("Lexed the input file");

    println!("\n============\n");
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsed the input file");

    println!("\n============\n");
    println!("{:?}", parser.tree);

    // Save the dot file
    println!("\n============\n");
    let dot = parser.tree.to_dot();
    let dot_file_path = "state_machine.dot";
    let mut file = File::create(dot_file_path).unwrap();
    // file.write_all(dot.as_bytes()).unwrap();
    file.write_all(dot.as_bytes()).unwrap();
    println!("Written the dot file to {}", dot_file_path);

    println!("\n============\n");
    let code = parser.tree.to_rust_code();
    // println!("{}", code);
    let file_path = "src/bin/state_machine.rs";
    let mut file = File::create(file_path).unwrap();
    file.write_all(code.as_bytes()).unwrap();

    println!("\n============\n");
    println!("Written the Rust code to {}", file_path);
    println!("\n============\n")
}
