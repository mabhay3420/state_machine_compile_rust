use state_machine_compiler_rust::{
    lexer::{Lexer, TokenType},
    parser::{Parser, ToDot},
};
use std::{fs::File, io::Write};

fn main() {
    //     let source = r#"
    //     # Comments
    //     STATES: [A], B
    //     # Comment 2
    //     SYMBOLS: 0, 1, B
    //     TRANSITIONS:
    //     A, 0 | 1, X-L-L-P(X)-L, B
    //     B, * , L , C1
    // "#;
    let source = r#"
    # This is a complex state machine example
    
    STATES: [S0], S1, S2, S3, S4, S5, S6, S7, S8, S9, S10
    
    # Symbol declarations
    SYMBOLS: a, b, c, d, e
    
    TRANSITIONS:
    # Transitions from S0
    S0, a, R-P(a)-R-P(b), S1
    S0, *, R, S6
    
    # Transitions from S1
    S1, b, L-L-P(c)-R, S2
    S1, *, R, S7
    
    # Transitions from S2
    S2, c, R-R-P(d)-L, S3
    S2, *, L, S8
    
    # Transitions from S3
    S3, d, L-P(e)-R-R, S4
    S3, *, R, S9
    
    # Transitions from S4
    S4, e, R-R-P(a)-L-L, S5
    S4, *, L, S10
    
    # Transitions from S5
    S5, a | b | c | d | e, R-P(b)-L-L-P(X)-R, S0
    S5, *, R, S6
    
    # Transitions from S6
    S6, a | b | c | d | e, L-P(c)-R-R-P(X)-L, S7
    S6, *, L, S1
    
    # Transitions from S7
    S7, a | b | c | d | e, R-P(d)-L-L-P(X)-R, S8
    S7, *, R, S2
    
    # Transitions from S8
    S8, a | b | c | d | e, L-P(e)-R-R-P(X)-L, S9
    S8, *, L, S3
    
    # Transitions from S9
    S9, a | b | c | d | e, R-P(a)-L-L-P(X)-R, S10
    S9, *, R, S4
    
    # Transitions from S10
    S10, a | b | c | d | e, L-P(b)-R-R-P(X)-L, S5
    S10, *, L, S0
    "#;

    let lexer = Lexer::new(source);
    let mut parser = Parser::new(lexer);

    parser.program();
    println!("{:?}", parser.tree);

    // Save the dot file
    let dot = parser.tree.to_dot();
    let mut file = File::create("state_machine.dot").unwrap();
    // file.write_all(dot.as_bytes()).unwrap();
    file.write_all(dot.as_bytes()).unwrap();
}
