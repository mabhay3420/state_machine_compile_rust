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

main_loop:                                        ; preds = %default_state, %transition_4_4, %transition_4_default, %state_p, %state_p, %transition_3_4, %transition_3_3, %transition_3_0, %state_o, %state_o, %transition_1_1, %transition_1_2, %state_q, %state_q, %transition_2_4, %transition_2_2, %transition_2_1, %transition_0_default, %init_loop_end
  %current_step = load i32, ptr %step_counter, align 4
  %continue_loop = icmp ult i32 %current_step, %num_steps1
  br i1 %continue_loop, label %main_loop_body, label %main_loop_end

main_loop_body:                                   ; preds = %main_loop
  %current_state = load i32, ptr %state_ptr, align 4
  %current_index = load i32, ptr %index, align 4
  %current_symbol_ptr = getelementptr i8, ptr %tape_malloc, i32 %current_index
  %current_symbol = load i8, ptr %current_symbol_ptr, align 1
  %symbol_int = alloca i32, align 4
  br label %symbol_switch

main_loop_end:                                    ; preds = %main_loop
  ret i32 0

symbol_switch:                                    ; preds = %main_loop_body
  switch i8 %current_symbol, label %symbol_default [
    i8 49, label %symbol_case_2
    i8 88, label %symbol_case_4
    i8 120, label %symbol_case_0
    i8 101, label %symbol_case_3
    i8 48, label %symbol_case_1
  ]

after_symbol_switch:                              ; preds = %symbol_default, %symbol_case_1, %symbol_case_3, %symbol_case_0, %symbol_case_4, %symbol_case_2
  %symbol_int5 = load i32, ptr %symbol_int, align 4
  switch i32 %current_state, label %default_state [
    i32 0, label %state_b
    i32 3, label %state_p
    i32 1, label %state_o
    i32 2, label %state_q
    i32 4, label %state_f
  ]

symbol_case_2:                                    ; preds = %symbol_switch
  store i32 2, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_4:                                    ; preds = %symbol_switch
  store i32 4, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_0:                                    ; preds = %symbol_switch
  store i32 0, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_3:                                    ; preds = %symbol_switch
  store i32 3, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_1:                                    ; preds = %symbol_switch
  store i32 1, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_default:                                   ; preds = %symbol_switch
  store i32 -1, ptr %symbol_int, align 4
  br label %after_symbol_switch

state_b:                                          ; preds = %after_symbol_switch

state_p:                                          ; preds = %after_symbol_switch
  br label %state_3_symbol_switch
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 0, label %transition_3_0
    i32 3, label %transition_3_3
    i32 4, label %transition_3_4
  ]

state_o:                                          ; preds = %after_symbol_switch
  br label %state_1_symbol_switch
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 2, label %transition_1_2
    i32 1, label %transition_1_1
  ]

state_q:                                          ; preds = %after_symbol_switch
  br label %state_2_symbol_switch
  br label %main_loop
  switch i32 %symbol_int5, label %main_loop [
    i32 1, label %transition_2_1
    i32 2, label %transition_2_2
    i32 4, label %transition_2_4
  ]

state_f:                                          ; preds = %after_symbol_switch
  br label %state_4_symbol_switch

default_state:                                    ; preds = %after_symbol_switch
  br label %main_loop

transition_0_default:                             ; preds = %transition_0_default
  %current_index6 = load i32, ptr %index, align 4
  %printf7 = call i32 (ptr, ...) @printf(ptr @print_format, i8 101)
  %new_index = add i32 %current_index6, 1
  store i32 %new_index, ptr %index, align 4
  %printf8 = call i32 (ptr, ...) @printf(ptr @print_format.1, i8 101)
  %new_index9 = add i32 %current_index6, 1
  store i32 %new_index9, ptr %index, align 4
  %printf10 = call i32 (ptr, ...) @printf(ptr @print_format.2, i8 48)
  %new_index11 = add i32 %current_index6, 1
  store i32 %new_index11, ptr %index, align 4
  %new_index12 = add i32 %current_index6, 1
  store i32 %new_index12, ptr %index, align 4
  %printf13 = call i32 (ptr, ...) @printf(ptr @print_format.3, i8 48)
  %new_index14 = sub i32 %current_index6, 1
  store i32 %new_index14, ptr %index, align 4
  %new_index15 = sub i32 %current_index6, 1
  store i32 %new_index15, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step16 = load i32, ptr %step_counter, align 4
  %next_step = add i32 %current_step16, 1
  store i32 %next_step, ptr %step_counter, align 4
  br label %main_loop
  br label %transition_0_default

transition_2_1:                                   ; preds = %state_q
  %current_index17 = load i32, ptr %index, align 4
  %new_index18 = add i32 %current_index17, 1
  store i32 %new_index18, ptr %index, align 4
  %new_index19 = add i32 %current_index17, 1
  store i32 %new_index19, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step20 = load i32, ptr %step_counter, align 4
  %next_step21 = add i32 %current_step20, 1
  store i32 %next_step21, ptr %step_counter, align 4
  br label %main_loop

transition_2_2:                                   ; preds = %state_q
  %current_index22 = load i32, ptr %index, align 4
  %new_index23 = add i32 %current_index22, 1
  store i32 %new_index23, ptr %index, align 4
  %new_index24 = add i32 %current_index22, 1
  store i32 %new_index24, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step25 = load i32, ptr %step_counter, align 4
  %next_step26 = add i32 %current_step25, 1
  store i32 %next_step26, ptr %step_counter, align 4
  br label %main_loop

transition_2_4:                                   ; preds = %state_q
  %current_index27 = load i32, ptr %index, align 4
  %printf28 = call i32 (ptr, ...) @printf(ptr @print_format.4, i8 49)
  %new_index29 = sub i32 %current_index27, 1
  store i32 %new_index29, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step30 = load i32, ptr %step_counter, align 4
  %next_step31 = add i32 %current_step30, 1
  store i32 %next_step31, ptr %step_counter, align 4
  br label %main_loop

state_2_symbol_switch:                            ; preds = %state_q

transition_1_2:                                   ; preds = %state_o
  %current_index32 = load i32, ptr %index, align 4
  %new_index33 = add i32 %current_index32, 1
  store i32 %new_index33, ptr %index, align 4
  %printf34 = call i32 (ptr, ...) @printf(ptr @print_format.5, i8 120)
  %new_index35 = sub i32 %current_index32, 1
  store i32 %new_index35, ptr %index, align 4
  %new_index36 = sub i32 %current_index32, 1
  store i32 %new_index36, ptr %index, align 4
  %new_index37 = sub i32 %current_index32, 1
  store i32 %new_index37, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step38 = load i32, ptr %step_counter, align 4
  %next_step39 = add i32 %current_step38, 1
  store i32 %next_step39, ptr %step_counter, align 4
  br label %main_loop

transition_1_1:                                   ; preds = %state_o
  %current_index40 = load i32, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step41 = load i32, ptr %step_counter, align 4
  %next_step42 = add i32 %current_step41, 1
  store i32 %next_step42, ptr %step_counter, align 4
  br label %main_loop

state_1_symbol_switch:                            ; preds = %state_o

transition_3_0:                                   ; preds = %state_p
  %current_index43 = load i32, ptr %index, align 4
  %printf44 = call i32 (ptr, ...) @printf(ptr @print_format.6, i8 88)
  %new_index45 = add i32 %current_index43, 1
  store i32 %new_index45, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step46 = load i32, ptr %step_counter, align 4
  %next_step47 = add i32 %current_step46, 1
  store i32 %next_step47, ptr %step_counter, align 4
  br label %main_loop

transition_3_3:                                   ; preds = %state_p
  %current_index48 = load i32, ptr %index, align 4
  %new_index49 = add i32 %current_index48, 1
  store i32 %new_index49, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step50 = load i32, ptr %step_counter, align 4
  %next_step51 = add i32 %current_step50, 1
  store i32 %next_step51, ptr %step_counter, align 4
  br label %main_loop

transition_3_4:                                   ; preds = %state_p
  %current_index52 = load i32, ptr %index, align 4
  %new_index53 = sub i32 %current_index52, 1
  store i32 %new_index53, ptr %index, align 4
  %new_index54 = sub i32 %current_index52, 1
  store i32 %new_index54, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step55 = load i32, ptr %step_counter, align 4
  %next_step56 = add i32 %current_step55, 1
  store i32 %next_step56, ptr %step_counter, align 4
  br label %main_loop

state_3_symbol_switch:                            ; preds = %state_p

transition_4_default:                             ; preds = %state_4_symbol_switch
  %current_index57 = load i32, ptr %index, align 4
  %new_index58 = add i32 %current_index57, 1
  store i32 %new_index58, ptr %index, align 4
  %new_index59 = add i32 %current_index57, 1
  store i32 %new_index59, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step60 = load i32, ptr %step_counter, align 4
  %next_step61 = add i32 %current_step60, 1
  store i32 %next_step61, ptr %step_counter, align 4
  br label %main_loop

transition_4_4:                                   ; preds = %state_4_symbol_switch
  %current_index62 = load i32, ptr %index, align 4
  %printf63 = call i32 (ptr, ...) @printf(ptr @print_format.7, i8 48)
  %new_index64 = sub i32 %current_index62, 1
  store i32 %new_index64, ptr %index, align 4
  %new_index65 = sub i32 %current_index62, 1
  store i32 %new_index65, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step66 = load i32, ptr %step_counter, align 4
  %next_step67 = add i32 %current_step66, 1
  store i32 %next_step67, ptr %step_counter, align 4
  br label %main_loop

state_4_symbol_switch:                            ; preds = %state_f
  switch i32 %symbol_int5, label %transition_4_default [
    i32 4, label %transition_4_4
  ]
}
