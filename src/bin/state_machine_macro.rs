#[macro_export]
macro_rules! states {
    ( $( $x: ident),* ) => {
        // {
            #[derive(Debug)]
            enum TapeMachineState {
                $(
                    $x,
                )*
            }
        impl TapeMachineState {
            fn as_str(&self) -> &'static str {
                match self {
                    $(
                        TapeMachineState::$x => stringify!($x),
                    )*
                }
            }
        }
        // }
    };
}

/*

States : B, O, Q, P, F

Symbols : 0, 1, X

Defaults: B(Blank), A(all)

Moves: L(Moves left), R(Moves right), P_x(Prints x), E(erase)

max_len = 100_000
max_steps = 10_000
*/

macro_rules! symbols {
    ( $(($x: ident, $y: literal)),* ) => {
        #[derive(Debug)]
        enum TapeMachineSymbol {
            $(
                $x,
            )*
            B,
            E,
            A,
        }

        impl TapeMachineSymbol {
            fn as_str(&self) -> &'static str {
                match self {
                    $(
                        TapeMachineSymbol::$x => $y,
                    )*
                    TapeMachineSymbol::B => "",
                    TapeMachineSymbol::E => "",
                    TapeMachineSymbol::A => "*",
                }
            }
        }
    };
}

// macro_rules! actions {
//     ( $(($x: ident, $y: literal)),* ) => {
//         #[derive(Debug)]
//         enum TapeMachineAction {
//             R,
//             L,
//             P,
//             E,
//         }
//     };
// }

macro_rules! init_tape {
    () => {
        #[derive(Debug)]
        struct TapeMachine<'a> {
            state: &'a TapeMachineState,
            result: &'a mut Vec<&'a TapeMachineSymbol>,
            index: usize,
        }

        impl<'a> TapeMachine<'a> {
            pub fn new(
                state: &'a TapeMachineState,
                result: &'a mut Vec<&'a TapeMachineSymbol>,
            ) -> TapeMachine<'a> {
                return TapeMachine {
                    state,
                    result,
                    index: 0usize,
                };
            }
        }

        fn p<'a>(c: &'a TapeMachineSymbol, index: usize, vec: &mut [&'a TapeMachineSymbol]) {
            vec[index] = &c;
        }

        fn r(index: &mut usize) {
            *index += 1;
        }

        fn l(index: &mut usize) {
            *index -= 1;
        }
    };
}

macro_rules! process_action {
    (A) => {
        _
    };
    ($action: ident) => {
        TapeMachineSymbol::$action
    };
}

macro_rules! transition_rules {
    ($tape_machine: ident, $steps: ident, $({ [$state: ident], [$($condition: ident)|+], [$($action: expr),*], [$final_state: ident] } ),* )=> {
        for i in 0..$steps {
            println!(
                "Step: {} State: {:?} Symbol: {:?}",i,
                $tape_machine.state, $tape_machine.result[$tape_machine.index]
            );
            match($tape_machine.state, $tape_machine.result[$tape_machine.index]) {
                $(
                    (TapeMachineState::$state,
                        $(
                            process_action!($condition)
                        ) | *
                    ) => {
                            $(
                                $action;
                            )*
                            $tape_machine.state = &TapeMachineState::$final_state;
                            println!("Final State: {:?}", TapeMachineState::$final_state);
                        }
                )*
                (_, _) => {
                    println!(
                        "{:?} {:?}",
                        $tape_machine.state, $tape_machine.result[$tape_machine.index]
                    );
                    panic!("Invalid state reached");
                }
            }
        }
    };
}

// states!(B, O, Q, P, F);
// symbols!((Zero, "0"), (One, "1"), (X, "x"));
// init_tape!();
states!(A, B);
symbols!((Zero, "0"), (One, "1"), (X, "x"));
init_tape!();

// 0010110111011110111110111111011111110111111110111111111

// To test: rustc +nightly -Zunpretty=expanded src/main.rs

macro_rules! P {
    ($tape_machine: ident, $symbol: ident) => {
        p(
            &TapeMachineSymbol::$symbol,
            $tape_machine.index,
            $tape_machine.result,
        )
    };
}

macro_rules! R {
    ($tape_machine: ident) => {
        r(&mut $tape_machine.index)
    };
}

macro_rules! L {
    ($tape_machine: ident) => {
        l(&mut $tape_machine.index)
    };
}

macro_rules! E {
    ($tape_machine: ident) => {
        P!($tape_machine, B)
    };
}

fn main() {
    let max_len = 1000;
    let steps = 100;
    let mut result: Vec<&TapeMachineSymbol> = vec![&TapeMachineSymbol::B; max_len];
    // A is the initial state
    let mut tape_machine = TapeMachine::new(&TapeMachineState::A, &mut result);
    transition_rules!(
        tape_machine,
        steps,
        {[A], [A], [P!(tape_machine, Zero)],[B]},
        {[B], [Zero], [R!(tape_machine), P!(tape_machine, One)], [B]},
        {[B], [One], [R!(tape_machine)], [A]}
    );

    let binary_result = tape_machine
        .result
        .iter()
        .map(|x| x.as_str())
        .collect::<String>();

    // 010101..
    println!("{}", binary_result);
}

// fn main() {
//     let max_len = 1000;
//     let steps = 100;
//     let mut result: Vec<&TapeMachineSymbol> = vec![&TapeMachineSymbol::B; max_len];
//     let mut tape_machine = TapeMachine::new(&TapeMachineState::B, &mut result);
//     transition_rules!(
//         tape_machine,
//         steps,
//         { [B], [A], [P!(tape_machine, E), R!(tape_machine), P!(tape_machine, E), R!(tape_machine), P!(tape_machine, Zero), R!(tape_machine), R!(tape_machine), P!(tape_machine, Zero), L!(tape_machine), L!(tape_machine)], [O] },
//         { [O], [One], [R!(tape_machine), P!(tape_machine, X), L!(tape_machine), L!(tape_machine), L!(tape_machine)], [O] },
//         { [O], [Zero], [], [Q] },
//         { [Q], [Zero | One], [R!(tape_machine), R!(tape_machine)], [Q] },
//         { [Q], [B], [P!(tape_machine, One), L!(tape_machine)], [P] },
//         { [P], [X], [E!(tape_machine), R!(tape_machine)], [Q] },
//         { [P], [E], [R!(tape_machine)], [F] },
//         { [P], [B], [L!(tape_machine), L!(tape_machine)], [P] },
//         { [F], [B], [P!(tape_machine, Zero), L!(tape_machine), L!(tape_machine)], [O] },
//         { [F], [A], [R!(tape_machine), R!(tape_machine)], [F] }
//     );
//     let binary_result = tape_machine
//         .result
//         .iter()
//         .map(|x| x.as_str())
//         .collect::<String>();
//     println!("{}", binary_result);
// }
