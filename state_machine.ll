; ModuleID = 'tape_machine_fixed'
source_filename = "tape_machine_fixed"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@print_current_step_format = private unnamed_addr constant [17 x i8] c"All Symbols: %s\0A\00", align 1
@symbol_index_value_mapping = private unnamed_addr constant [24 x i8] c"0:0, 1:1, 2:e, 3:x, 4:X\00", align 1
@print_current_step_format.1 = private unnamed_addr constant [18 x i8] c"Current step: %d\0A\00", align 1
@print_current_step_format.2 = private unnamed_addr constant [12 x i8] c"Symbol: %s\0A\00", align 1
@symbol_0 = private unnamed_addr constant [2 x i8] c"0\00", align 1
@symbol_1 = private unnamed_addr constant [2 x i8] c"1\00", align 1
@symbol_e = private unnamed_addr constant [2 x i8] c"e\00", align 1
@symbol_x = private unnamed_addr constant [2 x i8] c"x\00", align 1
@symbol_X = private unnamed_addr constant [2 x i8] c"X\00", align 1
@print_current_step_format.3 = private unnamed_addr constant [23 x i8] c"Default Remainder: %d\0A\00", align 1
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
  store i32 0, ptr %index_ptr, align 4
  store i32 0, ptr %current_step_ptr, align 4
  store i32 0, ptr %current_symbol_index_ptr, align 4
  %print_all_symbols = call i32 (ptr, ...) @printf(ptr @print_current_step_format, ptr @symbol_index_value_mapping)
  br label %steps_loop

steps_loop:                                       ; preds = %after_switch, %entry
  %current_step_val = load i32, ptr %current_step_ptr, align 4
  %current_symbol_index_val = load i32, ptr %current_symbol_index_ptr, align 4
  %step_limit_cond = icmp ult i32 %current_step_val, %num_steps
  br i1 %step_limit_cond, label %steps_loop_body, label %steps_loop_end

steps_loop_body:                                  ; preds = %steps_loop
  %current_step_print_call = call i32 (ptr, ...) @printf(ptr @print_current_step_format.1, i32 %current_step_val)
  switch i32 %current_symbol_index_val, label %switch_default [
    i32 0, label %switch_0
    i32 1, label %switch_1
    i32 2, label %switch_2
    i32 3, label %switch_3
    i32 4, label %switch_4
  ]

steps_loop_end:                                   ; preds = %steps_loop
  %step_loop_end_print = call i32 (ptr, ...) @printf(ptr @step_loop_end_format)
  br label %main_return

main_return:                                      ; preds = %steps_loop_end
  ret i32 0

switch_default:                                   ; preds = %steps_loop_body
  %current_step_print_call6 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, i32 %current_step_val)
  br label %after_switch

after_switch:                                     ; preds = %switch_default, %switch_4, %switch_3, %switch_2, %switch_1, %switch_0
  %current_step_increment = add i32 %current_step_val, 1
  store i32 %current_step_increment, ptr %current_step_ptr, align 4
  %current_symbol_index_increment_1 = add i32 %current_symbol_index_val, 2
  %clip_symbol_index = srem i32 %current_symbol_index_increment_1, 5
  store i32 %clip_symbol_index, ptr %current_symbol_index_ptr, align 4
  br label %steps_loop

switch_0:                                         ; preds = %steps_loop_body
  %current_step_print_call1 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, ptr @symbol_0)
  br label %after_switch

switch_1:                                         ; preds = %steps_loop_body
  %current_step_print_call2 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, ptr @symbol_1)
  br label %after_switch

switch_2:                                         ; preds = %steps_loop_body
  %current_step_print_call3 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, ptr @symbol_e)
  br label %after_switch

switch_3:                                         ; preds = %steps_loop_body
  %current_step_print_call4 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, ptr @symbol_x)
  br label %after_switch

switch_4:                                         ; preds = %steps_loop_body
  %current_step_print_call5 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.2, ptr @symbol_X)
  br label %after_switch
}
