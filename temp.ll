@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define i32 @foo2() {
  %T0 = mul i32 3, 3
  ret i32 %T0
}
define i32 @foo() {
  call void @printI(i32 5)
  call void @printI(i32 10)
  %T1 = call i32 @foo2()
  ret i32 %T1
}
define i32 @main() {
  %T2 = call i32 @foo()
  call void @printI(i32 %T2)
  ret i32 0
}
