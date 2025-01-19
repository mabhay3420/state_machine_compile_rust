; ModuleID = 'tape_machine_fixed'
source_filename = "tape_machine_fixed"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1

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
  ret i32 0
}
