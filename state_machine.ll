; ModuleID = 'tape_machine_fixed'
source_filename = "tape_machine_fixed"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@print_integer_format = private unnamed_addr constant [13 x i8] c"Integer: %d\0A\00", align 1
@loop_end_format = private unnamed_addr constant [21 x i8] c"Reached end of loop.\00", align 1

declare i32 @printf(ptr, ...)

declare ptr @malloc(i32)

declare i32 @scanf(ptr, ...)

define i32 @main() {
entry:
  %num_steps_ptr = alloca i32, align 4
  %arr_size_ptr = alloca i32, align 4
  %index_ptr = alloca i32, align 4
  store i32 0, ptr %index_ptr, align 4
  %printf_call_1 = call i32 (ptr, ...) @printf(ptr @num_steps_prompt)
  %scanf_call_1 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %num_steps_ptr)
  %num_steps = load i32, ptr %num_steps_ptr, align 4
  %printf_call_2 = call i32 (ptr, ...) @printf(ptr @arr_size_prompt)
  %scanf_call_2 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %arr_size_ptr)
  %arr_size = load i32, ptr %arr_size_ptr, align 4
  %tape_array_malloc_call = call ptr @malloc(i32 %arr_size)
  store i32 0, ptr %index_ptr, align 4
  br label %init_loop

init_loop:                                        ; preds = %init_loop_body, %entry
  %index_val = load i32, ptr %index_ptr, align 4
  %init_cond = icmp ult i32 %index_val, %arr_size
  br i1 %init_cond, label %init_loop_body, label %init_loop_end

init_loop_body:                                   ; preds = %init_loop
  %array_index_print_call = call i32 (ptr, ...) @printf(ptr @print_integer_format, i32 %index_val)
  %array_increment = add i32 %index_val, 1
  store i32 %array_increment, ptr %index_ptr, align 4
  br label %init_loop

init_loop_end:                                    ; preds = %init_loop
  %loop_end_print = call i32 (ptr, ...) @printf(ptr @loop_end_format)
  br label %main_return

main_return:                                      ; preds = %init_loop_end
  ret i32 0
}
