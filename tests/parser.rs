use state_machine_compiler_rust::lexer::Lexer;
use state_machine_compiler_rust::parser::Parser;

#[test]
fn test_basic_parser() {
    let code = "
        STATES: [A], B, C, D
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, X-L-L-P(X)-L, B
        B, * , L , C1
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
fn test_basic_parser_2() {
    let code = "
        STATES: A, [B], C, D
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, R-L-L-P(X)-L, B
        B, * , L , C1";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
fn test_basic_parser_3() {
    let code = "
        STATES: A, B, C, [D]
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, R-L-L-P(X)-L, B
        B, * , L , C1";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Initial state already defined.")]
fn test_double_initial_condition() {
    let code = "
        STATES: A, [B], C, [D]
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, R-L-L-P(X)-L, B
        B, * , L , C1";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Initial state not defined")]
fn test_initial_condition_not_provided() {
    let code = "
        STATES: A, B, C, D
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, R-L-L-P(X)-L, B
        B, * , L , C1
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Expected R or L or P or X as an action step, got IDENT: \"A\"")]
fn test_invalid_action() {
    let code = "
        STATES: A, [B], C, D
        SYMBOLS: 0, 1, B
        TRANSITIONS:
        A, 0 | 1, X-A-L-P(X)-L, B
        B, * , L , C1
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: State A already defined.")]
fn test_duplicate_state_identifiers() {
    let code = "
    STATES: A, [B], A, C

    SYMBOLS: 0, 1, B

    TRANSITIONS:
    B, 0 | 1, R-L-L-P(X)-L, C
    C, * , L , A
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Symbol 0 already defined.")]
fn test_duplicate_symbol_identifiers() {
    let code = "
    STATES: [A], B, C

    SYMBOLS: 0, 1, 0

    TRANSITIONS:
    A, 0 | 1, R-L-L-P(X)-L, B
    B, * , L , C
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Expected IDENT, got COMMA")]
fn test_invalid_transition_condition() {
    let code = "
    STATES: [A], B, C

    SYMBOLS: 0, 1

    TRANSITIONS:
    A, 0 | , R-L-L-P(X)-L, B
    B, * , L , C
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}

#[test]
#[should_panic(expected = "Parsing error: Symbol Y not defined, So cannot be printed.")]
fn test_invalid_print_symbol() {
    let code = "
    STATES: [A], B, C

    SYMBOLS: 0, 1

    TRANSITIONS:
    A, 0 | 1, R-L-L-P(Y)-L, B
    B, * , L , C
    ";

    let lexer = Lexer::new(code);
    let mut parser = Parser::new(lexer);
    parser.program();
    println!("Parsing Completed");
}