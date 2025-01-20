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
  %current_tape_index_ptr = alloca i32, align 4
  %current_step_ptr = alloca i32, align 4
  %current_symbol_index_ptr = alloca i32, align 4
  %current_state_index_ptr = alloca i32, align 4
  store i32 0, ptr %current_tape_index_ptr, align 4
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
    i32 0, label %state_b_sym_0
    i32 1, label %state_o_sym_0
    i32 2, label %state_q_sym_0
    i32 3, label %state_p_sym_0
    i32 4, label %state_f_sym_0
    i32 5, label %state_b_sym_1
    i32 6, label %state_o_sym_1
    i32 7, label %state_q_sym_1
    i32 8, label %state_p_sym_1
    i32 9, label %state_f_sym_1
    i32 10, label %state_b_sym_e
    i32 11, label %state_o_sym_e
    i32 12, label %state_q_sym_e
    i32 13, label %state_p_sym_e
    i32 14, label %state_f_sym_e
    i32 15, label %state_b_sym_x
    i32 16, label %state_o_sym_x
    i32 17, label %state_q_sym_x
    i32 18, label %state_p_sym_x
    i32 19, label %state_f_sym_x
    i32 20, label %state_b_sym_X
    i32 21, label %state_o_sym_X
    i32 22, label %state_q_sym_X
    i32 23, label %state_p_sym_X
    i32 24, label %state_f_sym_X
  ]

steps_loop_end:                                   ; preds = %steps_loop
  %step_loop_end_print = call i32 (ptr, ...) @printf(ptr @step_loop_end_format)
  br label %main_return

main_return:                                      ; preds = %steps_loop_end
  ret i32 0

switch_default:                                   ; preds = %steps_loop_body
  %current_step_print_call129 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.4, i32 %current_step_val)
  br label %after_switch

after_switch:                                     ; preds = %switch_default, %state_f_sym_X, %state_p_sym_X, %state_q_sym_X, %state_o_sym_X, %state_b_sym_X, %state_f_sym_x, %state_p_sym_x, %state_q_sym_x, %state_o_sym_x, %state_b_sym_x, %state_f_sym_e, %state_p_sym_e, %state_q_sym_e, %state_o_sym_e, %state_b_sym_e, %state_f_sym_1, %state_p_sym_1, %state_q_sym_1, %state_o_sym_1, %state_b_sym_1, %state_f_sym_0, %state_p_sym_0, %state_q_sym_0, %state_o_sym_0, %state_b_sym_0
  %current_step_increment = add i32 %current_step_val, 1
  store i32 %current_step_increment, ptr %current_step_ptr, align 4
  %current_symbol_index_increment_1 = add i32 %current_symbol_index_val, 2
  %clip_symbol_index = srem i32 %current_symbol_index_increment_1, 5
  store i32 %clip_symbol_index, ptr %current_symbol_index_ptr, align 4
  br label %steps_loop

state_b_sym_0:                                    ; preds = %steps_loop_body
  %current_step_print_call1 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_b)
  %current_tape_index_val69 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right70 = add i32 %current_tape_index_val69, 1
  store i32 %move_right70, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val71 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right72 = add i32 %current_tape_index_val71, 1
  store i32 %move_right72, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val73 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right74 = add i32 %current_tape_index_val73, 1
  store i32 %move_right74, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val75 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right76 = add i32 %current_tape_index_val75, 1
  store i32 %move_right76, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val77 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left78 = sub i32 %current_tape_index_val77, 1
  store i32 %move_left78, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val79 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left80 = sub i32 %current_tape_index_val79, 1
  store i32 %move_left80, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_o_sym_0:                                    ; preds = %steps_loop_body
  %current_step_print_call2 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_o)
  br label %after_switch

state_q_sym_0:                                    ; preds = %steps_loop_body
  %current_step_print_call3 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_q)
  %current_tape_index_val51 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right52 = add i32 %current_tape_index_val51, 1
  store i32 %move_right52, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val53 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right54 = add i32 %current_tape_index_val53, 1
  store i32 %move_right54, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_p_sym_0:                                    ; preds = %steps_loop_body
  %current_step_print_call4 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_p)
  br label %after_switch

state_f_sym_0:                                    ; preds = %steps_loop_body
  %current_step_print_call5 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_0, ptr @state_f)
  %current_tape_index_val35 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right36 = add i32 %current_tape_index_val35, 1
  store i32 %move_right36, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val37 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right38 = add i32 %current_tape_index_val37, 1
  store i32 %move_right38, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_b_sym_1:                                    ; preds = %steps_loop_body
  %current_step_print_call6 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_b)
  %current_tape_index_val81 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right82 = add i32 %current_tape_index_val81, 1
  store i32 %move_right82, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val83 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right84 = add i32 %current_tape_index_val83, 1
  store i32 %move_right84, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val85 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right86 = add i32 %current_tape_index_val85, 1
  store i32 %move_right86, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val87 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right88 = add i32 %current_tape_index_val87, 1
  store i32 %move_right88, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val89 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left90 = sub i32 %current_tape_index_val89, 1
  store i32 %move_left90, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val91 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left92 = sub i32 %current_tape_index_val91, 1
  store i32 %move_left92, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_o_sym_1:                                    ; preds = %steps_loop_body
  %current_step_print_call7 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_o)
  %current_tape_index_val = load i32, ptr %current_tape_index_ptr, align 4
  %move_right = add i32 %current_tape_index_val, 1
  store i32 %move_right, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val26 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left = sub i32 %current_tape_index_val26, 1
  store i32 %move_left, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val27 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left28 = sub i32 %current_tape_index_val27, 1
  store i32 %move_left28, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val29 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left30 = sub i32 %current_tape_index_val29, 1
  store i32 %move_left30, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_q_sym_1:                                    ; preds = %steps_loop_body
  %current_step_print_call8 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_q)
  %current_tape_index_val55 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right56 = add i32 %current_tape_index_val55, 1
  store i32 %move_right56, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val57 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right58 = add i32 %current_tape_index_val57, 1
  store i32 %move_right58, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_p_sym_1:                                    ; preds = %steps_loop_body
  %current_step_print_call9 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_p)
  br label %after_switch

state_f_sym_1:                                    ; preds = %steps_loop_body
  %current_step_print_call10 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_1, ptr @state_f)
  %current_tape_index_val39 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right40 = add i32 %current_tape_index_val39, 1
  store i32 %move_right40, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val41 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right42 = add i32 %current_tape_index_val41, 1
  store i32 %move_right42, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_b_sym_e:                                    ; preds = %steps_loop_body
  %current_step_print_call11 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_b)
  %current_tape_index_val93 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right94 = add i32 %current_tape_index_val93, 1
  store i32 %move_right94, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val95 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right96 = add i32 %current_tape_index_val95, 1
  store i32 %move_right96, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val97 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right98 = add i32 %current_tape_index_val97, 1
  store i32 %move_right98, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val99 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right100 = add i32 %current_tape_index_val99, 1
  store i32 %move_right100, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val101 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left102 = sub i32 %current_tape_index_val101, 1
  store i32 %move_left102, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val103 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left104 = sub i32 %current_tape_index_val103, 1
  store i32 %move_left104, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_o_sym_e:                                    ; preds = %steps_loop_body
  %current_step_print_call12 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_o)
  br label %after_switch

state_q_sym_e:                                    ; preds = %steps_loop_body
  %current_step_print_call13 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_q)
  br label %after_switch

state_p_sym_e:                                    ; preds = %steps_loop_body
  %current_step_print_call14 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_p)
  %current_tape_index_val63 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right64 = add i32 %current_tape_index_val63, 1
  store i32 %move_right64, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_f_sym_e:                                    ; preds = %steps_loop_body
  %current_step_print_call15 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_e, ptr @state_f)
  %current_tape_index_val43 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right44 = add i32 %current_tape_index_val43, 1
  store i32 %move_right44, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val45 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right46 = add i32 %current_tape_index_val45, 1
  store i32 %move_right46, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_b_sym_x:                                    ; preds = %steps_loop_body
  %current_step_print_call16 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_b)
  %current_tape_index_val105 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right106 = add i32 %current_tape_index_val105, 1
  store i32 %move_right106, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val107 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right108 = add i32 %current_tape_index_val107, 1
  store i32 %move_right108, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val109 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right110 = add i32 %current_tape_index_val109, 1
  store i32 %move_right110, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val111 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right112 = add i32 %current_tape_index_val111, 1
  store i32 %move_right112, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val113 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left114 = sub i32 %current_tape_index_val113, 1
  store i32 %move_left114, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val115 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left116 = sub i32 %current_tape_index_val115, 1
  store i32 %move_left116, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_o_sym_x:                                    ; preds = %steps_loop_body
  %current_step_print_call17 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_o)
  br label %after_switch

state_q_sym_x:                                    ; preds = %steps_loop_body
  %current_step_print_call18 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_q)
  br label %after_switch

state_p_sym_x:                                    ; preds = %steps_loop_body
  %current_step_print_call19 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_p)
  %current_tape_index_val61 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right62 = add i32 %current_tape_index_val61, 1
  store i32 %move_right62, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_f_sym_x:                                    ; preds = %steps_loop_body
  %current_step_print_call20 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_x, ptr @state_f)
  %current_tape_index_val47 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right48 = add i32 %current_tape_index_val47, 1
  store i32 %move_right48, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val49 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right50 = add i32 %current_tape_index_val49, 1
  store i32 %move_right50, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_b_sym_X:                                    ; preds = %steps_loop_body
  %current_step_print_call21 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_b)
  %current_tape_index_val117 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right118 = add i32 %current_tape_index_val117, 1
  store i32 %move_right118, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val119 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right120 = add i32 %current_tape_index_val119, 1
  store i32 %move_right120, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val121 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right122 = add i32 %current_tape_index_val121, 1
  store i32 %move_right122, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val123 = load i32, ptr %current_tape_index_ptr, align 4
  %move_right124 = add i32 %current_tape_index_val123, 1
  store i32 %move_right124, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val125 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left126 = sub i32 %current_tape_index_val125, 1
  store i32 %move_left126, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val127 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left128 = sub i32 %current_tape_index_val127, 1
  store i32 %move_left128, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_o_sym_X:                                    ; preds = %steps_loop_body
  %current_step_print_call22 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_o)
  br label %after_switch

state_q_sym_X:                                    ; preds = %steps_loop_body
  %current_step_print_call23 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_q)
  %current_tape_index_val59 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left60 = sub i32 %current_tape_index_val59, 1
  store i32 %move_left60, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_p_sym_X:                                    ; preds = %steps_loop_body
  %current_step_print_call24 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_p)
  %current_tape_index_val65 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left66 = sub i32 %current_tape_index_val65, 1
  store i32 %move_left66, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val67 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left68 = sub i32 %current_tape_index_val67, 1
  store i32 %move_left68, ptr %current_tape_index_ptr, align 4
  br label %after_switch

state_f_sym_X:                                    ; preds = %steps_loop_body
  %current_step_print_call25 = call i32 (ptr, ...) @printf(ptr @print_current_step_format.3, ptr @symbol_X, ptr @state_f)
  %current_tape_index_val31 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left32 = sub i32 %current_tape_index_val31, 1
  store i32 %move_left32, ptr %current_tape_index_ptr, align 4
  %current_tape_index_val33 = load i32, ptr %current_tape_index_ptr, align 4
  %move_left34 = sub i32 %current_tape_index_val33, 1
  store i32 %move_left34, ptr %current_tape_index_ptr, align 4
  br label %after_switch
}
