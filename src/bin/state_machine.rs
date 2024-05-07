use std::fmt;
use std::io;

#[derive(Debug, PartialEq, Eq)]
enum TapeMachineState {
    a,
    b,
}

#[derive(Debug, PartialEq, Eq, Clone)]
enum TapeMachineSymbol {
    Symbol0,
    Symbol1,
    SymbolX,
}

impl TapeMachineSymbol {
    fn as_str(&self) -> &'static str {
        match self {
            TapeMachineSymbol::Symbol0 => "0",
            TapeMachineSymbol::Symbol1 => "1",
            TapeMachineSymbol::SymbolX => "X"
        }
    }
}

struct TapeMachine<'a> {
    state: &'a TapeMachineState,
    result: &'a mut Vec<TapeMachineSymbol>,
    index: usize,
}

impl<'a> TapeMachine<'a> {
    pub fn new(state: &'a TapeMachineState, result: &'a mut Vec<TapeMachineSymbol>) -> Self {
        Self {
            state,
            result,
            index: 0,
        }
    }

    fn p(&mut self, symbol: TapeMachineSymbol) {
        self.result[self.index] = symbol;
    }

    fn r(&mut self) {
        self.index += 1;
    }

    fn l(&mut self) {
        self.index -= 1;
    }
}

fn main() {
    println!("Enter the number of steps:");
    let mut steps_input = String::new();
    io::stdin().read_line(&mut steps_input).unwrap();
    let steps: usize = steps_input.trim().parse().unwrap();

    println!("Enter the total tape length:");
    let mut tape_length_input = String::new();
    io::stdin().read_line(&mut tape_length_input).unwrap();
    let max_len: usize = tape_length_input.trim().parse().unwrap();

    let mut result = vec![TapeMachineSymbol::SymbolX; max_len];
    let mut tape_machine = TapeMachine::new(&TapeMachineState::a, &mut result);

    for i in 0..steps {
        println!("Step: {} State: {:?} Symbol: {:?}",
            i, tape_machine.state, tape_machine.result[tape_machine.index]);

        match (tape_machine.state, &tape_machine.result[tape_machine.index]) {
            (TapeMachineState::b, TapeMachineSymbol::Symbol0) =>{
                tape_machine.r();
                tape_machine.p(TapeMachineSymbol::Symbol1);
                tape_machine.state = &TapeMachineState::b;
                println!("Final State: {:?}", TapeMachineState::b);
            }
            (TapeMachineState::b, TapeMachineSymbol::Symbol1) =>{
                tape_machine.r();
                tape_machine.p(TapeMachineSymbol::Symbol0);
                tape_machine.state = &TapeMachineState::a;
                println!("Final State: {:?}", TapeMachineState::a);
            }
            (TapeMachineState::a, _) =>{
                tape_machine.p(TapeMachineSymbol::Symbol0);
                tape_machine.state = &TapeMachineState::b;
                println!("Final State: {:?}", TapeMachineState::b);
            }
            (_, _) => {
                println!("State: {:?} Index: {:?} Symbol: {:?}", tape_machine.state, tape_machine.index, tape_machine.result[tape_machine.index]);
                let binary_result: String = tape_machine.result.iter().map(|x| x.as_str()).collect();
                println!("{}", binary_result);
                panic!("Invalid state reached");
            }
        }
    }

    let binary_result: String = tape_machine.result.iter().map(|x| x.as_str()).collect();
    println!("{}", binary_result);
    let clean_result: String = tape_machine.result.iter().filter( |&x| x != &TapeMachineSymbol::SymbolX).map(|x| x.as_str()).collect();
    println!("=========\n");
    println!("{}", clean_result);
}
