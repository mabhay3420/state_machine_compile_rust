; ModuleID = 'tape_machine_fixed'
source_filename = "tape_machine_fixed"
target triple = "arm64-apple-macosx13.0.0"

@num_steps_prompt = private unnamed_addr constant [24 x i8] c"Enter number of steps: \00", align 1
@scanf_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@arr_size_prompt = private unnamed_addr constant [19 x i8] c"Enter array size: \00", align 1
@print_format = private unnamed_addr constant [12 x i8] c"Symbol: %c\0A\00", align 1
@print_array_format = private unnamed_addr constant [4 x i8] c"%c 0", align 1  ; Format for printing array symbols

; External function declarations
declare i32 @printf(ptr, ...)
declare ptr @malloc(i32)
declare i32 @scanf(ptr, ...)

define i32 @main() {
entry:
  ; Allocate variables
  %num_steps = alloca i32, align 4  ; Allocate memory for the number of steps
  %arr_size = alloca i32, align 4   ; Allocate memory for the array size
  %index = alloca i32, align 4      ; Allocate memory for the current index
  %i = alloca i32, align 4          ; Allocate memory for loop variable i
  %state_ptr = alloca i32, align 4  ; Allocate memory for the current state
  %step_counter = alloca i32, align 4 ; Allocate memory for the step counter
  %symbol_int = alloca i32, align 4 ; Allocate memory for the symbol integer

  ; Initialize index, step counter, and state
  store i32 0, ptr %index, align 4       ; Initialize index to 0
  store i32 0, ptr %step_counter, align 4 ; Initialize step counter to 0
  store i32 0, ptr %state_ptr, align 4   ; Initialize state to 0

  ; Prompt for number of steps
  %printf = call i32 (ptr, ...) @printf(ptr @num_steps_prompt)  ; Print prompt for number of steps
  %scanf = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %num_steps)  ; Read number of steps
  %num_steps1 = load i32, ptr %num_steps, align 4  ; Load the number of steps

  ; Prompt for array size
  %printf2 = call i32 (ptr, ...) @printf(ptr @arr_size_prompt)  ; Print prompt for array size
  %scanf3 = call i32 (ptr, ...) @scanf(ptr @scanf_format, ptr %arr_size)  ; Read array size
  %arr_size4 = load i32, ptr %arr_size, align 4  ; Load the array size

  ; Check if array size is positive
  %is_positive = icmp sgt i32 %arr_size4, 0  ; Check if array size is greater than 0
  br i1 %is_positive, label %allocate_memory, label %error_exit  ; Branch based on the result

allocate_memory:
  ; Allocate tape memory
  %tape_malloc = call ptr @malloc(i32 %arr_size4)  ; Allocate memory for the tape
  %tape = bitcast ptr %tape_malloc to ptr          ; Cast the allocated memory to an opaque pointer

  ; Initialize tape with 'X'
  store i32 0, ptr %i, align 4  ; Initialize loop variable i to 0
  br label %init_loop

init_loop:
  %i_val = load i32, ptr %i, align 4  ; Load the current value of i
  %init_cond = icmp ult i32 %i_val, %arr_size4  ; Check if i is less than the array size
  br i1 %init_cond, label %init_loop_body, label %init_loop_end  ; Branch based on the result

init_loop_body:
  %element_ptr = getelementptr i8, ptr %tape, i32 %i_val  ; Get the pointer to the current element in the tape
  store i8 88, ptr %element_ptr, align 1  ; Store 'X' (ASCII 88) in the current element
  %next_i = add i32 %i_val, 1  ; Increment i by 1
  store i32 %next_i, ptr %i, align 4  ; Store the updated value of i
  br label %init_loop

init_loop_end:
  ; Main loop for tape machine
  br label %main_loop

main_loop:
  %current_step = load i32, ptr %step_counter, align 4  ; Load the current step count
  %continue_loop = icmp ult i32 %current_step, %num_steps1  ; Check if the current step is less than the total steps
  br i1 %continue_loop, label %main_loop_body, label %main_loop_end  ; Branch based on the result

main_loop_body:
  %current_state = load i32, ptr %state_ptr, align 4  ; Load the current state
  %current_index = load i32, ptr %index, align 4  ; Load the current index

  ; Bounds check for index
  %in_bounds = icmp uge i32 %current_index, 0  ; Check if index is greater than or equal to 0
  %within_size = icmp ult i32 %current_index, %arr_size4  ; Check if index is less than the array size
  %valid_index = and i1 %in_bounds, %within_size  ; Combine both conditions to ensure index is valid
  br i1 %valid_index, label %valid_index_body, label %error_exit  ; Branch based on the result

valid_index_body:
  %current_symbol_ptr = getelementptr i8, ptr %tape, i32 %current_index  ; Get the pointer to the current symbol in the tape
  %current_symbol = load i8, ptr %current_symbol_ptr, align 1  ; Load the current symbol

  ; Handle different symbols
  switch i8 %current_symbol, label %symbol_default [
    i8 88, label %symbol_case_1  ; 'X'
    i8 120, label %symbol_case_2 ; 'x'
    i8 101, label %symbol_case_3 ; 'e'
    i8 48, label %symbol_case_4  ; '0'
    i8 49, label %symbol_case_5  ; '1'
  ]

symbol_case_1:
  store i32 1, ptr %symbol_int, align 4  ; Set symbol_int to 1 for 'X'
  br label %update_step

symbol_case_2:
  store i32 2, ptr %symbol_int, align 4  ; Set symbol_int to 2 for 'x'
  br label %update_step

symbol_case_3:
  store i32 3, ptr %symbol_int, align 4  ; Set symbol_int to 3 for 'e'
  br label %update_step

symbol_case_4:
  store i32 0, ptr %symbol_int, align 4  ; Set symbol_int to 0 for '0'
  br label %update_step

symbol_case_5:
  store i32 4, ptr %symbol_int, align 4  ; Set symbol_int to 4 for '1'
  br label %update_step

symbol_default:
  store i32 -1, ptr %symbol_int, align 4  ; Set symbol_int to -1 for unknown symbols
  br label %update_step

update_step:
  ; Update the step counter and continue loop
  %current_step8 = load i32, ptr %step_counter, align 4  ; Load the current step count
  %next_step = add i32 %current_step8, 1  ; Increment the step count by 1
  store i32 %next_step, ptr %step_counter, align 4  ; Store the updated step count
  br label %main_loop

main_loop_end:
  ; Print the final state of the tape array
  store i32 0, ptr %i, align 4  ; Initialize loop variable i to 0
  br label %print_loop

print_loop:
  %i_val_print = load i32, ptr %i, align 4  ; Load the current value of i
  %print_cond = icmp ult i32 %i_val_print, %arr_size4  ; Check if i is less than the array size
  br i1 %print_cond, label %print_loop_body, label %print_loop_end  ; Branch based on the result

print_loop_body:
  %element_ptr_print = getelementptr i8, ptr %tape, i32 %i_val_print  ; Get the pointer to the current element in the tape
  %element_val = load i8, ptr %element_ptr_print, align 1  ; Load the current element value
  call i32 (ptr, ...) @printf(ptr @print_array_format, i8 %element_val)  ; Print the element value
  %next_i_print = add i32 %i_val_print, 1  ; Increment i by 1
  store i32 %next_i_print, ptr %i, align 4  ; Store the updated value of i
  br label %print_loop

print_loop_end:
  ret i32 0  ; Return 0 to indicate successful execution

error_exit:
  ; Print error message and exit
  %error_msg = call i32 (ptr, ...) @printf(ptr @print_format, i8 69) ; Print 'E' for error
  ret i32 -1  ; Return -1 to indicate an error
}
