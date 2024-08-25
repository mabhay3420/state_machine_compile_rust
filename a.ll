; ModuleID = 'src/a.c'
source_filename = "src/a.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx13.0.0"

@prompt_message = private unnamed_addr constant [17 x i8] c"Enter a number: \00", align 1
@input_format = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@message_x_is_1 = private unnamed_addr constant [8 x i8] c"x is 1\0A\00", align 1
@message_x_is_2 = private unnamed_addr constant [8 x i8] c"x is 2\0A\00", align 1
@message_x_not_1_or_2 = private unnamed_addr constant [17 x i8] c"x is not 1 or 2\0A\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
entry_block:
  %return_value = alloca i32, align 4
  %user_input = alloca i32, align 4
  store i32 0, ptr %return_value, align 4
  %print_prompt = call i32 (ptr, ...) @printf(ptr noundef @prompt_message)
  %read_input = call i32 (ptr, ...) @scanf(ptr noundef @input_format, ptr noundef %user_input)
  %input_value = load i32, ptr %user_input, align 4
  switch i32 %input_value, label %default_case [
    i32 1, label %case_x_is_1
    i32 2, label %case_x_is_2
  ]

case_x_is_1:
  %print_x_is_1 = call i32 (ptr, ...) @printf(ptr noundef @message_x_is_1)
  br label %end_switch

case_x_is_2:
  %print_x_is_2 = call i32 (ptr, ...) @printf(ptr noundef @message_x_is_2)
  br label %end_switch

default_case:
  %print_x_not_1_or_2 = call i32 (ptr, ...) @printf(ptr noundef @message_x_not_1_or_2)
  br label %end_switch

end_switch:
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

declare i32 @scanf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+complxnum,+crc,+dotprod,+fp-armv8,+fp16fml,+fullfp16,+jsconv,+lse,+neon,+pauth,+ras,+rcpc,+rdm,+sha2,+sha3,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!"clang version 18.1.8"}