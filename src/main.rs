use state_machine_compiler_rust::lexer::{Lexer, TokenType};

fn main() {
    let source = r#"
    # Comments
    STATES: [A], B
    # Comment 2
    SYMBOLS: 0, 1, X, B
    TRANSITIONS: [A, 0 | 1, R-L-L-P(X)-L, B], [B, * , P(X)-L, A]
"#;

    let mut lexer = Lexer::new(source);
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        println!("{:?}", token);
    }
}
