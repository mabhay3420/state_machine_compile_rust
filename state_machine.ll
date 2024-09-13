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

main_loop:                                        ; preds = %default_state, %transition_4_2, %transition_4_default, %transition_3_2, %transition_3_4, %transition_3_3, %transition_2_2, %transition_2_0, %transition_2_1, %transition_1_1, %transition_1_0, %transition_0_default, %state_4_default, %state_3_default9, %state_3_default8, %state_3_default, %state_2_default7, %state_2_default, %state_1_default6, %state_1_default, %init_loop_end
  %current_step = load i32, ptr %step_counter, align 4
  %continue_loop = icmp ult i32 %current_step, %num_steps1
  br i1 %continue_loop, label %main_loop_body, label %main_loop_end

main_loop_body:                                   ; preds = %main_loop
  %current_state = load i32, ptr %state_ptr, align 4
  %current_index = load i32, ptr %index, align 4
  %current_symbol_ptr = getelementptr i8, ptr %tape_malloc, i32 %current_index
  %current_symbol = load i32, ptr %current_symbol_ptr, align 4
  %symbol_int = alloca i32, align 4
  br label %symbol_switch

main_loop_end:                                    ; preds = %main_loop
  ret i32 0

symbol_switch:                                    ; preds = %main_loop_body
  switch i32 %current_symbol, label %symbol_default [
    i8 120, label %symbol_case_3
    i8 49, label %symbol_case_0
    i8 48, label %symbol_case_1
    i8 88, label %symbol_case_2
    i8 101, label %symbol_case_4
  ]

after_symbol_switch:                              ; preds = %symbol_default, %symbol_case_4, %symbol_case_2, %symbol_case_1, %symbol_case_0, %symbol_case_3
  %symbol_int5 = load i32, ptr %symbol_int, align 4
  switch i32 %current_state, label %default_state [
    i32 4, label %state_f
    i32 2, label %state_q
    i32 3, label %state_p
    i32 1, label %state_o
    i32 0, label %state_b
  ]

symbol_case_3:                                    ; preds = %symbol_switch
  store i32 3, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_0:                                    ; preds = %symbol_switch
  store i32 0, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_1:                                    ; preds = %symbol_switch
  store i32 1, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_2:                                    ; preds = %symbol_switch
  store i32 2, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_case_4:                                    ; preds = %symbol_switch
  store i32 4, ptr %symbol_int, align 4
  br label %after_symbol_switch

symbol_default:                                   ; preds = %symbol_switch
  store i32 -1, ptr %symbol_int, align 4
  br label %after_symbol_switch

state_f:                                          ; preds = %after_symbol_switch
  br label %state_4_symbol_switch

state_q:                                          ; preds = %after_symbol_switch
  br label %state_2_symbol_switch

state_p:                                          ; preds = %after_symbol_switch
  br label %state_3_symbol_switch

state_o:                                          ; preds = %after_symbol_switch
  br label %state_1_symbol_switch

state_b:                                          ; preds = %after_symbol_switch
  br label %state_0_symbol_switch

default_state:                                    ; preds = %after_symbol_switch
  br label %main_loop

state_0_symbol_switch:                            ; preds = %state_b
  switch i32 %symbol_int5, label %transition_0_default [
  ]

transition_0_default:                             ; preds = %state_0_symbol_switch
  %current_index10 = load i32, ptr %index, align 4
  %printf11 = call i32 (ptr, ...) @printf(ptr @print_format, i8 101)
  %new_index = add i32 %current_index10, 1
  store i32 %new_index, ptr %index, align 4
  %printf12 = call i32 (ptr, ...) @printf(ptr @print_format.1, i8 101)
  %new_index13 = add i32 %current_index10, 1
  store i32 %new_index13, ptr %index, align 4
  %printf14 = call i32 (ptr, ...) @printf(ptr @print_format.2, i8 48)
  %new_index15 = add i32 %current_index10, 1
  store i32 %new_index15, ptr %index, align 4
  %new_index16 = add i32 %current_index10, 1
  store i32 %new_index16, ptr %index, align 4
  %printf17 = call i32 (ptr, ...) @printf(ptr @print_format.3, i8 48)
  %new_index18 = sub i32 %current_index10, 1
  store i32 %new_index18, ptr %index, align 4
  %new_index19 = sub i32 %current_index10, 1
  store i32 %new_index19, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step20 = load i32, ptr %step_counter, align 4
  %next_step = add i32 %current_step20, 1
  store i32 %next_step, ptr %step_counter, align 4
  br label %main_loop

;state_1_symbol_switch:                            ; preds = %state_1_default, %state_o

transition_1_0:                                   ; preds = %state_1_default
  %current_index21 = load i32, ptr %index, align 4
  %new_index22 = add i32 %current_index21, 1
  store i32 %new_index22, ptr %index, align 4
  %printf23 = call i32 (ptr, ...) @printf(ptr @print_format.4, i8 120)
  %new_index24 = sub i32 %current_index21, 1
  store i32 %new_index24, ptr %index, align 4
  %new_index25 = sub i32 %current_index21, 1
  store i32 %new_index25, ptr %index, align 4
  %new_index26 = sub i32 %current_index21, 1
  store i32 %new_index26, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step27 = load i32, ptr %step_counter, align 4
  %next_step28 = add i32 %current_step27, 1
  store i32 %next_step28, ptr %step_counter, align 4
  br label %main_loop

state_1_default:                                  ; preds = %state_1_default
  br label %main_loop
  switch i32 %symbol_int5, label %state_1_default [
    i32 0, label %transition_1_0
  ]
  br label %state_1_symbol_switch

transition_1_1:                                   ; preds = %state_1_default6
  %current_index29 = load i32, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step30 = load i32, ptr %step_counter, align 4
  %next_step31 = add i32 %current_step30, 1
  store i32 %next_step31, ptr %step_counter, align 4
  br label %main_loop

state_1_default6:                                 ; preds = %state_1_default6
  br label %main_loop
  switch i32 %symbol_int5, label %state_1_default6 [
    i32 1, label %transition_1_1
  ]

;state_2_symbol_switch:                            ; preds = %state_2_default, %state_q

transition_2_1:                                   ; preds = %state_2_default
  %current_index32 = load i32, ptr %index, align 4
  %new_index33 = add i32 %current_index32, 1
  store i32 %new_index33, ptr %index, align 4
  %new_index34 = add i32 %current_index32, 1
  store i32 %new_index34, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step35 = load i32, ptr %step_counter, align 4
  %next_step36 = add i32 %current_step35, 1
  store i32 %next_step36, ptr %step_counter, align 4
  br label %main_loop

transition_2_0:                                   ; preds = %state_2_default
  %current_index37 = load i32, ptr %index, align 4
  %new_index38 = add i32 %current_index37, 1
  store i32 %new_index38, ptr %index, align 4
  %new_index39 = add i32 %current_index37, 1
  store i32 %new_index39, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step40 = load i32, ptr %step_counter, align 4
  %next_step41 = add i32 %current_step40, 1
  store i32 %next_step41, ptr %step_counter, align 4
  br label %main_loop

state_2_default:                                  ; preds = %state_2_default
  br label %main_loop
  switch i32 %symbol_int5, label %state_2_default [
    i32 1, label %transition_2_1
    i32 0, label %transition_2_0
  ]
  br label %state_2_symbol_switch

transition_2_2:                                   ; preds = %state_2_default7
  %current_index42 = load i32, ptr %index, align 4
  %printf43 = call i32 (ptr, ...) @printf(ptr @print_format.5, i8 49)
  %new_index44 = sub i32 %current_index42, 1
  store i32 %new_index44, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step45 = load i32, ptr %step_counter, align 4
  %next_step46 = add i32 %current_step45, 1
  store i32 %next_step46, ptr %step_counter, align 4
  br label %main_loop

state_2_default7:                                 ; preds = %state_2_default7
  br label %main_loop
  switch i32 %symbol_int5, label %state_2_default7 [
    i32 2, label %transition_2_2
  ]

;state_3_symbol_switch:                            ; preds = %state_3_default8, %state_3_default, %state_p

transition_3_3:                                   ; preds = %state_3_default
  %current_index47 = load i32, ptr %index, align 4
  %printf48 = call i32 (ptr, ...) @printf(ptr @print_format.6, i8 88)
  %new_index49 = add i32 %current_index47, 1
  store i32 %new_index49, ptr %index, align 4
  store i32 2, ptr %state_ptr, align 4
  %current_step50 = load i32, ptr %step_counter, align 4
  %next_step51 = add i32 %current_step50, 1
  store i32 %next_step51, ptr %step_counter, align 4
  br label %main_loop

state_3_default:                                  ; preds = %state_3_default
  br label %main_loop
  switch i32 %symbol_int5, label %state_3_default [
    i32 3, label %transition_3_3
  ]
  br label %state_3_symbol_switch

transition_3_4:                                   ; preds = %state_3_default8
  %current_index52 = load i32, ptr %index, align 4
  %new_index53 = add i32 %current_index52, 1
  store i32 %new_index53, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step54 = load i32, ptr %step_counter, align 4
  %next_step55 = add i32 %current_step54, 1
  store i32 %next_step55, ptr %step_counter, align 4
  br label %main_loop

state_3_default8:                                 ; preds = %state_3_default8
  br label %main_loop
  switch i32 %symbol_int5, label %state_3_default8 [
    i32 4, label %transition_3_4
  ]
  br label %state_3_symbol_switch

transition_3_2:                                   ; preds = %state_3_default9
  %current_index56 = load i32, ptr %index, align 4
  %new_index57 = sub i32 %current_index56, 1
  store i32 %new_index57, ptr %index, align 4
  %new_index58 = sub i32 %current_index56, 1
  store i32 %new_index58, ptr %index, align 4
  store i32 3, ptr %state_ptr, align 4
  %current_step59 = load i32, ptr %step_counter, align 4
  %next_step60 = add i32 %current_step59, 1
  store i32 %next_step60, ptr %step_counter, align 4
  br label %main_loop

state_3_default9:                                 ; preds = %state_3_default9
  br label %main_loop
  switch i32 %symbol_int5, label %state_3_default9 [
    i32 2, label %transition_3_2
  ]

state_4_symbol_switch:                            ; preds = %state_4_symbol_switch, %state_f
  switch i32 %symbol_int5, label %transition_4_default [
  ]
  br label %state_4_symbol_switch

transition_4_default:                             ; preds = %state_4_symbol_switch
  %current_index61 = load i32, ptr %index, align 4
  %new_index62 = add i32 %current_index61, 1
  store i32 %new_index62, ptr %index, align 4
  %new_index63 = add i32 %current_index61, 1
  store i32 %new_index63, ptr %index, align 4
  store i32 4, ptr %state_ptr, align 4
  %current_step64 = load i32, ptr %step_counter, align 4
  %next_step65 = add i32 %current_step64, 1
  store i32 %next_step65, ptr %step_counter, align 4
  br label %main_loop

transition_4_2:                                   ; preds = %state_4_default
  %current_index66 = load i32, ptr %index, align 4
  %printf67 = call i32 (ptr, ...) @printf(ptr @print_format.7, i8 48)
  %new_index68 = sub i32 %current_index66, 1
  store i32 %new_index68, ptr %index, align 4
  %new_index69 = sub i32 %current_index66, 1
  store i32 %new_index69, ptr %index, align 4
  store i32 1, ptr %state_ptr, align 4
  %current_step70 = load i32, ptr %step_counter, align 4
  %next_step71 = add i32 %current_step70, 1
  store i32 %next_step71, ptr %step_counter, align 4
  br label %main_loop

state_4_default:                                  ; preds = %state_4_default
  br label %main_loop
  switch i32 %symbol_int5, label %state_4_default [
    i32 2, label %transition_4_2
  ]
}
