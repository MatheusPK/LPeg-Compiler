@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}


define i32 @foo(i32 %T0, i32 %T2, i32 %T4) {
   %T1 = alloca i32
   store i32 %T0, i32* %T1
   %T3 = alloca i32
   store i32 %T2, i32* %T3
   %T5 = alloca i32
   store i32 %T4, i32* %T5
   %T6 = load i32, i32* %T1
   %T7 = load i32, i32* %T3
   %T8 = mul i32 %T6, %T7
   %T9 = load i32, i32* %T5
   %T10 = mul i32 %T8, %T9
   ret i32 %T10
   ret i32 0
}
define i32 @main() {
   %T11 = add i32 0, 2
   %T12 = add i32 %T11, 5
   %T13 = add i32 3, 2
   %T14 = add i32 2, 3
   %T15 = sub i32 0, 2
   %T16 = add i32 1, %T15
   %T17 = call i32 @foo(i32 %T13, i32 %T14, i32 %T16)
   %T18 = add i32 %T12, %T17
   call void @printI(i32 %T18)
   ret i32 0
}
