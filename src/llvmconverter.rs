#![allow(unused)]
use std::collections::{HashMap, HashSet};

use crate::parser::{Condition, ParseTree, Transition,TransitionStep};
use inkwell::basic_block::BasicBlock;
use inkwell::context::Context;
use inkwell::targets::TargetTriple;
use inkwell::values::{FunctionValue, PointerValue};
use inkwell::{AddressSpace, IntPredicate};

// Trait for converting to LLVM IR
pub trait ToLlvmIr {
    fn to_llvm_ir(&self) -> String;
}

impl ToLlvmIr for ParseTree {
    fn to_llvm_ir(&self) -> String {
        // Create LLVM context, module, and builder
        let context = Context::create();
        let module = context.create_module("tape_machine");
        let builder = context.create_builder();

        // Set target triple for macOS on ARM64
        let triple = TargetTriple::create("arm64-apple-macosx13.0.0");
        module.set_triple(&triple);

        // Define basic LLVM types
        let i32_type = context.i32_type();
        let i8_type = context.i8_type();
        let ptr_type = i8_type.ptr_type(AddressSpace::default());

        // Declare external functions (printf, malloc, scanf)
        let printf_type = i32_type.fn_type(&[ptr_type.into()], true);
        let printf_fn = module.add_function("printf", printf_type, None);

        let malloc_type = ptr_type.fn_type(&[i32_type.into()], false);
        let malloc_fn = module.add_function("malloc", malloc_type, None);

        let scanf_type = i32_type.fn_type(&[ptr_type.into()], true);
        let scanf_fn = module.add_function("scanf", scanf_type, None);

        // Prepare state and symbol mappings
        let state_to_int: HashMap<String, u64> = self
            .states
            .iter()
            .enumerate()
            .map(|(i, s)| (s.clone(), i as u64))
            .collect();

        // Collect all symbols used, including those in transitions
        let mut all_symbols: HashSet<String> = self.symbols.iter().cloned().collect();
        for transition in &self.transitions {
            match &transition.condition {
                Condition::OR(symbols) => {
                    for symbol in symbols {
                        all_symbols.insert(symbol.clone());
                    }
                }
                Condition::Star => {}
            }
            for step in &transition.steps {
                if let TransitionStep::P(symbol) = step {
                    all_symbols.insert(symbol.clone());
                }
            }
        }
        // Include 'X' if not already included (used in tape initialization)
        all_symbols.insert("X".to_string());

        let symbol_to_int: HashMap<String, u64> = all_symbols
            .iter()
            .enumerate()
            .map(|(i, s)| (s.clone(), i as u64))
            .collect();

        // Map characters to symbol integers
        let symbol_char_to_int: HashMap<u8, u64> = symbol_to_int
            .iter()
            .filter_map(|(symbol, &int_value)| {
                if symbol.len() == 1 {
                    Some((symbol.as_bytes()[0], int_value))
                } else {
                    None
                }
            })
            .collect();

        // Define main function
        let main_type = i32_type.fn_type(&[], false);
        let main_fn = module.add_function("main", main_type, None);
        let entry = context.append_basic_block(main_fn, "entry");
        builder.position_at_end(entry);

        // Allocate and initialize variables
        let num_steps_ptr = builder.build_alloca(i32_type, "num_steps").unwrap();
        let arr_size_ptr = builder.build_alloca(i32_type, "arr_size").unwrap();
        let index_ptr = builder.build_alloca(i32_type, "index").unwrap();
        builder.build_store(index_ptr, i32_type.const_int(0, false));

        // Prompt user for input (number of steps)
        let num_steps_prompt = builder.build_global_string_ptr("Enter number of steps: ", "num_steps_prompt").unwrap();
        let scanf_format = builder.build_global_string_ptr("%d", "scanf_format").unwrap();
        builder.build_call(printf_fn, &[num_steps_prompt.as_pointer_value().into()], "printf");
        builder.build_call(scanf_fn, &[scanf_format.as_pointer_value().into(), num_steps_ptr.into()], "scanf");

        // Load num_steps value
        let num_steps = builder.build_load(i32_type, num_steps_ptr, "num_steps").unwrap().into_int_value();

        // Prompt user for input (array size)
        let arr_size_prompt = builder.build_global_string_ptr("Enter array size: ", "arr_size_prompt").unwrap();
        builder.build_call(printf_fn, &[arr_size_prompt.as_pointer_value().into()], "printf");
        builder.build_call(scanf_fn, &[scanf_format.as_pointer_value().into(), arr_size_ptr.into()], "scanf");

        // Allocate tape dynamically using malloc
        let arr_size = builder.build_load(i32_type, arr_size_ptr, "arr_size").unwrap().into_int_value();
        let tape_ptr = builder
            .build_call(malloc_fn, &[arr_size.into()], "tape_malloc")
            .unwrap()
            .try_as_basic_value()
            .left()
            .unwrap()
            .into_pointer_value();

        let init_loop = context.append_basic_block(main_fn, "init_loop");
        let init_loop_body = context.append_basic_block(main_fn, "init_loop_body");
        let init_loop_end = context.append_basic_block(main_fn, "init_loop_end");

        // Initialize loop counter
        let i = builder.build_alloca(i32_type, "i").unwrap();
        builder.build_store(i, i32_type.const_int(0, false));
        builder.build_unconditional_branch(init_loop);

        // Loop condition
        builder.position_at_end(init_loop);
        let i_val = builder.build_load(i32_type, i, "i_val").unwrap().into_int_value();
        let cond = builder.build_int_compare(IntPredicate::ULT, i_val, arr_size, "init_cond").unwrap();
        builder.build_conditional_branch(cond, init_loop_body, init_loop_end);

        // Loop body: initialize tape with 'X'
        builder.position_at_end(init_loop_body);
        let element_ptr = unsafe { builder.build_gep(i8_type, tape_ptr, &[i_val], "element_ptr").unwrap() };
        builder.build_store(element_ptr, i8_type.const_int('X' as u64, false));
        let next_i = builder.build_int_add(i_val, i32_type.const_int(1, false), "next_i").unwrap();
        builder.build_store(i, next_i);
        builder.build_unconditional_branch(init_loop);

        builder.position_at_end(init_loop_end);

        // Initialize state as integer
        let initial_state = self.transitions[0].initial_state.clone();
        let state_ptr_alloca = builder.build_alloca(i32_type, "state_ptr").unwrap();
        let initial_state_value = i32_type.const_int(state_to_int[&initial_state], false);
        builder.build_store(state_ptr_alloca, initial_state_value);

        // Initialize step counter
        let step_counter = builder.build_alloca(i32_type, "step_counter").unwrap();
        builder.build_store(step_counter, i32_type.const_int(0, false));

        // Main loop
        let main_loop = context.append_basic_block(main_fn, "main_loop");
        let main_loop_body = context.append_basic_block(main_fn, "main_loop_body");
        let main_loop_end = context.append_basic_block(main_fn, "main_loop_end");

        builder.build_unconditional_branch(main_loop);

        builder.position_at_end(main_loop);

        // Check if we've reached the maximum number of steps
        let current_step = builder.build_load(i32_type, step_counter, "current_step").unwrap().into_int_value();
        let continue_loop = builder.build_int_compare(IntPredicate::ULT, current_step, num_steps, "continue_loop").unwrap();
        builder.build_conditional_branch(continue_loop, main_loop_body, main_loop_end);

        // Main loop body
        builder.position_at_end(main_loop_body);

        // Load current state and symbol
        let current_state = builder.build_load(i32_type, state_ptr_alloca, "current_state").unwrap().into_int_value();
        let current_index = builder.build_load(i32_type, index_ptr, "current_index").unwrap().into_int_value();
        let current_symbol_ptr = unsafe { builder.build_gep(i8_type, tape_ptr, &[current_index], "current_symbol_ptr").unwrap() };
        let current_symbol = builder.build_load(i8_type, current_symbol_ptr, "current_symbol").unwrap().into_int_value();

        // Map current_symbol (i8) to symbol_int (i32)
        let symbol_int_ptr = builder.build_alloca(i32_type, "symbol_int").unwrap();
        let symbol_switch_block = context.append_basic_block(main_fn, "symbol_switch");
        let after_symbol_switch = context.append_basic_block(main_fn, "after_symbol_switch");
        builder.build_unconditional_branch(symbol_switch_block);

        builder.position_at_end(symbol_switch_block);

        // Build switch on current_symbol
        let mut symbol_cases = Vec::new();
        for (&char_value, &symbol_int_value) in &symbol_char_to_int {
            let case_block = context.append_basic_block(main_fn, &format!("symbol_case_{}", symbol_int_value));
            symbol_cases.push((i8_type.const_int(char_value as u64, false), case_block));

            // In each case block
            builder.position_at_end(case_block);
            builder.build_store(symbol_int_ptr, i32_type.const_int(symbol_int_value, false));
            builder.build_unconditional_branch(after_symbol_switch);
        }
        // Default case
        let symbol_default_block = context.append_basic_block(main_fn, "symbol_default");
        builder.position_at_end(symbol_default_block);
        // Store a special value for unknown symbol (e.g., -1)
        builder.build_store(symbol_int_ptr, i32_type.const_int(-1i64 as u64, false));
        builder.build_unconditional_branch(after_symbol_switch);

        builder.position_at_end(symbol_switch_block);
        builder.build_switch(
            current_symbol,
            symbol_default_block,
            &symbol_cases
                .iter()
                .map(|(val, block)| (*val, *block))
                .collect::<Vec<_>>(),
        );

        builder.position_at_end(after_symbol_switch);
        let symbol_int = builder.build_load(i32_type, symbol_int_ptr, "symbol_int").unwrap().into_int_value();

        // Create blocks for each state
        let mut state_blocks: HashMap<u64, BasicBlock> = HashMap::new();
        let mut state_cases = Vec::new();
        for (state_name, &state_int) in &state_to_int {
            let state_block = context.append_basic_block(main_fn, &format!("state_{}", state_name));
            state_blocks.insert(state_int, state_block);
            state_cases.push((i32_type.const_int(state_int, false), state_block));
        }
        let default_state_block = context.append_basic_block(main_fn, "default_state");

        // Build switch on current_state
        builder.build_switch(
            current_state,
            default_state_block,
            &state_cases.iter().map(|(val, block)| (*val, *block)).collect::<Vec<_>>(),
        );

        // For each state, collect transitions for that state
        let mut state_transitions: HashMap<u64, Vec<&Transition>> = HashMap::new();
        for transition in &self.transitions {
            let state_int = state_to_int[&transition.initial_state];
            state_transitions.entry(state_int).or_default().push(transition);
        }

        // For each state, build transitions
        for (&state_int, transitions) in &state_transitions {
            let state_block = state_blocks[&state_int];
            builder.position_at_end(state_block);

            // Collect symbol cases for this state
            let mut symbol_cases = Vec::new();
            let mut default_block = None;

            for transition in transitions {
                match &transition.condition {
                    Condition::OR(symbols) => {
                        for symbol in symbols {
                            let symbol_int = symbol_to_int[symbol];
                            let trans_block = context.append_basic_block(main_fn, &format!("transition_{}_{}", state_int, symbol_int));

                            symbol_cases.push((i32_type.const_int(symbol_int, false), trans_block));

                            // Implement transition logic in trans_block
                            builder.position_at_end(trans_block);
                            self.perform_transition_steps(
                                &builder,
                                &context,
                                &i32_type,
                                &i8_type,
                                &printf_fn,
                                tape_ptr,
                                index_ptr,
                                state_ptr_alloca,
                                step_counter,
                                &transition.steps,
                                &transition.final_state,
                                &state_to_int,
                                main_loop,
                            );
                        }
                    }
                    Condition::Star => {
                        let trans_block = context.append_basic_block(main_fn, &format!("transition_{}_default", state_int));

                        default_block = Some(trans_block);

                        // Implement transition logic in trans_block
                        builder.position_at_end(trans_block);
                        self.perform_transition_steps(
                            &builder,
                            &context,
                            &i32_type,
                            &i8_type,
                            &printf_fn,
                            tape_ptr,
                            index_ptr,
                            state_ptr_alloca,
                            step_counter,
                            &transition.steps,
                            &transition.final_state,
                            &state_to_int,
                            main_loop,
                        );
                    }
                }
            }

            if !symbol_cases.is_empty() {
                let symbol_switch_block = context.append_basic_block(main_fn, &format!("state_{}_symbol_switch", state_int));
                builder.position_at_end(state_block);
                builder.build_unconditional_branch(symbol_switch_block);

                builder.position_at_end(symbol_switch_block);

                let default_symbol_block = default_block.unwrap_or_else(|| {
                    // If there's no default transition, branch back to main_loop
                    builder.position_at_end(state_block);
                    builder.build_unconditional_branch(main_loop);
                    main_loop
                });

                builder.build_switch(
                    symbol_int,
                    default_symbol_block,
                    &symbol_cases
                        .iter()
                        .map(|(val, block)| (*val, *block))
                        .collect::<Vec<_>>(),
                );
            } else if let Some(default_block) = default_block {
                // If there are no symbol cases but there is a default (wildcard) transition
                builder.build_unconditional_branch(default_block);
            } else {
                // No transitions for this state, branch back to main_loop
                builder.build_unconditional_branch(main_loop);
            }
        }

        // For states without any transitions (i.e., not in state_transitions)
        for (&state_int, _) in state_blocks.iter().filter(|(&state_int, _)| !state_transitions.contains_key(&state_int)) {
            let state_block = state_blocks[&state_int];
            builder.position_at_end(state_block);
            builder.build_unconditional_branch(main_loop);
        }

        // Default state block
        builder.position_at_end(default_state_block);
        builder.build_unconditional_branch(main_loop);

        // Main loop end
        builder.position_at_end(main_loop_end);
        builder.build_return(Some(&i32_type.const_int(0, false)));

        // Generate LLVM IR as a string
        module.print_to_string().to_string()
    }
}

impl ParseTree {
    fn perform_transition_steps(
        &self,
        builder: &inkwell::builder::Builder,
        context: &inkwell::context::Context,
        i32_type: &inkwell::types::IntType,
        i8_type: &inkwell::types::IntType,
        printf_fn: &FunctionValue,
        tape_ptr: PointerValue,
        index_ptr: PointerValue,
        state_ptr_alloca: PointerValue,
        step_counter: PointerValue,
        steps: &Vec<TransitionStep>,
        final_state: &String,
        state_to_int: &HashMap<String, u64>,
        main_loop: BasicBlock,
    ) {
        let i32_type = context.i32_type();
        // Load current index value
        let current_index = builder.build_load(i32_type, index_ptr, "current_index").unwrap().into_int_value();

        for step in steps {
            match step {
                TransitionStep::R => {
                    // Move tape head right
                    let new_index = builder.build_int_add(current_index, i32_type.const_int(1, false), "new_index").unwrap();
                    builder.build_store(index_ptr, new_index);
                }
                TransitionStep::L => {
                    // Move tape head left
                    let new_index = builder.build_int_sub(current_index, i32_type.const_int(1, false), "new_index").unwrap();
                    builder.build_store(index_ptr, new_index);
                }
                TransitionStep::X => {
                    // Do nothing (stay in place)
                }
                TransitionStep::P(symbol) => {
                    // Print symbol
                    let print_format = builder.build_global_string_ptr("Symbol: %c\n", "print_format").unwrap();
                    builder.build_call(
                        *printf_fn,
                        &[
                            print_format.as_pointer_value().into(),
                            i8_type.const_int(symbol.as_bytes()[0] as u64, false).into(),
                        ],
                        "printf",
                    );
                }
            }
        }

        // Update state
        let new_state_int = i32_type.const_int(state_to_int[final_state], false);
        builder.build_store(state_ptr_alloca, new_state_int);

        // Increment step counter
        let current_step = builder.build_load(i32_type, step_counter, "current_step").unwrap().into_int_value();
        let next_step = builder.build_int_add(current_step, i32_type.const_int(1, false), "next_step").unwrap();
        builder.build_store(step_counter, next_step);

        // Continue loop
        builder.build_unconditional_branch(main_loop);
    }
}
