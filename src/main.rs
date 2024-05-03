use state_machine_compiler_rust::{
    lexer::Lexer,
    parser::{Parser, ToDot},
};
use std::{
    fs::File,
    io::{Read, Write},
};

use clap::Parser as ClapParser;
use log::{debug, error, info};
// use env_logger::

#[derive(ClapParser, Debug)]
struct Args {
    #[arg(short, long)]
    input_file_path: std::path::PathBuf,

    #[arg(short, long, default_value_t = false)]
    debug: bool,
}

fn main() {
    env_logger::init();

    let args = Args::parse();
    debug!("Command line arguments: {:?}", args);

    let mut file = match File::open(&args.input_file_path) {
        Ok(file) => file,
        Err(e) => {
            error!("Failed to open input file: {}", e);
            std::process::exit(1);
        }
    };
    let mut source = String::new();
    if let Err(e) = file.read_to_string(&mut source) {
        error!("Failed to read input file: {}", e);
        std::process::exit(1);
    }

    info!("Lexing the input file");
    let lexer = Lexer::new(&source);

    info!("Parsing the input file");
    let mut parser = Parser::new(lexer);
    parser.program();

    debug!("Parsed tree: {:?}", parser.tree);

    info!("Generating the dot file");
    let dot = parser.tree.to_dot();
    let dot_file_path = "state_machine.dot";
    if let Err(e) = File::create(dot_file_path).and_then(|mut file| file.write_all(dot.as_bytes()))
    {
        error!("Failed to write the dot file: {}", e);
    } else {
        info!("Written the dot file to {}", dot_file_path);
    }

    info!("Generating the Rust code");
    let code = parser.tree.to_rust_code();
    let file_path = "src/bin/state_machine.rs";
    if let Err(e) = File::create(file_path).and_then(|mut file| file.write_all(code.as_bytes())) {
        error!("Failed to write the Rust code: {}", e);
    } else {
        info!("Written the Rust code to {}", file_path);
    }
}
