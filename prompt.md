we are writing a state machine compiler in rust.
we start from a user input like this:
```
STATES: [b], o, q, p, f

SYMBOLS: 0, 1, e, x

TRANSITIONS:
b, *, P(e)-R-P(e)-R-P(0)-R-R-P(0)-L-L, o
o, 1, R-P(x)-L-L-L, o
o, 0, X, q
q, 0 | 1, R-R, q
q, X, P(1)-L, p
p, x, P(X)-R, q
p, e, R, f
p, X, L-L, p
f, *, R-R, f
f, X, P(0)-L-L, o
```

and parse it into following structure:

```
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

#[derive(Debug, PartialEq, Clone)]
pub struct Transition {
    pub initial_state: String,
    pub condition: Condition,
    pub steps: Vec<TransitionStep>,
    pub final_state: String,
}

#[derive(Debug, PartialEq, Clone)]
pub struct ParseTree {
    pub states: Vec<String>,
    pub initial_state: String,
    pub symbols: Vec<String>,
    pub transitions: Vec<Transition>,
}
```

Then we are converting this to llvm ir by using llvm rust bindings.

Current state of the program:
```
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
        // let ptr_type = context.ptr_type(AddressSpace::default());
        let ptr_type = context.ptr_type(AddressSpace::default())

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
```

This will generate following ir:

```
; ModuleID = 'tape_machine'
source_filename = "tape_machine"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@scanf_format.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@initial_state = private unnamed_addr constant [2 x i8] c"b\00", align 1
@print_format = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.2 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.3 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.4 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_o = private unnamed_addr constant [2 x i8] c"o\00", align 1
@print_format.5 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_o.6 = private unnamed_addr constant [2 x i8] c"o\00", align 1
@new_state_q = private unnamed_addr constant [2 x i8] c"q\00", align 1
@new_state_q.7 = private unnamed_addr constant [2 x i8] c"q\00", align 1
@new_state_q.8 = private unnamed_addr constant [2 x i8] c"q\00", align 1
@print_format.9 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_p = private unnamed_addr constant [2 x i8] c"p\00", align 1
@print_format.10 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_q.11 = private unnamed_addr constant [2 x i8] c"q\00", align 1
@new_state_f = private unnamed_addr constant [2 x i8] c"f\00", align 1
@new_state_p.12 = private unnamed_addr constant [2 x i8] c"p\00", align 1
@new_state_f.13 = private unnamed_addr constant [2 x i8] c"f\00", align 1
@print_format.14 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_o.15 = private unnamed_addr constant [2 x i8] c"o\00", align 1

declare i32 @printf(ptr, ...)

declare ptr @malloc(i32)

declare i32 @scanf(ptr, ptr, ...)

declare i32 @strcmp(ptr, ptr)

define i32 @get_unique_case_value(ptr %0, i8 %1) {
entry:
  ret i32 42
}

define i32 @main() {
entry:
  %num_steps = alloca i32, align 4
  %arr_size = alloca i32, align 4
  %index = alloca i32, align 4
  store i32 0, ptr %index, align 4
  %printf = call i32 (ptr, ...) @printf(ptr @num_steps_prompt)
  %scanf = call i32 (ptr, ptr, ...) @scanf(ptr @scanf_format, ptr %num_steps)
  %num_steps1 = load i32, ptr %num_steps, align 4
  %printf2 = call i32 (ptr, ...) @printf(ptr @arr_size_prompt)
  %scanf3 = call i32 (ptr, ptr, ...) @scanf(ptr @scanf_format.1, ptr %arr_size)
  %arr_size4 = load i32, ptr %arr_size, align 4
  %tape_malloc = call ptr @malloc(i32 %arr_size4)
  %i = alloca i32, align 4
  store i32 0, ptr %i, align 4
  br label %init_loop

init_loop:                                        ; preds = %init_loop_body, %entry
  %i_val = load i32, ptr %i, align 4
  %init_cond = icmp ult i32 %i_val, %arr_size4
  br i1 %init_cond, label %init_loop_body, label %init_loop_end

init_loop_body:                                   ; preds = %init_loop
  %element_ptr = getelementptr i8, ptr %tape_malloc, i32 %i_val
  store i8 88, ptr %element_ptr, align 1
  %next_i = add i32 %i_val, 1
  store i32 %next_i, ptr %i, align 4
  br label %init_loop

init_loop_end:                                    ; preds = %init_loop
  %state_ptr = alloca ptr, align 8
  store ptr @initial_state, ptr %state_ptr, align 8
  %step_counter = alloca i32, align 4
  store i32 0, ptr %step_counter, align 4
  br label %main_loop

main_loop:                                        ; preds = %default, %transition_28, %transition_29, %transition_22, %transition_20, %transition_21, %transition_16, %transition_13, %transition_12, %transition_6, %transition_7, %transition_5, %main_loop, %init_loop_end
  %current_step = load i32, ptr %step_counter, align 4
  %continue_loop = icmp ult i32 %current_step, %num_steps1
  br i1 %continue_loop, label %main_loop, label %main_loop_end
  %current_state = load ptr, ptr %state_ptr, align 8
  %current_index = load i32, ptr %index, align 4
  %current_symbol_ptr = getelementptr i8, ptr %tape_malloc, i32 %current_index
  %current_symbol = load i8, ptr %current_symbol_ptr, align 1
  %case_value = call i32 @get_unique_case_value(ptr %current_state, i8 %current_symbol)

main_loop_end:                                    ; preds = %main_loop
  ret i32 0

transition_5:                                     ; preds = %switch
  %printf5 = call i32 (ptr, ...) @printf(ptr @print_format, i8 101)
  %new_index = add i32 %current_index, 1
  store i32 %new_index, ptr %index, align 4
  %printf6 = call i32 (ptr, ...) @printf(ptr @print_format.2, i8 101)
  %new_index7 = add i32 %current_index, 1
  store i32 %new_index7, ptr %index, align 4
  %printf8 = call i32 (ptr, ...) @printf(ptr @print_format.3, i8 48)
  %new_index9 = add i32 %current_index, 1
  store i32 %new_index9, ptr %index, align 4
  %new_index10 = add i32 %current_index, 1
  store i32 %new_index10, ptr %index, align 4
  %printf11 = call i32 (ptr, ...) @printf(ptr @print_format.4, i8 48)
  %new_index12 = sub i32 %current_index, 1
  store i32 %new_index12, ptr %index, align 4
  %new_index13 = sub i32 %current_index, 1
  store i32 %new_index13, ptr %index, align 4
  store ptr @new_state_o, ptr %state_ptr, align 8
  %next_step = add i32 %current_step, 1
  store i32 %next_step, ptr %step_counter, align 4
  br label %main_loop

transition_7:                                     ; preds = %switch
  %new_index14 = add i32 %current_index, 1
  store i32 %new_index14, ptr %index, align 4
  %printf15 = call i32 (ptr, ...) @printf(ptr @print_format.5, i8 120)
  %new_index16 = sub i32 %current_index, 1
  store i32 %new_index16, ptr %index, align 4
  %new_index17 = sub i32 %current_index, 1
  store i32 %new_index17, ptr %index, align 4
  %new_index18 = sub i32 %current_index, 1
  store i32 %new_index18, ptr %index, align 4
  store ptr @new_state_o.6, ptr %state_ptr, align 8
  %next_step19 = add i32 %current_step, 1
  store i32 %next_step19, ptr %step_counter, align 4
  br label %main_loop

transition_6:                                     ; preds = %switch
  store ptr @new_state_q, ptr %state_ptr, align 8
  %next_step20 = add i32 %current_step, 1
  store i32 %next_step20, ptr %step_counter, align 4
  br label %main_loop

transition_12:                                    ; preds = %switch
  %new_index21 = add i32 %current_index, 1
  store i32 %new_index21, ptr %index, align 4
  %new_index22 = add i32 %current_index, 1
  store i32 %new_index22, ptr %index, align 4
  store ptr @new_state_q.7, ptr %state_ptr, align 8
  %next_step23 = add i32 %current_step, 1
  store i32 %next_step23, ptr %step_counter, align 4
  br label %main_loop

transition_13:                                    ; preds = %switch
  %new_index24 = add i32 %current_index, 1
  store i32 %new_index24, ptr %index, align 4
  %new_index25 = add i32 %current_index, 1
  store i32 %new_index25, ptr %index, align 4
  store ptr @new_state_q.8, ptr %state_ptr, align 8
  %next_step26 = add i32 %current_step, 1
  store i32 %next_step26, ptr %step_counter, align 4
  br label %main_loop

transition_16:                                    ; preds = %switch
  %printf27 = call i32 (ptr, ...) @printf(ptr @print_format.9, i8 49)
  %new_index28 = sub i32 %current_index, 1
  store i32 %new_index28, ptr %index, align 4
  store ptr @new_state_p, ptr %state_ptr, align 8
  %next_step29 = add i32 %current_step, 1
  store i32 %next_step29, ptr %step_counter, align 4
  br label %main_loop

transition_21:                                    ; preds = %switch
  %printf30 = call i32 (ptr, ...) @printf(ptr @print_format.10, i8 88)
  %new_index31 = add i32 %current_index, 1
  store i32 %new_index31, ptr %index, align 4
  store ptr @new_state_q.11, ptr %state_ptr, align 8
  %next_step32 = add i32 %current_step, 1
  store i32 %next_step32, ptr %step_counter, align 4
  br label %main_loop

transition_20:                                    ; preds = %switch
  %new_index33 = add i32 %current_index, 1
  store i32 %new_index33, ptr %index, align 4
  store ptr @new_state_f, ptr %state_ptr, align 8
  %next_step34 = add i32 %current_step, 1
  store i32 %next_step34, ptr %step_counter, align 4
  br label %main_loop

transition_22:                                    ; preds = %switch
  %new_index35 = sub i32 %current_index, 1
  store i32 %new_index35, ptr %index, align 4
  %new_index36 = sub i32 %current_index, 1
  store i32 %new_index36, ptr %index, align 4
  store ptr @new_state_p.12, ptr %state_ptr, align 8
  %next_step37 = add i32 %current_step, 1
  store i32 %next_step37, ptr %step_counter, align 4
  br label %main_loop

transition_29:                                    ; preds = %switch
  %new_index38 = add i32 %current_index, 1
  store i32 %new_index38, ptr %index, align 4
  %new_index39 = add i32 %current_index, 1
  store i32 %new_index39, ptr %index, align 4
  store ptr @new_state_f.13, ptr %state_ptr, align 8
  %next_step40 = add i32 %current_step, 1
  store i32 %next_step40, ptr %step_counter, align 4
  br label %main_loop

transition_28:                                    ; preds = %switch
  %printf41 = call i32 (ptr, ...) @printf(ptr @print_format.14, i8 48)
  %new_index42 = sub i32 %current_index, 1
  store i32 %new_index42, ptr %index, align 4
  %new_index43 = sub i32 %current_index, 1
  store i32 %new_index43, ptr %index, align 4
  store ptr @new_state_o.15, ptr %state_ptr, align 8
  %next_step44 = add i32 %current_step, 1
  store i32 %next_step44, ptr %step_counter, align 4
  br label %main_loop
  br label %switch

switch:                                           ; preds = %transition_28
  switch i32 %case_value, label %default [
    i32 6, label %transition_6
    i32 20, label %transition_20
    i32 21, label %transition_21
    i32 16, label %transition_16
    i32 29, label %transition_29
    i32 12, label %transition_12
    i32 22, label %transition_22
    i32 7, label %transition_7
    i32 5, label %transition_5
    i32 13, label %transition_13
    i32 28, label %transition_28
  ]

default:                                          ; preds = %switch
  br label %main_loop
}
```

which is incorrect.


The task is to fix the llvm converter code, which correctly implements the switch logic.
The states and transition logic works with string, but since that is inefficient, we will internally
convert it to numbers ( as is being done in this code) and then use those numbers in appropriate places.

Give me full working code of llvmconverter.rs.
