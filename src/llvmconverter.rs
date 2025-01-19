#![allow(unused)]
use std::collections::{HashMap, HashSet};

use crate::parser::{Condition, ParseTree, Transition, TransitionStep};
use inkwell::basic_block::BasicBlock;
use inkwell::context::Context;
use inkwell::targets::TargetTriple;
use inkwell::values::{BasicValue, BasicValueEnum, FunctionValue, PointerValue};
use inkwell::{AddressSpace, IntPredicate};

// Trait for converting to LLVM IR
pub trait ToLlvmIr {
    fn to_llvm_ir(&self) -> String;
}

// TODO - Write this to minimise the work for printing something
// fn print_call(builder: inkwell::builder::Builder, prompt: &str, name: &str, printf_fn: inkwell::values::FunctionValue, print_args: &[inkwell::values::BasicValueEnum], print_call_name: &str) {
//     let print_steps_format = builder.build_global_string_ptr(prompt, name).unwrap();
//     let mut print_all_args = [print_steps_format.as_basic_value_enum()];
//     print_all_args.iter().chain(print_args);
//     builder.build_call(printf_fn, &print_all_args,print_call_name);
// }

impl ToLlvmIr for ParseTree {
    fn to_llvm_ir(&self) -> String {
        // Create LLVM context, module, and builder
        let context = Context::create();
        let module = context.create_module("tape_machine_fixed");
        let builder = context.create_builder();

        // Set target triple for macOS on ARM64
        let triple = TargetTriple::create("arm64-apple-macosx13.0.0");
        module.set_triple(&triple);

        // Define basic LLVM types
        let i32_type = context.i32_type();
        let i8_type = context.i8_type();
        let ptr_type = context.ptr_type(AddressSpace::default());

        // Declare external functions (printf, malloc, scanf)
        let printf_type = i32_type.fn_type(&[ptr_type.into()], true);
        let printf_fn = module.add_function("printf", printf_type, None);

        let malloc_type = ptr_type.fn_type(&[i32_type.into()], false);
        let malloc_fn = module.add_function("malloc", malloc_type, None);

        let scanf_type = i32_type.fn_type(&[ptr_type.into()], true);
        let scanf_fn = module.add_function("scanf", scanf_type, None);

        // Define main function
        let main_type = i32_type.fn_type(&[], false);
        let main_fn = module.add_function("main", main_type, None);

        // Actual instruction building starts from here
        let entry = context.append_basic_block(main_fn, "entry");
        builder.position_at_end(entry);

        // Allocate and initialize variables
        let num_steps_ptr = builder.build_alloca(i32_type, "num_steps_ptr").unwrap();
        let arr_size_ptr = builder.build_alloca(i32_type, "arr_size_ptr").unwrap();
        let i32_0 = i32_type.const_int(0, false);
        // builder.build_store(index_ptr, i32_0);
        // builder.build_store(index_ptr, i32_type.const_int(0, false));

        // Prompt user for input (number of steps)
        let num_steps_prompt = builder
            .build_global_string_ptr("Enter number of steps: ", "num_steps_prompt")
            .unwrap();
        let scanf_format = builder
            .build_global_string_ptr("%d", "scanf_format")
            .unwrap();
        builder.build_call(
            printf_fn,
            &[num_steps_prompt.as_pointer_value().into()],
            "printf_call_1",
        );
        builder.build_call(
            scanf_fn,
            &[scanf_format.as_pointer_value().into(), num_steps_ptr.into()],
            "scanf_call_1",
        );

        // Load num_steps value
        let num_steps = builder
            .build_load(i32_type, num_steps_ptr, "num_steps")
            .unwrap()
            .into_int_value();
        // let num_steps = builder.build_load(i32_type, num_steps_ptr.as_basic_value_enum().into_pointer_value(), "num_steps").into_int_value();

        // Prompt user for input (array size)
        let arr_size_prompt = builder
            .build_global_string_ptr("Enter array size: ", "arr_size_prompt")
            .unwrap();
        builder.build_call(
            printf_fn,
            &[arr_size_prompt.as_pointer_value().into()],
            "printf_call_2",
        );
        builder.build_call(
            scanf_fn,
            &[scanf_format.as_pointer_value().into(), arr_size_ptr.into()],
            "scanf_call_2",
        );

        // Allocate tape dynamically using malloc
        let arr_size = builder
            .build_load(i32_type, arr_size_ptr, "arr_size")
            .unwrap()
            .into_int_value();
        let tape_ptr = builder
            .build_call(malloc_fn, &[arr_size.into()], "tape_array_malloc_call")
            .unwrap()
            .try_as_basic_value()
            .left()
            .unwrap()
            .into_pointer_value();

        // Initialize tape with 'X'
        let steps_loop = context.append_basic_block(main_fn, "steps_loop");
        let steps_loop_body = context.append_basic_block(main_fn, "steps_loop_body");
        let steps_loop_end = context.append_basic_block(main_fn, "steps_loop_end");
        let main_return = context.append_basic_block(main_fn, "main_return");

        // Initialize loop counter
        let index_ptr = builder.build_alloca(i32_type, "index_ptr").unwrap();
        let current_step_ptr = builder.build_alloca(i32_type, "current_step_ptr").unwrap();
        let current_symbol_index_ptr = builder
            .build_alloca(i32_type, "current_symbol_index_ptr")
            .unwrap();
        builder.build_store(index_ptr, i32_0);
        builder.build_store(current_step_ptr, i32_0);

        // TODO - Update it based on what the initial symbol is
        builder.build_store(current_symbol_index_ptr, i32_0);

        let print_steps_format = builder
            .build_global_string_ptr("All Symbols: %s\n", "print_current_step_format")
            .unwrap();

        let symbol_index_value_mapping = self
            .symbols
            .iter()
            .enumerate()
            .map(|(i, s)| format!("{}:{}", i, s))
            .collect::<Vec<String>>()
            .join(", ");

        let symbol_index_value_mapping_ptr = builder.build_global_string_ptr(&symbol_index_value_mapping, "symbol_index_value_mapping").unwrap();
        builder.build_call(printf_fn, &[print_steps_format.as_pointer_value().into(), symbol_index_value_mapping_ptr.as_pointer_value().into()], "print_all_symbols");
        builder.build_unconditional_branch(steps_loop);

        // Loop condition
        builder.position_at_end(steps_loop);
        let current_step_val = builder
            .build_load(i32_type, current_step_ptr, "current_step_val")
            .unwrap()
            .into_int_value();
        let current_symbol_index = builder
            .build_load(
                i32_type,
                current_symbol_index_ptr,
                "current_symbol_index_val",
            )
            .unwrap()
            .into_int_value();
        let step_limit_cond = builder
            .build_int_compare(
                IntPredicate::ULT,
                current_step_val,
                num_steps,
                "step_limit_cond",
            )
            .unwrap();
        builder.build_conditional_branch(step_limit_cond, steps_loop_body, steps_loop_end);

        // // Loop body: initialize tape with 'X'
        builder.position_at_end(steps_loop_body);
        let print_steps_format = builder
            .build_global_string_ptr("Current step: %d\n", "print_current_step_format")
            .unwrap();
        builder.build_call(
            printf_fn,
            &[
                print_steps_format.as_pointer_value().into(),
                current_step_val.into(),
            ],
            "current_step_print_call",
        );

        // Build a switch statement based on current step value
        // let current_step_nature = builder
        //     .build_int_signed_rem(
        //         current_step_val,
        //         i32_type.const_int(4, false),
        //         "is_even_check",
        //     )
        //     .unwrap();
        // Later we will use the current state and current symbol value
        let total_symbols = self.symbols.len();
        let switch_default = context.append_basic_block(main_fn, "switch_default");
        let after_switch = context.append_basic_block(main_fn, "after_switch");
        let mut case_switch_mapping = vec![];
        let print_steps_format = builder
            .build_global_string_ptr("Symbol: %s\n", "print_current_step_format")
            .unwrap();
        for sym_index in 0..total_symbols {
            let symbol = builder
                .build_global_string_ptr(
                    &self.symbols[sym_index],
                    &format!("symbol_{}", self.symbols[sym_index]),
                )
                .unwrap();
            let switch_case = context.append_basic_block(main_fn, &format!("switch_{}", sym_index));
            builder.position_at_end(switch_case);
            builder.build_call(
                printf_fn,
                &[
                    print_steps_format.as_pointer_value().into(),
                    symbol.as_pointer_value().into(),
                ],
                "current_step_print_call",
            );
            builder.build_unconditional_branch(after_switch);
            case_switch_mapping.push((
                i32_type.const_int(sym_index.try_into().unwrap(), false),
                switch_case,
            ));
        }

        // let switch_even_case = context.append_basic_block(main_fn, "switch_0");
        // let switch_odd_case = context.append_basic_block(main_fn, "switch_1");

        builder.position_at_end(switch_default);
        let print_steps_format = builder
            .build_global_string_ptr("Default Remainder: %d\n", "print_current_step_format")
            .unwrap();
        builder.build_call(
            printf_fn,
            &[
                print_steps_format.as_pointer_value().into(),
                current_step_val.into(),
            ],
            "current_step_print_call",
        );
        builder.build_unconditional_branch(after_switch);

        // builder.position_at_end(switch_even_case);
        // let print_steps_format = builder
        //     .build_global_string_ptr("Remainder 0: %d\n", "print_current_step_format")
        //     .unwrap();
        // builder.build_call(
        //     printf_fn,
        //     &[
        //         print_steps_format.as_pointer_value().into(),
        //         current_step_val.into(),
        //     ],
        //     "current_step_print_call",
        // );
        // builder.build_unconditional_branch(after_switch);

        // builder.position_at_end(switch_odd_case);
        // let print_steps_format = builder
        //     .build_global_string_ptr("Remainder 1: %d\n", "print_current_step_format")
        //     .unwrap();
        // builder.build_call(
        //     printf_fn,
        //     &[
        //         print_steps_format.as_pointer_value().into(),
        //         current_step_val.into(),
        //     ],
        //     "current_step_print_call",
        // );
        // builder.build_unconditional_branch(after_switch);

        // Insert swicht statement in steps loop body
        builder.position_at_end(steps_loop_body);
        // print_call(builder, "Switch Default Case", "switch_default_print", printf_fn, , print_call_name);
        builder.build_switch(current_symbol_index, switch_default, &case_switch_mapping);

        builder.position_at_end(after_switch);
        let updated_current_step_val = builder
            .build_int_add(
                current_step_val,
                i32_type.const_int(1, false),
                "current_step_increment",
            )
            .unwrap();
        builder.build_store(current_step_ptr, updated_current_step_val);

        // TODO - Move this to every switch statement block
        // This will be updated based on the associated conditions
        let mut updated_current_symbol_index = builder
            .build_int_add(
                current_symbol_index,
                i32_type.const_int(2, false),
                "current_symbol_index_increment_1",
            )
            .unwrap();

        // TODO - This will be replaced by forcing the flow to go to
        // Invalid block if the current symbol doesn't exist in the
        // available options
        updated_current_symbol_index = builder
            .build_int_signed_rem(
                updated_current_symbol_index,
                i32_type.const_int(total_symbols.try_into().unwrap(), false),
                "clip_symbol_index",
            )
            .unwrap();

        builder.build_store(current_symbol_index_ptr, updated_current_symbol_index);
        builder.build_unconditional_branch(steps_loop);

        // Loop end
        builder.position_at_end(steps_loop_end);
        let print_loop_end_format = builder
            .build_global_string_ptr("Reached end of steps loop.", "step_loop_end_format")
            .unwrap();
        builder.build_call(
            printf_fn,
            &[print_loop_end_format.as_pointer_value().into()],
            "step_loop_end_print",
        );
        builder.build_unconditional_branch(main_return);

        builder.position_at_end(main_return);
        builder.build_return(Some(&i32_type.const_int(0, false)));

        // Generate LLVM IR as a string
        module.print_to_string().to_string()
    }
}
