; ModuleID = 'tape_machine_fixed'
source_filename = "tape_machine_fixed"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@print_current_step_format = private unnamed_addr constant [17 x i8] c"All Symbols: %s\0A\00", align 1
@symbol_index_value_mapping = private unnamed_addr constant [24 x i8] c"0:0, 1:1, 2:e, 3:x, 4:X\00", align 1
@print_current_step_format.1 = private unnamed_addr constant [16 x i8] c"All States: %s\0A\00", align 1
@state_index_value_mapping = private unnamed_addr constant [24 x i8] c"0:b, 1:o, 2:q, 3:p, 4:f\00", align 1
@print_current_step_format.2 = private unnamed_addr constant [18 x i8] c"Current step: %d\0A\00", align 1
@print_current_step_format.3 = private unnamed_addr constant [22 x i8] c"Symbol: %s State: %s\0A\00", align 1
@symbol_0 = private unnamed_addr constant [2 x i8] c"0\00", align 1
@symbol_1 = private unnamed_addr constant [2 x i8] c"1\00", align 1
@symbol_e = private unnamed_addr constant [2 x i8] c"e\00", align 1
@symbol_x = private unnamed_addr constant [2 x i8] c"x\00", align 1
@symbol_X = private unnamed_addr constant [2 x i8] c"X\00", align 1
@state_b = private unnamed_addr constant [2 x i8] c"b\00", align 1
@state_o = private unnamed_addr constant [2 x i8] c"o\00", align 1
@state_q = private unnamed_addr constant [2 x i8] c"q\00", align 1
@state_p = private unnamed_addr constant [2 x i8] c"p\00", align 1
@state_f = private unnamed_addr constant [2 x i8] c"f\00", align 1
@print_current_step_format.4 = private unnamed_addr constant [23 x i8] c"Default Remainder: %d\0A\00", align 1
@step_loop_end_format = private unnamed_addr constant [27 x i8] c"Reached end of steps loop.\00", align 1

declare i32 @printf(ptr, ...)

declare ptr @malloc(i32)

declare i32 @scanf(ptr, ...)

define i32 @main() {
entry:
  %num_steps_ptr = alloca i32, align 4
  %arr_size_ptr = alloca i32, align 4
  %printf_call_1 = call i32 (ptr, ...) @printf(ptr @num_steps_prompt)
  %scanf_call_1 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %num_steps_ptr)
  %num_steps = load i32, ptr %num_steps_ptr, align 4
  %printf_call_2 = call i32 (ptr, ...) @printf(ptr @arr_size_prompt)
  %scanf_call_2 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %arr_size_ptr)
  %arr_size = load i32, ptr %arr_size_ptr, align 4
  %tape_array_malloc_call = call ptr @malloc(i32 %arr_size)
  %index_ptr = alloca i32, align 4
  %current_step_ptr = alloca i32, align 4
  %current_symbol_index_ptr = alloca i32, align 4
  %current_state_index_ptr = alloca i32, align 4
  store i32 0, ptr %index_ptr, align 4
  store i32 0, ptr %current_step_ptr, align 4
  store i32 0, ptr %current_symbol_index_ptr, align 4
  store i32 0, ptr %current_state_index_ptr, align 4
  %print_all_symbols = call i32 (ptr, ...) @printf(ptr @print_current_step_format, ptr @symbol_index_value_mapping)
  %print_all_states = call i32 (ptr, ...) @printf(ptr @print_current_step_format.1, ptr @state_index_value_mapping)
  br label %steps_loop

steps_loop:                                       ; preds = %after_switch, %entry
  %current_step_val = load i32, ptr %current_step_ptr, align 4
  %current_symbol_index_val = load i32, ptr %current_symbol_index_ptr, align 4
  %current_state_index_val = load i32, ptr %current_state_index_ptr, align 4
  %current_symbol_index__x__total_states = mul i32 %current_symbol_index_val, 5
  %current_switch_case_number = add i32 %current_symbol_index__x__total_states, %current_state_index_val
  %step_limit_cond = icmp ult i32 %current_step_val, %num_steps
  br i1 %step_limit_cond, label %steps_loop_body, label %steps_loop_end

steps_loop_body:                                  ; preds = %steps_loop
  %current_step_print_call = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, i32 %current_step_val)
  switch i32 %current_switch_case_number, label %switch_default [
    i32 0, label %sym_0_state_0
    i32 1, label %sym_0_state_1
    i32 2, label %sym_0_state_2
    i32 3, label %sym_0_state_3
    i32 4, label %sym_0_state_4
    i32 5, label %sym_1_state_0
    i32 6, label %sym_1_state_1
    i32 7, label %sym_1_state_2
    i32 8, label %sym_1_state_3
    i32 9, label %sym_1_state_4
    i32 10, label %sym_2_state_0
    i32 11, label %sym_2_state_1
    i32 12, label %sym_2_state_2
    i32 13, label %sym_2_state_3
    i32 14, label %sym_2_state_4
    i32 15, label %sym_3_state_0
    i32 16, label %sym_3_state_1
    i32 17, label %sym_3_state_2
    i32 18, label %sym_3_state_3
    i32 19, label %sym_3_state_4
    i32 20, label %sym_4_state_0
    i32 21, label %sym_4_state_1
    i32 22, label %sym_4_state_2
    i32 23, label %sym_4_state_3
    i32 24, label %sym_4_state_4
  ]

steps_loop_end:                                   ; preds = %steps_loop
  %step_loop_end_print = call i32 (ptr, ...) @printf(ptr @step_loop_end_format)
  br label %main_return

main_return:                                      ; preds = %steps_loop_end
  ret i32 0

switch_default:                                   ; preds = %steps_loop_body
  %current_step_print_call26 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.4, i32 %current_step_val)
  br label %after_switch

after_switch:                                     ; preds = %switch_default, %sym_4_state_4, %sym_4_state_3, %sym_4_state_2, %sym_4_state_1, %sym_4_state_0, %sym_3_state_4, %sym_3_state_3, %sym_3_state_2, %sym_3_state_1, %sym_3_state_0, %sym_2_state_4, %sym_2_state_3, %sym_2_state_2, %sym_2_state_1, %sym_2_state_0, %sym_1_state_4, %sym_1_state_3, %sym_1_state_2, %sym_1_state_1, %sym_1_state_0, %sym_0_state_4, %sym_0_state_3, %sym_0_state_2, %sym_0_state_1, %sym_0_state_0
  %current_step_increment = add i32 %current_step_val, 1
  store i32 %current_step_increment, ptr %current_step_ptr, align 4
  %current_symbol_index_increment_1 = add i32 %current_symbol_index_val, 2
  %clip_symbol_index = srem i32 %current_symbol_index_increment_1, 5
  store i32 %clip_symbol_index, ptr %current_symbol_index_ptr, align 4
  br label %steps_loop

sym_0_state_0:                                    ; preds = %steps_loop_body
  %current_step_print_call1 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_b)
  br label %after_switch

sym_0_state_1:                                    ; preds = %steps_loop_body
  %current_step_print_call2 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_o)
  br label %after_switch

sym_0_state_2:                                    ; preds = %steps_loop_body
  %current_step_print_call3 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_q)
  br label %after_switch

sym_0_state_3:                                    ; preds = %steps_loop_body
  %current_step_print_call4 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_p)
  br label %after_switch

sym_0_state_4:                                    ; preds = %steps_loop_body
  %current_step_print_call5 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_f)
  br label %after_switch

sym_1_state_0:                                    ; preds = %steps_loop_body
  %current_step_print_call6 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_b)
  br label %after_switch

sym_1_state_1:                                    ; preds = %steps_loop_body
  %current_step_print_call7 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_o)
  br label %after_switch

sym_1_state_2:                                    ; preds = %steps_loop_body
  %current_step_print_call8 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_q)
  br label %after_switch

sym_1_state_3:                                    ; preds = %steps_loop_body
  %current_step_print_call9 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_p)
  br label %after_switch

sym_1_state_4:                                    ; preds = %steps_loop_body
  %current_step_print_call10 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_f)
  br label %after_switch

sym_2_state_0:                                    ; preds = %steps_loop_body
  %current_step_print_call11 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_b)
  br label %after_switch

sym_2_state_1:                                    ; preds = %steps_loop_body
  %current_step_print_call12 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_o)
  br label %after_switch

sym_2_state_2:                                    ; preds = %steps_loop_body
  %current_step_print_call13 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_q)
  br label %after_switch

sym_2_state_3:                                    ; preds = %steps_loop_body
  %current_step_print_call14 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_p)
  br label %after_switch

sym_2_state_4:                                    ; preds = %steps_loop_body
  %current_step_print_call15 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_f)
  br label %after_switch

sym_3_state_0:                                    ; preds = %steps_loop_body
  %current_step_print_call16 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_b)
  br label %after_switch

sym_3_state_1:                                    ; preds = %steps_loop_body
  %current_step_print_call17 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_o)
  br label %after_switch

sym_3_state_2:                                    ; preds = %steps_loop_body
  %current_step_print_call18 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_q)
  br label %after_switch

sym_3_state_3:                                    ; preds = %steps_loop_body
  %current_step_print_call19 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_p)
  br label %after_switch

sym_3_state_4:                                    ; preds = %steps_loop_body
  %current_step_print_call20 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_f)
  br label %after_switch

sym_4_state_0:                                    ; preds = %steps_loop_body
  %current_step_print_call21 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_b)
  br label %after_switch

sym_4_state_1:                                    ; preds = %steps_loop_body
  %current_step_print_call22 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_o)
  br label %after_switch

sym_4_state_2:                                    ; preds = %steps_loop_body
  %current_step_print_call23 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_q)
  br label %after_switch

sym_4_state_3:                                    ; preds = %steps_loop_body
  %current_step_print_call24 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_p)
  br label %after_switch

sym_4_state_4:                                    ; preds = %steps_loop_body
  %current_step_print_call25 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_f)
  br label %after_switch
}
