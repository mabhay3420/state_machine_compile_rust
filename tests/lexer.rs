use state_machine_compiler_rust::lexer::{Lexer, Token, TokenType};

#[test]
fn test_next_char() {
    let code = " states: [A], B ";
    let mut lexer = Lexer::new(code);
    let mut chars = Vec::new();
    while lexer.peek() != '\0' {
        chars.push(lexer.cur_char);
        lexer.next_char();
    }
    assert_eq!(chars.iter().collect::<String>(), code);
}

#[test]
fn test_get_token() {
    let code = "[],";
    let expected = vec![
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
    ];
    let mut lexer = Lexer::new(code);
    let mut result = Vec::new();
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        result.push(token);
    }
    println!("Result: {:?}", result);
    println!("Expected: {:?}", expected);
    assert_eq!(result, expected);
    // assert!(false)
}

#[test]
#[should_panic(expected = "Lexical Error: Unknown token: !")]
fn test_invalid_token() {
    let code = "[]";
    let mut lexer = Lexer::new(code);
    while let Some(token) = lexer.get_token() {
        println!("{:?}", token);
        if token.kind == TokenType::EOF {
            break;
        }
    }
}

#[test]
fn test_whitespace_token() {
    let code = "[ ]";
    let expected = vec![
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
    ];
    let mut lexer = Lexer::new(code);
    let mut result = Vec::new();
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        result.push(token);
    }
    assert_eq!(result, expected);
}

#[test]
fn test_more_tokens() {
    let code = "[ * ],--|";
    let expected = vec![
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "*".to_string(),
            kind: TokenType::STAR,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "-".to_string(),
            kind: TokenType::DASH,
        },
        Token {
            text: "-".to_string(),
            kind: TokenType::DASH,
        },
        Token {
            text: "|".to_string(),
            kind: TokenType::OR,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
    ];
    let mut lexer = Lexer::new(code);
    let mut result = Vec::new();
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        result.push(token);
    }
    assert_eq!(result, expected);
}

#[test]
fn test_comments() {
    let code = "[]# This is a comment *\n    * |\n    # This is another comment - -";
    let expected = vec![
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "*".to_string(),
            kind: TokenType::STAR,
        },
        Token {
            text: "|".to_string(),
            kind: TokenType::OR,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
    ];
    let mut lexer = Lexer::new(code);
    let mut result = Vec::new();
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        result.push(token);
    }
    assert_eq!(result, expected);
}

#[test]
fn test_keywords_and_identifiers() {
    let code = "
        STATES: [A], B, C1
        SYMBOLS: [0 , 1, X, R]
        TRANSITIONS: [A, 0 | 1, L-R-P(X), B], [B, * , L , C1]
    ";
    let expected = vec![
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "STATES".to_string(),
            kind: TokenType::STATES,
        },
        Token {
            text: ":".to_string(),
            kind: TokenType::COLON,
        },
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "A".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "B".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "C1".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "SYMBOLS".to_string(),
            kind: TokenType::SYMBOLS,
        },
        Token {
            text: ":".to_string(),
            kind: TokenType::COLON,
        },
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "0".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "1".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "X".to_string(),
            kind: TokenType::X,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "R".to_string(),
            kind: TokenType::R,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "TRANSITIONS".to_string(),
            kind: TokenType::TRANSITIONS,
        },
        Token {
            text: ":".to_string(),
            kind: TokenType::COLON,
        },
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "A".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "0".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: "|".to_string(),
            kind: TokenType::OR,
        },
        Token {
            text: "1".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "L".to_string(),
            kind: TokenType::L,
        },
        Token {
            text: "-".to_string(),
            kind: TokenType::DASH,
        },
        Token {
            text: "R".to_string(),
            kind: TokenType::R,
        },
        Token {
            text: "-".to_string(),
            kind: TokenType::DASH,
        },
        Token {
            text: "P".to_string(),
            kind: TokenType::P,
        },
        Token {
            text: "(".to_string(),
            kind: TokenType::LEFT_PAREN,
        },
        Token {
            text: "X".to_string(),
            kind: TokenType::X,
        },
        Token {
            text: ")".to_string(),
            kind: TokenType::RIGHT_PAREN,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "B".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "[".to_string(),
            kind: TokenType::LEFT_BRACKET,
        },
        Token {
            text: "B".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "*".to_string(),
            kind: TokenType::STAR,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "L".to_string(),
            kind: TokenType::L,
        },
        Token {
            text: ",".to_string(),
            kind: TokenType::COMMA,
        },
        Token {
            text: "C1".to_string(),
            kind: TokenType::IDENT,
        },
        Token {
            text: "]".to_string(),
            kind: TokenType::RIGHT_BRACKET,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
        Token {
            text: "\n".to_string(),
            kind: TokenType::NEWLINE,
        },
    ];
    let mut lexer = Lexer::new(code);
    let mut result = Vec::new();
    while let Some(token) = lexer.get_token() {
        if token.kind == TokenType::EOF {
            break;
        }
        result.push(token);
    }
    assert_eq!(result, expected);
}
