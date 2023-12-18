@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [7 x i8] c"%.16g\0A\00"

declare dso_local i32 @printf(i8*, ...)
declare ptr @malloc(i64)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define internal void @printD(double %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %x)
  ret void
}


define i32 @main() {
%T0 = alloca i32
store i32 0, ptr %T0
br label %L1
L1:
%T4 = load i32, ptr %T0
%T5 = icmp slt i32 %T4, 10
%T6 = zext i1 %T5 to i32
%T7 = icmp ne i32 %T6, 0
br i1 %T7, label %L2, label %L3
L2:
%T8 = load i32, ptr %T0
call void @printI(i32 %T8)
%T9 = load i32, ptr %T0
%T10 = add i32 %T9, 1
store i32 %T10, ptr %T0

br label %L1
L3:
ret i32 0
}
