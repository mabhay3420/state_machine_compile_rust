#![allow(unused)]
use std::collections::{HashMap, HashSet};

use crate::parser::{Condition, ParseTree, Transition, TransitionStep};
use inkwell::basic_block::BasicBlock;
use inkwell::context::Context;
use inkwell::targets::TargetTriple;
use inkwell::values::{FunctionValue, PointerValue, BasicValueEnum};
use inkwell::{AddressSpace, IntPredicate};

// Trait for converting to LLVM IR
pub trait ToLlvmIr {
    fn to_llvm_ir(&self) -> String;
}

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
        let entry = context.append_basic_block(main_fn, "entry");
        builder.position_at_end(entry);

        // Allocate and initialize variables
        let num_steps_ptr = builder.build_alloca(i32_type, "num_steps_ptr").unwrap();
        let arr_size_ptr = builder.build_alloca(i32_type, "arr_size_ptr").unwrap();
        let i32_0 = i32_type.const_int(0, false);
        // builder.build_store(index_ptr, i32_0);
        // builder.build_store(index_ptr, i32_type.const_int(0, false));

        // Prompt user for input (number of steps)
        let num_steps_prompt = builder.build_global_string_ptr("Enter number of steps: ", "num_steps_prompt").unwrap();
        let scanf_format = builder.build_global_string_ptr("%d", "scanf_format").unwrap();
        builder.build_call(printf_fn, &[num_steps_prompt.as_pointer_value().into()], "printf_call_1");
        builder.build_call(scanf_fn, &[scanf_format.as_pointer_value().into(), num_steps_ptr.into()], "scanf_call_1");

        // Load num_steps value
        let num_steps = builder.build_load(i32_type, num_steps_ptr, "num_steps").unwrap().into_int_value();
        // let num_steps = builder.build_load(i32_type, num_steps_ptr.as_basic_value_enum().into_pointer_value(), "num_steps").into_int_value();

        // Prompt user for input (array size)
        let arr_size_prompt = builder.build_global_string_ptr("Enter array size: ", "arr_size_prompt").unwrap();
        builder.build_call(printf_fn, &[arr_size_prompt.as_pointer_value().into()], "printf_call_2");
        builder.build_call(scanf_fn, &[scanf_format.as_pointer_value().into(), arr_size_ptr.into()], "scanf_call_2");

        // Allocate tape dynamically using malloc
        let arr_size = builder.build_load(i32_type, arr_size_ptr, "arr_size").unwrap().into_int_value();
        let tape_ptr = 
                    builder.
                        build_call(malloc_fn, &[arr_size.into()], "tape_array_malloc_call")
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
        builder.build_store(index_ptr, i32_0);
        builder.build_store(current_step_ptr, i32_0);
        builder.build_unconditional_branch(steps_loop);

        // Loop condition
        builder.position_at_end(steps_loop);
        let current_step_val = builder.build_load(i32_type, current_step_ptr, "current_step_val").unwrap().into_int_value();
        let step_limit_cond = builder.build_int_compare(IntPredicate::ULT, current_step_val, num_steps, "step_limit_cond").unwrap();
        builder.build_conditional_branch(step_limit_cond, steps_loop_body, steps_loop_end);

        // // Loop body: initialize tape with 'X'
        builder.position_at_end(steps_loop_body);
        let print_steps_format = builder.build_global_string_ptr("Current step: %d\n", "print_current_step_format").unwrap();
        builder.build_call(printf_fn, &[print_steps_format.as_pointer_value().into(), current_step_val.into()], "current_step_print_call");
        let updated_current_step_val =  builder.build_int_add(current_step_val, i32_type.const_int(1, false), "current_step_increment").unwrap();
        builder.build_store(current_step_ptr, updated_current_step_val);
        builder.build_unconditional_branch(steps_loop);


        // Loop end
        builder.position_at_end(steps_loop_end);
        let print_loop_end_format = builder.build_global_string_ptr("Reached end of steps loop.", "step_loop_end_format").unwrap();
        builder.build_call(printf_fn, &[print_loop_end_format.as_pointer_value().into()], "step_loop_end_print");
        builder.build_unconditional_branch(main_return);


        // let element_ptr = unsafe { builder.build_gep(i8_type, tape_ptr, &[i_val], "element_ptr") };
        // builder.build_store(element_ptr, i8_type.const_int('X' as u64, false));
        // let next_i = builder.build_int_add(i_val, i32_type.const_int(1, false), "next_i");
        // builder.build_store(i, next_i);
        // builder.build_unconditional_branch(init_loop);

        // builder.position_at_end(init_loop_end);

        // // Print the final state of the tape array
        // let print_loop = context.append_basic_block(main_fn, "print_loop");
        // let print_loop_body = context.append_basic_block(main_fn, "print_loop_body");
        // let print_loop_end = context.append_basic_block(main_fn, "print_loop_end");

        // // Initialize loop counter for printing
        // builder.build_store(i, i32_type.const_int(0, false));
        // builder.build_unconditional_branch(print_loop);

        // // Loop condition for printing
        // builder.position_at_end(print_loop);
        // let i_val_print = builder.build_load(i32_type, i.as_basic_value_enum().into_pointer_value(), "i_val_print").into_int_value();
        // let print_cond = builder.build_int_compare(IntPredicate::ULT, i_val_print, arr_size, "print_cond");
        // builder.build_conditional_branch(print_cond, print_loop_body, print_loop_end);

        // // Loop body: print tape values
        // builder.position_at_end(print_loop_body);
        // let element_ptr_print = unsafe { builder.build_gep(i8_type, tape_ptr, &[i_val_print], "element_ptr_print") };
        // let element_val = builder.build_load(i8_type, element_ptr_print, "element_val");
        // let print_array_format = builder.build_global_string_ptr("%c ", "print_array_format");
        // builder.build_call(printf_fn, &[print_array_format.as_pointer_value().into(), element_val.into()], "printf");
        // let next_i_print = builder.build_int_add(i_val_print, i32_type.const_int(1, false), "next_i_print");
        // builder.build_store(i, next_i_print);
        // builder.build_unconditional_branch(print_loop);

        // builder.position_at_end(print_loop_end);

        builder.position_at_end(main_return);
        builder.build_return(Some(&i32_type.const_int(0, false)));


        // Generate LLVM IR as a string
        module.print_to_string().to_string()
    }
}
