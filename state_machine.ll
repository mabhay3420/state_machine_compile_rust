; ModuleID = 'tape_machine'
source_filename = "tape_machine"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@print_format = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.1 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.2 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.3 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.4 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.5 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.6 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_format.7 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1

declare i32 @printf(ptr, ...)

declare ptr @malloc(i32)

declare i32 @scanf(ptr, ...)

define i32 @main() {
entry:
  %num_steps = alloca i32, align 4
  %arr_size = alloca i32, align 4
  %index = alloca i32, align 4
  store i32 0, ptr %index, align 4
  %printf = call i32 (ptr, ...) @printf(ptr @num_steps_prompt)
  %scanf = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %num_steps)
  %num_steps1 = load i32, ptr %num_steps, align 4
  %printf2 = call i32 (ptr, ...) @printf(ptr @arr_size_prompt)
  %scanf3 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %arr_size)
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
  %state_ptr = alloca i32, align 4
  store i32 0, ptr %state_ptr, align 4
  %step_counter = alloca i32, align 4
  store i32 0, ptr %step_counter, align 4
  br label %main_loop

main_loop:                                        ; preds = %default_state, %state_o, %state_o, %transition_1_0, %transition_1_2, %transition_0_default, %state_q, %state_q, %transition_2_1, %transition_2_2, %transition_2_0, %transition_4_1, %transition_4_default, %state_p, %state_p, %transition_3_1, %transition_3_3, %transition_3_4, %symbol_default, %symbol_case_2, %symbol_case_0, %symbol_case_3, %symbol_case_4, %symbol_case_1, %init_loop_end
  %current_step = load i32, ptr %step_counter, align 4
  %continue_loop = icmp ult i32 %current_step, %num_steps1
  br i1 %continue_loop, label %main_loop_body, label %main_loop_end
  %symbol_int5 = load i32, ptr %symbol_int, align 4
  switch i32 %current_state, label %default_state [
    i32 0, label %state_b
    i32 1, label %state_o
    i32 2, label %state_q
    i32 4, label %state_f
    i32 3, label %state_p
  ]

main_loop_body:                                   ; preds = %main_loop
  %current_state = load i32, ptr %state_ptr, align 4
  %current_index = load i32, ptr %index, align 4
  %current_symbol_ptr = getelementptr i8, ptr %tape_malloc, i32 %current_index
  %current_symbol = load i8, ptr %current_symbol_ptr, align 1
  %symbol_int = alloca i32, align 4
  switch i8 %current_symbol, label %symbol_default [
    i8 88, label %symbol_case_1
    i8 120, label %symbol_case_4
    i8 101, label %symbol_case_3
    i8 48, label %symbol_case_0
    i8 49, label %symbol_case_2
  ]

main_loop_end:                                    ; preds = %main_loop
  ret i32 0

symbol_case_1:                                    ; preds = %main_loop_body
  store i32 1, ptr %symbol_int, align 4
  br label %main_loop

symbol_case_4:                                    ; preds = %main_loop_body
  store i32 4, ptr %symbol_int, align 4
  br label %main_loop

symbol_case_3:                                    ; preds = %main_loop_body
  store i32 3, ptr %symbol_int, align 4
  br label %main_loop

symbol_case_0:                                    ; preds = %main_loop_body
  store i32 0, ptr %symbol_int, align 4
  br label %main_loop

symbol_case_2:                                    ; preds = %main_loop_body
  store i32 2, ptr %symbol_int, align 4
  br label %main_loop

symbol_default:                                   ; preds = %main_loop_body
  store i32 -1, ptr %symbol_int, align 4
  br label %main_loop

state_b:                                          ; preds = %main_loop
  br label %transition_0_default

state_o:                                          ; preds = %main_loop
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 2, label %transition_1_2
    i32 0, label %transition_1_0
  ]

state_q:                                          ; preds = %main_loop
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 0, label %transition_2_0
    i32 2, label %transition_2_2
    i32 1, label %transition_2_1
  ]

state_f:                                          ; preds = %main_loop
  switch i32 %symbol_int5, label %transition_4_default [
    i32 1, label %transition_4_1
  ]

state_p:                                          ; preds = %main_loop
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 4, label %transition_3_4
    i32 3, label %transition_3_3
    i32 1, label %transition_3_1
  ]

default_state:                                    ; preds = %main_loop
  br label %main_loop

transition_3_4:                                   ; preds = %state_p
  %current_index6 = load i32, ptr %index, align 4
  %printf7 = call i32 (ptr, ...) @printf(ptr @print_format, i8 88)
  %new_index = add i32 %current_index6, 1
  store i32 %new_index, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step8 = load i32, ptr %step_counter, align 4
  %next_step = add i32 %current_step8, 1
  store i32 %next_step, ptr %step_counter, align 4
  br label %main_loop

transition_3_3:                                   ; preds = %state_p
  %current_index9 = load i32, ptr %index, align 4
  %new_index10 = add i32 %current_index9, 1
  store i32 %new_index10, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step11 = load i32, ptr %step_counter, align 4
  %next_step12 = add i32 %current_step11, 1
  store i32 %next_step12, ptr %step_counter, align 4
  br label %main_loop

transition_3_1:                                   ; preds = %state_p
  %current_index13 = load i32, ptr %index, align 4
  %new_index14 = sub i32 %current_index13, 1
  store i32 %new_index14, ptr %index, align 4
  %new_index15 = sub i32 %current_index13, 1
  store i32 %new_index15, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step16 = load i32, ptr %step_counter, align 4
  %next_step17 = add i32 %current_step16, 1
  store i32 %next_step17, ptr %step_counter, align 4
  br label %main_loop

transition_4_default:                             ; preds = %state_f
  %current_index18 = load i32, ptr %index, align 4
  %new_index19 = add i32 %current_index18, 1
  store i32 %new_index19, ptr %index, align 4
  %new_index20 = add i32 %current_index18, 1
  store i32 %new_index20, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step21 = load i32, ptr %step_counter, align 4
  %next_step22 = add i32 %current_step21, 1
  store i32 %next_step22, ptr %step_counter, align 4
  br label %main_loop

transition_4_1:                                   ; preds = %state_f
  %current_index23 = load i32, ptr %index, align 4
  %printf24 = call i32 (ptr, ...) @printf(ptr @print_format.1, i8 48)
  %new_index25 = sub i32 %current_index23, 1
  store i32 %new_index25, ptr %index, align 4
  %new_index26 = sub i32 %current_index23, 1
  store i32 %new_index26, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step27 = load i32, ptr %step_counter, align 4
  %next_step28 = add i32 %current_step27, 1
  store i32 %next_step28, ptr %step_counter, align 4
  br label %main_loop

transition_2_0:                                   ; preds = %state_q
  %current_index29 = load i32, ptr %index, align 4
  %new_index30 = add i32 %current_index29, 1
  store i32 %new_index30, ptr %index, align 4
  %new_index31 = add i32 %current_index29, 1
  store i32 %new_index31, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step32 = load i32, ptr %step_counter, align 4
  %next_step33 = add i32 %current_step32, 1
  store i32 %next_step33, ptr %step_counter, align 4
  br label %main_loop

transition_2_2:                                   ; preds = %state_q
  %current_index34 = load i32, ptr %index, align 4
  %new_index35 = add i32 %current_index34, 1
  store i32 %new_index35, ptr %index, align 4
  %new_index36 = add i32 %current_index34, 1
  store i32 %new_index36, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step37 = load i32, ptr %step_counter, align 4
  %next_step38 = add i32 %current_step37, 1
  store i32 %next_step38, ptr %step_counter, align 4
  br label %main_loop

transition_2_1:                                   ; preds = %state_q
  %current_index39 = load i32, ptr %index, align 4
  %printf40 = call i32 (ptr, ...) @printf(ptr @print_format.2, i8 49)
  %new_index41 = sub i32 %current_index39, 1
  store i32 %new_index41, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step42 = load i32, ptr %step_counter, align 4
  %next_step43 = add i32 %current_step42, 1
  store i32 %next_step43, ptr %step_counter, align 4
  br label %main_loop

transition_0_default:                             ; preds = %state_b
  %current_index44 = load i32, ptr %index, align 4
  %printf45 = call i32 (ptr, ...) @printf(ptr @print_format.3, i8 101)
  %new_index46 = add i32 %current_index44, 1
  store i32 %new_index46, ptr %index, align 4
  %printf47 = call i32 (ptr, ...) @printf(ptr @print_format.4, i8 101)
  %new_index48 = add i32 %current_index44, 1
  store i32 %new_index48, ptr %index, align 4
  %printf49 = call i32 (ptr, ...) @printf(ptr @print_format.5, i8 48)
  %new_index50 = add i32 %current_index44, 1
  store i32 %new_index50, ptr %index, align 4
  %new_index51 = add i32 %current_index44, 1
  store i32 %new_index51, ptr %index, align 4
  %printf52 = call i32 (ptr, ...) @printf(ptr @print_format.6, i8 48)
  %new_index53 = sub i32 %current_index44, 1
  store i32 %new_index53, ptr %index, align 4
  %new_index54 = sub i32 %current_index44, 1
  store i32 %new_index54, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step55 = load i32, ptr %step_counter, align 4
  %next_step56 = add i32 %current_step55, 1
  store i32 %next_step56, ptr %step_counter, align 4
  br label %main_loop

transition_1_2:                                   ; preds = %state_o
  %current_index57 = load i32, ptr %index, align 4
  %new_index58 = add i32 %current_index57, 1
  store i32 %new_index58, ptr %index, align 4
  %printf59 = call i32 (ptr, ...) @printf(ptr @print_format.7, i8 120)
  %new_index60 = sub i32 %current_index57, 1
  store i32 %new_index60, ptr %index, align 4
  %new_index61 = sub i32 %current_index57, 1
  store i32 %new_index61, ptr %index, align 4
  %new_index62 = sub i32 %current_index57, 1
  store i32 %new_index62, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step63 = load i32, ptr %step_counter, align 4
  %next_step64 = add i32 %current_step63, 1
  store i32 %next_step64, ptr %step_counter, align 4
  br label %main_loop

transition_1_0:                                   ; preds = %state_o
  %current_index65 = load i32, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step66 = load i32, ptr %step_counter, align 4
  %next_step67 = add i32 %current_step66, 1
  store i32 %next_step67, ptr %step_counter, align 4
  br label %main_loop
}
