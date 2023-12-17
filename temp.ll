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
%T1 = load i32, ptr %T0
%T3 = add i32 %T1, 1
store i32 %T3, ptr %T0

%T4 = load i32, ptr %T0
%T6 = add i32 %T4, 1
store i32 %T6, ptr %T0

call void @printI(i32 %T4)
%T7 = load i32, ptr %T0
call void @printI(i32 %T7)
ret i32 0
}
