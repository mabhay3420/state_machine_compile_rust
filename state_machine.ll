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
@print_format.8 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_p = private unnamed_addr constant [2 x i8] c"p\00", align 1
@print_format.9 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_q.10 = private unnamed_addr constant [2 x i8] c"q\00", align 1
@new_state_f = private unnamed_addr constant [2 x i8] c"f\00", align 1
@new_state_p.11 = private unnamed_addr constant [2 x i8] c"p\00", align 1
@new_state_f.12 = private unnamed_addr constant [2 x i8] c"f\00", align 1
@print_format.13 = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@new_state_o.14 = private unnamed_addr constant [2 x i8] c"o\00", align 1

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

main_loop:                                        ; preds = %transition_28, %transition_29, %transition_22, %transition_20, %transition_21, %transition_16, %transition_13, %transition_6, %transition_7, %transition_5, %default, %main_loop, %init_loop_end
  %current_step = load i32, ptr %step_counter, align 4
  %continue_loop = icmp ult i32 %current_step, %num_steps1
  br i1 %continue_loop, label %main_loop, label %main_loop_end
  %current_state = load ptr, ptr %state_ptr, align 8
  %current_index = load i32, ptr %index, align 4
  %current_symbol_ptr = getelementptr i8, ptr %tape_malloc, i32 %current_index
  %current_symbol = load i8, ptr %current_symbol_ptr, align 1
  %case_value = call i32 @get_unique_case_value(ptr %current_state, i8 %current_symbol)
  br label %switch

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

transition_13:                                    ; preds = %switch
  %new_index23 = add i32 %current_index, 1
  store i32 %new_index23, ptr %index, align 4
  %new_index24 = add i32 %current_index, 1
  store i32 %new_index24, ptr %index, align 4
  store ptr @new_state_q.7, ptr %state_ptr, align 8
  %next_step25 = add i32 %current_step, 1
  store i32 %next_step25, ptr %step_counter, align 4
  br label %main_loop

transition_16:                                    ; preds = %switch
  %printf26 = call i32 (ptr, ...) @printf(ptr @print_format.8, i8 49)
  %new_index27 = sub i32 %current_index, 1
  store i32 %new_index27, ptr %index, align 4
  store ptr @new_state_p, ptr %state_ptr, align 8
  %next_step28 = add i32 %current_step, 1
  store i32 %next_step28, ptr %step_counter, align 4
  br label %main_loop

transition_21:                                    ; preds = %switch
  %printf29 = call i32 (ptr, ...) @printf(ptr @print_format.9, i8 88)
  %new_index30 = add i32 %current_index, 1
  store i32 %new_index30, ptr %index, align 4
  store ptr @new_state_q.10, ptr %state_ptr, align 8
  %next_step31 = add i32 %current_step, 1
  store i32 %next_step31, ptr %step_counter, align 4
  br label %main_loop

transition_20:                                    ; preds = %switch
  %new_index32 = add i32 %current_index, 1
  store i32 %new_index32, ptr %index, align 4
  store ptr @new_state_f, ptr %state_ptr, align 8
  %next_step33 = add i32 %current_step, 1
  store i32 %next_step33, ptr %step_counter, align 4
  br label %main_loop

transition_22:                                    ; preds = %switch
  %new_index34 = sub i32 %current_index, 1
  store i32 %new_index34, ptr %index, align 4
  %new_index35 = sub i32 %current_index, 1
  store i32 %new_index35, ptr %index, align 4
  store ptr @new_state_p.11, ptr %state_ptr, align 8
  %next_step36 = add i32 %current_step, 1
  store i32 %next_step36, ptr %step_counter, align 4
  br label %main_loop

transition_29:                                    ; preds = %switch
  %new_index37 = add i32 %current_index, 1
  store i32 %new_index37, ptr %index, align 4
  %new_index38 = add i32 %current_index, 1
  store i32 %new_index38, ptr %index, align 4
  store ptr @new_state_f.12, ptr %state_ptr, align 8
  %next_step39 = add i32 %current_step, 1
  store i32 %next_step39, ptr %step_counter, align 4
  br label %main_loop

transition_28:                                    ; preds = %switch
  %printf40 = call i32 (ptr, ...) @printf(ptr @print_format.13, i8 48)
  %new_index41 = sub i32 %current_index, 1
  store i32 %new_index41, ptr %index, align 4
  %new_index42 = sub i32 %current_index, 1
  store i32 %new_index42, ptr %index, align 4
  store ptr @new_state_o.14, ptr %state_ptr, align 8
  %next_step43 = add i32 %current_step, 1
  store i32 %next_step43, ptr %step_counter, align 4
  br label %main_loop

switch:                                           ; preds = %main_loop
  switch i32 %case_value, label %default [
    i32 6, label %transition_6
    i32 5, label %transition_5
    i32 20, label %transition_20
    i32 13, label %transition_13
    i32 7, label %transition_7
    i32 22, label %transition_22
    i32 29, label %transition_29
    i32 12, label %transition_12
    i32 28, label %transition_28
    i32 16, label %transition_16
    i32 21, label %transition_21
  ]

default:                                          ; preds = %switch
  br label %main_loop
}
