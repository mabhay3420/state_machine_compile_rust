use crate::lexer::{Lexer, Token, TokenType};
use log::{debug, error, info};

#[derive(Debug, PartialEq, Clone)]
pub enum Condition {
    OR(Vec<String>),
    Star,
}

#[derive(Debug, PartialEq, Clone)]
pub enum TransitionStep {
    R,
    L,
    X,
    P(String), // A function call
}

trait FromTokenAndValue {
    fn from_token_and_value(token: &Token, value: Option<String>) -> Self;
}

impl FromTokenAndValue for TransitionStep {
    fn from_token_and_value(token: &Token, value: Option<String>) -> Self {
        match token.kind {
            TokenType::R => TransitionStep::R,
            TokenType::L => TransitionStep::L,
            TokenType::X => TransitionStep::X,
            TokenType::P => TransitionStep::P(value.unwrap()),
            _ => panic!("Invalid token type for TransitionStep"),
        }
    }
}

#[derive(Debug, PartialEq, Clone)]
pub struct Transition {
    pub initial_state: String,
    pub condition: Condition,
    pub steps: Vec<TransitionStep>,
    pub final_state: String,
}

impl Transition {
    pub fn new() -> Self {
        Transition {
            initial_state: String::new(),
            condition: Condition::OR(Vec::new()),
            steps: Vec::new(),
            final_state: String::new(),
        }
    }
}

#[derive(Debug, PartialEq, Clone)]
pub struct ParseTree {
    pub states: Vec<String>,
    pub initial_state: String,
    pub symbols: Vec<String>,
    pub transitions: Vec<Transition>,
}

impl ParseTree {
    pub fn to_rust_code(&self) -> String {
        let mut code = String::new();

        // Generate the TapeMachineState enum
        code.push_str(
            "use std::fmt;\nuse std::io;\n\n#[derive(Debug, PartialEq, Eq)]\nenum TapeMachineState {\n",
        );
        for state in &self.states {
            code.push_str(&format!("    {},\n", state));
        }
        code.push_str("}\n\n");

        // Generate the TapeMachineSymbol enum
        code.push_str("#[derive(Debug, PartialEq, Eq, Clone)]\nenum TapeMachineSymbol {\n");
        for symbol in &self.symbols {
            code.push_str(&format!("    Symbol{},\n", symbol));
        }
        code.push_str("}\n\n");

        // Generate the TapeMachineSymbol implementation
        code.push_str("impl TapeMachineSymbol {\n");
        code.push_str("    fn as_str(&self) -> &'static str {\n");
        code.push_str("        match self {\n");
        code.push_str(
            &self
                .symbols
                .iter()
                .map(|symbol| {
                    format!(
                        "            TapeMachineSymbol::Symbol{} => \"{}\"",
                        symbol, symbol
                    )
                })
                .collect::<Vec<String>>()
                .join(",\n"),
        );
        code.push_str("\n        }\n");
        code.push_str("    }\n");
        code.push_str("}\n\n");

        // Generate the TapeMachine struct
        code.push_str("struct TapeMachine<'a> {\n    state: &'a TapeMachineState,\n    result: &'a mut Vec<TapeMachineSymbol>,\n    index: usize,\n}\n\n");

        // Generate the TapeMachine implementation
        code.push_str("impl<'a> TapeMachine<'a> {\n");
        code.push_str("    pub fn new(state: &'a TapeMachineState, result: &'a mut Vec<TapeMachineSymbol>) -> Self {\n");
        code.push_str("        Self {\n");
        code.push_str("            state,\n");
        code.push_str("            result,\n");
        code.push_str("            index: 0,\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");

        code.push_str("    fn p(&mut self, symbol: TapeMachineSymbol) {\n");
        code.push_str("        self.result[self.index] = symbol;\n");
        code.push_str("    }\n\n");

        code.push_str("    fn r(&mut self) {\n");
        code.push_str("        self.index += 1;\n");
        code.push_str("    }\n\n");

        code.push_str("    fn l(&mut self) {\n");
        code.push_str("        self.index -= 1;\n");
        code.push_str("    }\n");

        code.push_str("}\n\n");

        // Generate the main function
        code.push_str("fn main() {\n");
        code.push_str("    println!(\"Enter the number of steps:\");\n");
        code.push_str("    let mut steps_input = String::new();\n");
        code.push_str("    io::stdin().read_line(&mut steps_input).unwrap();\n");
        code.push_str("    let steps: usize = steps_input.trim().parse().unwrap();\n\n");

        code.push_str("    println!(\"Enter the total tape length:\");\n");
        code.push_str("    let mut tape_length_input = String::new();\n");
        code.push_str("    io::stdin().read_line(&mut tape_length_input).unwrap();\n");
        code.push_str("    let max_len: usize = tape_length_input.trim().parse().unwrap();\n\n");
        code.push_str("    let mut result = vec![TapeMachineSymbol::SymbolX; max_len];\n");
        code.push_str(&format!(
            "    let mut tape_machine = TapeMachine::new(&TapeMachineState::{}, &mut result);\n\n",
            self.initial_state
        ));

        code.push_str("    for i in 0..steps {\n");
        code.push_str("        println!(\"Step: {} State: {:?} Symbol: {:?}\",\n");
        code.push_str(
            "            i, tape_machine.state, tape_machine.result[tape_machine.index]);\n\n",
        );

        code.push_str(
            "        match (tape_machine.state, &tape_machine.result[tape_machine.index]) {\n",
        );

        // Sort transitions so that the ones with star condition are executed last
        // This is to ensure compatibility with switch statements
        let mut sorted_transitions = self.transitions.clone();
        sorted_transitions.sort_by(|a, b| {
            if a.condition == Condition::Star {
                std::cmp::Ordering::Greater
            } else if b.condition == Condition::Star {
                std::cmp::Ordering::Less
            } else {
                std::cmp::Ordering::Equal
            }
        });
        for transition in sorted_transitions {
            let condition = match &transition.condition {
                Condition::OR(symbols) => {
                    let mut condition_str = String::new();
                    for (i, symbol) in symbols.iter().enumerate() {
                        condition_str.push_str(&format!("TapeMachineSymbol::Symbol{}", symbol));
                        if i < symbols.len() - 1 {
                            condition_str.push_str(" | ");
                        }
                    }
                    condition_str
                }
                Condition::Star => "_".to_string(),
            };

            code.push_str(&format!(
                "            (TapeMachineState::{}, {}) =>",
                transition.initial_state, condition
            ));
            code.push_str("{\n");

            for step in &transition.steps {
                match step {
                    TransitionStep::R => code.push_str("                tape_machine.r();\n"),
                    TransitionStep::L => code.push_str("                tape_machine.l();\n"),
                    TransitionStep::X => {
                        code.push_str("                // X means do nothing\n");
                    }
                    TransitionStep::P(symbol) => {
                        code.push_str(&format!(
                            "                tape_machine.p(TapeMachineSymbol::Symbol{});\n",
                            symbol
                        ));
                    }
                }
            }

            code.push_str(&format!(
                "                tape_machine.state = &TapeMachineState::{};\n",
                transition.final_state
            ));
            code.push_str(&format!(
                "                println!(\"Final State: {{:?}}\", TapeMachineState::{});\n",
                transition.final_state
            ));
            code.push_str("            }\n");
        }

        code.push_str("            (_, _) => {\n");
        code.push_str("                println!(\"State: {:?} Index: {:?} Symbol: {:?}\", tape_machine.state, tape_machine.index, tape_machine.result[tape_machine.index]);\n");
        code.push_str("                let binary_result: String = tape_machine.result.iter().map(|x| x.as_str()).collect();\n");
        code.push_str("                println!(\"{}\", binary_result);\n");
        code.push_str("                panic!(\"Invalid state reached\");\n");
        code.push_str("            }\n");
        code.push_str("        }\n");
        code.push_str("    }\n\n");

        code.push_str("    let binary_result: String = tape_machine.result.iter().map(|x| x.as_str()).collect();\n");
        code.push_str("    println!(\"{}\", binary_result);\n");
        code.push_str("    let clean_result: String = tape_machine.result.iter().filter( |&x| x != &TapeMachineSymbol::SymbolX).map(|x| x.as_str()).collect();\n");
        code.push_str("    println!(\"=========\\n\");\n");
        code.push_str("    println!(\"{}\", clean_result);\n");
        code.push_str("}\n");

        code
    }
}
pub trait ToDot {
    fn to_dot(&self) -> String;
}

impl ToDot for ParseTree {
    fn to_dot(&self) -> String {
        let mut dot = String::from(
            "digraph {
                rankdir=LR;
                labelloc=\"t\";
                node [shape=circle, style=filled, fillcolor=lightblue, fontname=\"Arial\"];
                edge [fontcolor=blue, fontname=\"Arial\"];
                ",
        );

        // Define states
        for state in &self.states {
            let shape = if state == &self.initial_state {
                "doublecircle"
            } else {
                "circle"
            };
            let fillcolor = if state == &self.initial_state {
                "lightgreen"
            } else {
                "lightblue"
            };
            let width = if state == &self.initial_state {
                "1.5"
            } else {
                "1.2"
            };
            let height = if state == &self.initial_state {
                "1.5"
            } else {
                "1.2"
            };
            dot.push_str(&format!(
                "  \"{}\" [shape={}, fillcolor={}, width={}, height={}]; ",
                state, shape, fillcolor, width, height
            ));
        }

        // Define transitions
        for transition in &self.transitions {
            let condition = match &transition.condition {
                Condition::OR(symbols) => format!("[{}]", symbols.join(",")),
                Condition::Star => "*".to_string(),
            };
            let steps: Vec<String> = transition
                .steps
                .iter()
                .map(|step| match step {
                    TransitionStep::R => "R".to_string(),
                    TransitionStep::L => "L".to_string(),
                    TransitionStep::X => "X".to_string(),
                    TransitionStep::P(func) => format!("P({})", func),
                })
                .collect();
            let label = format!("{} / {}", condition, steps.join("-"));
            let color = "black";
            dot.push_str(&format!(
                "  \"{}\" -> \"{}\" [label=\"{}\", color={}];
",
                transition.initial_state, transition.final_state, label, color
            ));
        }

        dot.push_str(" } ");
        dot
    }
}

#[derive(Debug, PartialEq, Clone)]
pub struct Parser {
    lexer: Lexer,
    cur_token: Token,
    peek_token: Token,
    pub tree: ParseTree,
}

impl Parser {
    pub fn new(lexer: Lexer) -> Self {
        info!("Initializing Parser");
        let mut parser = Parser {
            lexer,
            cur_token: Token {
                text: "\0".to_string(),
                kind: TokenType::EOF,
            },
            peek_token: Token {
                text: "\0".to_string(),
                kind: TokenType::EOF,
            },
            tree: ParseTree {
                states: Vec::new(),
                initial_state: "".to_string(),
                symbols: Vec::new(),
                transitions: Vec::new(),
            },
        };
        parser.next_token(); // Initialize peek_token
        parser.next_token(); // Initialize cur_token
        parser
    }

    // Check if the current token matches the expected token type
    fn check_token(&self, kind: TokenType) -> bool {
        self.cur_token.kind == kind
    }

    // Check if the next token has the expected token type
    fn check_peek(&self, kind: TokenType) -> bool {
        self.peek_token.kind == kind
    }

    // Advance to the next token
    fn next_token(&mut self) {
        self.cur_token = self.peek_token.clone();
        self.peek_token = self.lexer.get_token().unwrap_or(Token {
            text: "\0".to_string(),
            kind: TokenType::EOF,
        });

        // If both current and peek token are newline, skip the newline
        if self.check_token(TokenType::NEWLINE) && self.check_peek(TokenType::NEWLINE) {
            self.next_token();
        }
    }

    // Abort the parsing process with an error message
    fn abort(&self, message: &str) {
        error!("Parsing error: {}", message);
        panic!("Parsing error: {}", message);
    }

    // Try to consume the current token if it matches the expected token type
    // If successful, print the token type and text (if available) and execute the optional action
    // Return true if the token was consumed, false otherwise
    fn try_consume<F>(&mut self, kind: TokenType, action: Option<F>) -> bool
    where
        F: FnMut(&Token),
    {
        if self.check_token(kind) {
            match kind {
                TokenType::IDENT => debug!("{:?}: {}", kind, self.cur_token.text),
                _ => debug!("{:?}", kind),
            }

            if let Some(mut action) = action {
                action(&self.cur_token);
            }

            self.next_token();
            true
        } else {
            false
        }
    }

    // Consume the current token if it matches the expected token type
    // If not, abort with an error message
    // Execute the optional action if provided
    fn consume<F>(&mut self, expected: TokenType, action: Option<F>)
    where
        F: FnMut(&Token),
    {
        if !self.try_consume(expected, action) {
            self.abort(&format!(
                "Expected {:?}, got {:?}",
                expected, self.cur_token.kind
            ));
        }
    }

    // Parse an initial state identifier: [IDENT]
    fn initial_state_identifier(&mut self) {
        self.consume(TokenType::LeftBracket, None::<fn(&Token)>);
        let mut initial_state = String::new();
        self.consume(
            TokenType::IDENT,
            Some(|token: &Token| {
                initial_state.push_str(&token.text);
            }),
        );
        if self.tree.initial_state.is_empty() {
            self.tree.initial_state = initial_state.clone();
            self.tree.states.push(initial_state);
        } else {
            self.abort("Initial state already defined.");
        }
        self.consume(TokenType::RightBracket, None::<fn(&Token)>);
        debug!("INITIAL_STATE_IDENTIFIER");
    }

    // Parse a list of state identifiers: IDENT (',' IDENT)*
    fn state_identifier_list(&mut self) {
        let mut state_identifiers = Vec::new();

        // Consume all tokens
        while self.check_token(TokenType::IDENT) || self.check_token(TokenType::LeftBracket) {
            if self.check_token(TokenType::LeftBracket) {
                self.initial_state_identifier();
            } else if !self.try_consume(
                TokenType::IDENT,
                Some(|token: &Token| {
                    state_identifiers.push(token.text.clone());
                }),
            ) {
                break;
            }
            if !self.try_consume(TokenType::COMMA, None::<fn(&Token)>) {
                debug!("STATE_IDENTIFIER_LIST");
                break;
            }
        }

        if self.tree.initial_state.is_empty() {
            self.abort("Initial state not defined.");
        }

        // If state identifiers have duplicates, abort with an error message
        state_identifiers.iter().for_each(|state_identifier| {
            if self.tree.states.contains(state_identifier) {
                self.abort(&format!("State {} already defined.", state_identifier));
            } else {
                self.tree.states.push(state_identifier.clone());
            }
        });
    }

    // Parse a states declaration: STATES ':' state_identifier_list NEWLINE
    fn states_declaration(&mut self) {
        self.consume(TokenType::STATES, None::<fn(&Token)>);
        self.consume(TokenType::COLON, None::<fn(&Token)>);
        self.state_identifier_list();
        self.consume(TokenType::NEWLINE, None::<fn(&Token)>);
        debug!("STATES_DECLARATION");
    }

    // Parse a list of symbol identifiers: IDENT (',' IDENT)*
    fn symbol_identifiers(&mut self) {
        let mut symbol_identifiers = Vec::new();

        self.consume(
            TokenType::IDENT,
            Some(|token: &Token| {
                symbol_identifiers.push(token.text.clone());
            }),
        );

        while self.try_consume(TokenType::COMMA, None::<fn(&Token)>) {
            self.consume(
                TokenType::IDENT,
                Some(|token: &Token| {
                    symbol_identifiers.push(token.text.clone());
                }),
            );
        }
        symbol_identifiers.iter().for_each(|symbol_identifier| {
            if self.tree.symbols.contains(symbol_identifier) {
                self.abort(&format!("Symbol {} already defined.", symbol_identifier));
            } else {
                self.tree.symbols.push(symbol_identifier.clone());
            }
        });

        // X is a special symbol
        self.tree.symbols.push("X".to_string());
        debug!("SYMBOL_IDENTIFIERS");
    }

    // Parse a symbols declaration: SYMBOLS ':' symbol_identifiers NEWLINE
    fn symbols_declaration(&mut self) {
        self.consume(TokenType::SYMBOLS, None::<fn(&Token)>);
        self.consume(TokenType::COLON, None::<fn(&Token)>);
        self.symbol_identifiers();
        self.consume(TokenType::NEWLINE, None::<fn(&Token)>);
        debug!("SYMBOLS_DECLARATION");
    }

    // Parse a transition step: R | L | P '(' IDENT ')' | X
    fn transition_step(&mut self) {
        // By default, do nothing
        let mut step: TransitionStep = TransitionStep::X;
        if self.try_consume(
            TokenType::R,
            Some(|token: &Token| {
                step = FromTokenAndValue::from_token_and_value(&token.clone(), None);
            }),
        ) {
        } else if self.try_consume(
            TokenType::L,
            Some(|token: &Token| {
                step = FromTokenAndValue::from_token_and_value(&token.clone(), None);
            }),
        ) {
        } else if self.try_consume(
            TokenType::X,
            Some(|token: &Token| {
                step = FromTokenAndValue::from_token_and_value(&token.clone(), None);
            }),
        ) {
        } else if self.try_consume(TokenType::P, None::<fn(&Token)>) {
            self.consume(TokenType::LeftParen, None::<fn(&Token)>);
            let mut print_string = String::new();
            // Either X or a symbol identifier
            if self.try_consume(
                TokenType::X,
                Some(|token: &Token| {
                    print_string.push_str(&token.text);
                }),
            ) {
            } else {
                self.consume(
                    TokenType::IDENT,
                    Some(|step: &Token| {
                        print_string.push_str(&step.text);
                    }),
                )
            };

            if !self.tree.symbols.contains(&print_string) {
                self.abort(&format!(
                    "Symbol {} not defined, So cannot be printed.",
                    print_string
                ));
            }
            step = FromTokenAndValue::from_token_and_value(
                &Token {
                    text: "P".to_string(),
                    kind: TokenType::P,
                },
                Some(print_string),
            );

            self.consume(TokenType::RightParen, None::<fn(&Token)>);
        } else {
            self.abort(&format!(
                "Expected {:?} or {:?} or {:?} or {:?} as an action step, got {:?}: {:?}",
                TokenType::R,
                TokenType::L,
                TokenType::P,
                TokenType::X,
                self.cur_token.kind,
                self.cur_token.text
            ));
        }
        self.tree.transitions.last_mut().unwrap().steps.push(step);
    }

    fn transition_steps(&mut self) {
        self.transition_step();
        while self.try_consume(TokenType::DASH, None::<fn(&Token)>) {
            self.transition_step();
        }
        debug!("TRANSITION_STEPS");
    }

    // Parse a list of transition conditions: IDENT ('|' IDENT)*
    fn transition_condition_list(&mut self) {
        let mut conditions: Vec<String> = Vec::new();

        // Consume X as well
        if self.try_consume(
            TokenType::X,
            Some(|token: &Token| {
                conditions.push(token.text.clone());
            }),
        ) {
        } else {
            self.consume(
                TokenType::IDENT,
                Some(|token: &Token| {
                    conditions.push(token.text.clone());
                }),
            );
        }

        while self.try_consume(TokenType::OR, None::<fn(&Token)>) {
            // Consume X as well
            if self.try_consume(
                TokenType::X,
                Some(|token: &Token| {
                    conditions.push(token.text.clone());
                }),
            ) {
            } else {
                self.consume(
                    TokenType::IDENT,
                    Some(|token: &Token| {
                        conditions.push(token.text.clone());
                    }),
                );
            }
        }
        self.tree.transitions.last_mut().unwrap().condition = Condition::OR(conditions);
        debug!("TRANSITION_CONDITION_LIST");
    }

    // Parse transition conditions: '*' | transition_condition_list
    fn transition_conditions(&mut self) {
        let mut star_condition = false;
        if !self.try_consume(
            TokenType::STAR,
            Some(|_token: &Token| {
                star_condition = true;
            }),
        ) {
            self.transition_condition_list();
        }

        // Override all other conditions with the star condition
        if star_condition {
            self.tree.transitions.last_mut().unwrap().condition = Condition::Star;
        }
        debug!("TRANSITION_CONDITIONS");
    }

    // Parse a transition declaration:
    // IDENT ',' transition_conditions ',' transition_steps ',' IDENT
    fn transition_declaration(&mut self) {
        // Initialize a new transition
        self.tree.transitions.push(Transition::new());

        // Initial state
        let mut initial_state = String::new();
        self.consume(
            TokenType::IDENT,
            Some(|token: &Token| {
                initial_state.push_str(&token.text);
            }),
        );
        self.tree.transitions.last_mut().unwrap().initial_state = initial_state;

        debug!("INITIAL_STATE_IDENTIFIER");
        self.consume(TokenType::COMMA, None::<fn(&Token)>);

        // Conditions
        self.transition_conditions();
        self.consume(TokenType::COMMA, None::<fn(&Token)>);

        // Actions
        self.transition_steps();
        self.consume(TokenType::COMMA, None::<fn(&Token)>);

        // Final state
        let mut final_state = String::new();
        self.consume(
            TokenType::IDENT,
            Some(|token: &Token| {
                final_state.push_str(&token.text);
            }),
        );
        self.tree.transitions.last_mut().unwrap().final_state = final_state;
        debug!("FINAL_STATE_IDENTIFIER");
        debug!("TRANSITION_DECLARATION");
    }

    // Parse transitions declarations:
    // TRANSITIONS ':' (NEWLINE transition_declaration)*
    fn transitions_declaration(&mut self) {
        self.consume(TokenType::TRANSITIONS, None::<fn(&Token)>);
        self.consume(TokenType::COLON, None::<fn(&Token)>);

        while self.try_consume(TokenType::NEWLINE, None::<fn(&Token)>) {
            if self.check_token(TokenType::EOF) {
                break;
            }
            self.transition_declaration();
        }
        debug!("TRANSITION_DECLARATIONS");
    }

    // Parse the entire program:
    // NEWLINE? states_declaration symbols_declaration transitions_declaration NEWLINE? EOF
    pub fn program(&mut self) {
        // Consume newlines
        while self.try_consume(TokenType::NEWLINE, None::<fn(&Token)>) {}
        self.states_declaration();
        self.symbols_declaration();
        self.transitions_declaration();
        // Consume newlines
        while self.try_consume(TokenType::NEWLINE, None::<fn(&Token)>) {}
        self.consume(TokenType::EOF, None::<fn(&Token)>);
        debug!("PROGRAM");
    }
}
