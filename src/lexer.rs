use log::{error, info};
use std::str::FromStr;

#[derive(Debug, PartialEq, Clone, Copy)]
pub enum TokenType {
    // Special
    EOF = -1,
    NEWLINE = 0,

    // Keywords
    STATES = 201,
    SYMBOLS = 202,
    TRANSITIONS = 203,
    // Contextual Keywords
    R = 104,
    L = 105,
    X = 106,
    P = 107,

    // Identifiers : Alphanumerics
    IDENT = 7,

    // Operators
    OR = 8,
    LeftBracket = 9,
    RightBracket = 10,
    COMMA = 11,
    DASH = 12,
    LeftParen = 13,
    RightParen = 14,
    STAR = 15,
    COLON = 16,
}

impl FromStr for TokenType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "EOF" => Ok(TokenType::EOF),
            "NEWLINE" => Ok(TokenType::NEWLINE),
            "STATES" => Ok(TokenType::STATES),
            "SYMBOLS" => Ok(TokenType::SYMBOLS),
            "TRANSITIONS" => Ok(TokenType::TRANSITIONS),
            "R" => Ok(TokenType::R),
            "L" => Ok(TokenType::L),
            "P" => Ok(TokenType::P),
            "X" => Ok(TokenType::X),
            "IDENT" => Ok(TokenType::IDENT),
            "OR" => Ok(TokenType::OR),
            "LEFT_BRACKET" => Ok(TokenType::LeftBracket),
            "RIGHT_BRACKET" => Ok(TokenType::RightBracket),
            "COMMA" => Ok(TokenType::COMMA),
            "DASH" => Ok(TokenType::DASH),
            "LEFT_PAREN" => Ok(TokenType::LeftParen),
            "RIGHT_PAREN" => Ok(TokenType::RightParen),
            "STAR" => Ok(TokenType::STAR),
            "COLON" => Ok(TokenType::COLON),
            _ => Err(format!("Unknown token type: {}", s)),
        }
    }
}

#[derive(Debug, PartialEq, Clone)]
pub struct Token {
    pub text: String,
    pub kind: TokenType,
}

impl Token {
    fn check_if_keyword(token_text: &str) -> Option<TokenType> {
        let token_type = TokenType::from_str(token_text);
        match token_type {
            Ok(t) => {
                if t as i32 > 100 {
                    Some(t)
                } else {
                    None
                }
            }
            Err(_s) => None,
        }
    }
}

#[derive(Debug, PartialEq, Clone)]
pub struct Lexer {
    source: Vec<char>,
    pub cur_char: char,
    cur_pos: usize,
}

impl Lexer {
    pub fn new(source: &str) -> Self {
        info!("Initializing Lexer");
        let mut source_chars = source.chars().collect::<Vec<_>>();
        source_chars.push('\n');

        let cur_char = if source_chars.len() > 1 {
            source_chars[0]
        } else {
            '\n'
        };

        Lexer {
            source: source_chars,
            cur_char,
            cur_pos: 0,
        }
    }

    pub fn cur_char(&self) -> char {
        self.source[self.cur_pos]
    }

    pub fn next_char(&mut self) {
        self.cur_pos += 1;
        if self.cur_pos >= self.source.len() {
            self.cur_char = '\0'; // EOF
        } else {
            self.cur_char = self.source[self.cur_pos];
        }
    }

    pub fn peek(&self) -> char {
        if self.cur_pos + 1 >= self.source.len() {
            '\0' // EOF
        } else {
            self.source[self.cur_pos + 1]
        }
    }

    pub fn abort(&self, message: &str) {
        error!("Lexical Error: {}", message);
        panic!("Lexical Error: {}", message);
    }

    fn skip_whitespace(&mut self) {
        while self.cur_char == ' ' || self.cur_char == '\t' || self.cur_char == '\r' {
            self.next_char();
        }
    }

    fn skip_comment(&mut self) {
        if self.cur_char == '#' {
            while self.cur_char != '\n' {
                self.next_char();
            }
        }
    }

    pub fn get_token(&mut self) -> Option<Token> {
        self.skip_whitespace();
        self.skip_comment();

        let token = match self.cur_char {
            '\n' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::NEWLINE,
            }),
            '|' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::OR,
            }),
            '[' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::LeftBracket,
            }),
            ']' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::RightBracket,
            }),
            ',' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::COMMA,
            }),
            '-' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::DASH,
            }),
            '(' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::LeftParen,
            }),
            ')' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::RightParen,
            }),
            '*' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::STAR,
            }),
            ':' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::COLON,
            }),
            '\0' => Some(Token {
                text: self.cur_char.to_string(),
                kind: TokenType::EOF,
            }),
            _ if self.cur_char.is_alphanumeric() => {
                let start_pos = self.cur_pos;
                while self.peek().is_alphanumeric() {
                    self.next_char();
                }
                let tok_text: String = self.source[start_pos..=self.cur_pos].iter().collect();
                match Token::check_if_keyword(&tok_text) {
                    Some(keyword) => Some(Token {
                        text: tok_text,
                        kind: keyword,
                    }),
                    None => Some(Token {
                        text: tok_text,
                        kind: TokenType::IDENT,
                    }),
                }
            }
            _ => {
                self.abort(&format!("Unknown token: {}", self.cur_char));
                None
            }
        };

        self.next_char();
        token
    }
}
