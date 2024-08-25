use std::collections::HashMap;

use crate::parser::{Condition, ParseTree, TransitionStep};
use inkwell::basic_block::BasicBlock;
use inkwell::context::Context;
use inkwell::targets::TargetTriple;
use inkwell::AddressSpace;
use inkwell::IntPredicate;

// Trait for converting to LLVM value
pub trait ToLlvmValue {
    fn to_llvm_value(&self) -> String;
}

// Trait for converting to LLVM IR
pub trait ToLlvmIr {
    unsafe fn to_llvm_ir(&self) -> String;
}

impl ToLlvmIr for ParseTree {
    unsafe fn to_llvm_ir(&self) -> String {
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
        let ptr_type = context.ptr_type(AddressSpace::default());

        // Declare external functions (printf, malloc, scanf, strcmp)
        let printf_type = i32_type.fn_type(&[ptr_type.into()], true);
        let printf_fn = module.add_function("printf", printf_type, None);

        let malloc_type = ptr_type.fn_type(&[i32_type.into()], false);
        let malloc_fn = module.add_function("malloc", malloc_type, None);

        let scanf_type = i32_type.fn_type(&[ptr_type.into(), ptr_type.into()], true);
        let scanf_fn = module.add_function("scanf", scanf_type, None);

        let string_eq_type = i32_type.fn_type(&[ptr_type.into(), ptr_type.into()], false);
        let string_eq_fn = module.add_function("strcmp", string_eq_type, None);

        // Declare get_unique_case_value function
        let get_unique_case_value_type =
            i32_type.fn_type(&[ptr_type.into(), i8_type.into()], false);
        let get_unique_case_value_fn =
            module.add_function("get_unique_case_value", get_unique_case_value_type, None);

        // Define the dummy function
        let get_unique_case_value_block =
            context.append_basic_block(get_unique_case_value_fn, "entry");
        builder.position_at_end(get_unique_case_value_block);

        // For simplicity, we'll just return a constant value
        let dummy_result = i32_type.const_int(42, false);
        builder.build_return(Some(&dummy_result));

        // Define main function
        let main_type = i32_type.fn_type(&[], false);
        let main_fn = module.add_function("main", main_type, None);
        let entry = context.append_basic_block(main_fn, "entry");
        builder.position_at_end(entry);

        // Allocate and initialize variables
        let num_steps_ptr = builder.build_alloca(i32_type, "num_steps").unwrap();
        let arr_size_ptr = builder.build_alloca(i32_type, "arr_size").unwrap();
        let index_ptr = builder.build_alloca(i32_type, "index").unwrap();
        builder
            .build_store(index_ptr, i32_type.const_int(0, false))
            .unwrap();

        // Prompt user for input (number of steps)
        let num_steps_prompt = builder
            .build_global_string_ptr("Enter number of steps: ", "num_steps_prompt")
            .unwrap();
        let scanf_format = builder
            .build_global_string_ptr("%d", "scanf_format")
            .unwrap();
        builder
            .build_call(
                printf_fn,
                &[num_steps_prompt.as_pointer_value().into()],
                "printf",
            )
            .unwrap();
        builder
            .build_call(
                scanf_fn,
                &[scanf_format.as_pointer_value().into(), num_steps_ptr.into()],
                "scanf",
            )
            .unwrap();

        // Load num_steps value
        let num_steps = builder
            .build_load(i32_type, num_steps_ptr, "num_steps")
            .unwrap()
            .into_int_value();

        // Prompt user for input (array size)
        let arr_size_prompt = builder
            .build_global_string_ptr("Enter array size: ", "arr_size_prompt")
            .unwrap();
        let scanf_format = builder
            .build_global_string_ptr("%d", "scanf_format")
            .unwrap();
        builder
            .build_call(
                printf_fn,
                &[arr_size_prompt.as_pointer_value().into()],
                "printf",
            )
            .unwrap();
        builder
            .build_call(
                scanf_fn,
                &[scanf_format.as_pointer_value().into(), arr_size_ptr.into()],
                "scanf",
            )
            .unwrap();

        // Allocate tape dynamically using malloc
        let arr_size = builder
            .build_load(i32_type, arr_size_ptr, "arr_size")
            .unwrap()
            .into_int_value();
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
        builder
            .build_store(i, i32_type.const_int(0, false))
            .unwrap();
        builder.build_unconditional_branch(init_loop);

        // Loop condition
        builder.position_at_end(init_loop);
        let i_val = builder
            .build_load(i32_type, i, "i_val")
            .unwrap()
            .into_int_value();
        let cond = builder
            .build_int_compare(IntPredicate::ULT, i_val, arr_size, "init_cond")
            .unwrap();
        builder.build_conditional_branch(cond, init_loop_body, init_loop_end);

        // Loop body: initialize tape with 'X'
        builder.position_at_end(init_loop_body);
        let element_ptr = unsafe {
            builder
                .build_gep(i8_type, tape_ptr, &[i_val], "element_ptr")
                .unwrap()
        };
        builder
            .build_store(element_ptr, i8_type.const_int('X' as u64, false))
            .unwrap();
        let next_i = builder
            .build_int_add(i_val, i32_type.const_int(1, false), "next_i")
            .unwrap();
        builder.build_store(i, next_i).unwrap();
        builder.build_unconditional_branch(init_loop);

        builder.position_at_end(init_loop_end);

        // Initialize state
        let initial_state = self.transitions[0].initial_state.clone();
        let state_ptr = builder
            .build_global_string_ptr(&initial_state, "initial_state")
            .unwrap();
        let state_ptr_alloca = builder.build_alloca(ptr_type, "state_ptr").unwrap();
        builder
            .build_store(state_ptr_alloca, state_ptr.as_pointer_value())
            .unwrap();

        // Initialize step counter
        let step_counter = builder.build_alloca(i32_type, "step_counter").unwrap();
        builder
            .build_store(step_counter, i32_type.const_int(0, false))
            .unwrap();

        // Main loop
        let main_loop = context.append_basic_block(main_fn, "main_loop");
        let main_loop_end = context.append_basic_block(main_fn, "main_loop_end");

        builder.build_unconditional_branch(main_loop);

        builder.position_at_end(main_loop);

        // Check if we've reached the maximum number of steps
        let current_step = builder
            .build_load(i32_type, step_counter, "current_step")
            .unwrap()
            .into_int_value();
        let continue_loop = builder
            .build_int_compare(IntPredicate::ULT, current_step, num_steps, "continue_loop")
            .unwrap();
        builder.build_conditional_branch(continue_loop, main_loop, main_loop_end);

        // Calculate case_value
        let current_state = builder
            .build_load(ptr_type, state_ptr_alloca, "current_state")
            .unwrap();
        let current_index = builder
            .build_load(i32_type, index_ptr, "current_index")
            .unwrap()
            .into_int_value();
        let current_symbol_ptr = unsafe {
            builder
                .build_gep(i8_type, tape_ptr, &[current_index], "current_symbol_ptr")
                .unwrap()
        };
        let current_symbol = builder
            .build_load(i8_type, current_symbol_ptr, "current_symbol")
            .unwrap();

        let case_value = builder
            .build_call(
                get_unique_case_value_fn,
                &[current_state.into(), current_symbol.into()],
                "case_value",
            )
            .unwrap()
            .try_as_basic_value()
            .left()
            .unwrap()
            .into_int_value();

        // Prepare state and symbol mappings
        let mut state_symbol_to_int: HashMap<(String, String), u64> = HashMap::new();
        let mut unique_value = 0;
        for state in &self.states {
            for symbol in &self.symbols {
                state_symbol_to_int.insert((state.clone(), symbol.clone()), unique_value);
                unique_value += 1;
            }
            state_symbol_to_int.insert((state.clone(), "*".to_string()), unique_value);
            unique_value += 1;
        }

        // Implement transition logic
        // Generate basic blocks for transitions
        let mut transition_blocks: HashMap<u64, BasicBlock> = HashMap::new();

        for transition in &self.transitions {
            let mut temp_blocks = Vec::new();
            match &transition.condition {
                Condition::OR(symbols) => {
                    for symbol in symbols {
                        let case_value = state_symbol_to_int
                            [&(transition.initial_state.clone(), symbol.clone())];
                        let block = context
                            .append_basic_block(main_fn, &format!("transition_{}", case_value));
                        transition_blocks.insert(case_value, block);
                        temp_blocks.push((case_value, block));
                    }
                }
                Condition::Star => {
                    let case_value =
                        state_symbol_to_int[&(transition.initial_state.clone(), "*".to_string())];
                    let block =
                        context.append_basic_block(main_fn, &format!("transition_{}", case_value));
                    transition_blocks.insert(case_value, block);
                    temp_blocks.push((case_value, block));
                }
            }

            // Add instructions for each block in this transition
            for (case_value, block) in temp_blocks {
                builder.position_at_end(block);

                // Perform transition steps
                for step in &transition.steps {
                    match step {
                        TransitionStep::R => {
                            // Move tape head right
                            let new_index = builder
                                .build_int_add(
                                    current_index,
                                    i32_type.const_int(1, false),
                                    "new_index",
                                )
                                .unwrap();
                            builder.build_store(index_ptr, new_index).unwrap();
                        }
                        TransitionStep::L => {
                            // Move tape head left
                            let new_index = builder
                                .build_int_sub(
                                    current_index,
                                    i32_type.const_int(1, false),
                                    "new_index",
                                )
                                .unwrap();
                            builder.build_store(index_ptr, new_index).unwrap();
                        }
                        TransitionStep::X => {
                            // Do nothing (stay in place)
                        }
                        TransitionStep::P(symbol) => {
                            // Print symbol
                            let print_format = builder
                                .build_global_string_ptr("Symbol: %c\n", "print_format")
                                .unwrap();
                            builder
                                .build_call(
                                    printf_fn,
                                    &[
                                        print_format.as_pointer_value().into(),
                                        i8_type
                                            .const_int(symbol.chars().next().unwrap() as u64, false)
                                            .into(),
                                    ],
                                    "printf",
                                )
                                .unwrap();
                        }
                    }
                }

                // Update state
                let new_state = builder
                    .build_global_string_ptr(
                        &transition.final_state,
                        &format!("new_state_{}", transition.final_state),
                    )
                    .unwrap();
                builder
                    .build_store(state_ptr_alloca, new_state.as_pointer_value())
                    .unwrap();

                // Increment step counter
                let next_step = builder
                    .build_int_add(current_step, i32_type.const_int(1, false), "next_step")
                    .unwrap();
                builder.build_store(step_counter, next_step).unwrap();

                // Continue loop
                builder.build_unconditional_branch(main_loop);
            }
        }

        // Create switch
        let switch_block = context.append_basic_block(main_fn, "switch");
        builder.build_unconditional_branch(switch_block);
        builder.position_at_end(switch_block);

        let mut switch_cases = Vec::new();
        for (&case_value, &block) in &transition_blocks {
            switch_cases.push((i32_type.const_int(case_value, false), block));
        }

        let default_block = context.append_basic_block(main_fn, "default");
        builder.build_switch(case_value, default_block, &switch_cases);

        // Default case: continue to next iteration
        builder.position_at_end(default_block);
        builder.build_unconditional_branch(main_loop);

        // Main loop end
        builder.position_at_end(main_loop_end);

        // Return 0
        builder.build_return(Some(&i32_type.const_int(0, false)));

        // Generate LLVM IR as a string
        module.print_to_string().to_string()
    }
}
