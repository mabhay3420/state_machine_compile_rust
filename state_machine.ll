; ModuleID = 'abhay'
source_filename = "abhay"
target triple = "arm64-apple-macosx13.0.0"

@print_string = private unnamed_addr constant [17 x i8] c"Hello world: %d\0A\00", align 1

declare i32 @printf(ptr, ...)

define i32 @main() {
entry:
  %printf = call i32 (ptr, ...) @printf(ptr @print_string, i32 0)
  ret i32 0
}
