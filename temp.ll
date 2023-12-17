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
%T2 = add i32 %T1, 1
store i32 %T2, ptr %T0

%T3 = load i32, ptr %T0
%T4 = sub i32 %T3, 1
store i32 %T4, ptr %T0

%T5 = load i32, ptr %T0
%T6 = add i32 %T5, 1
store i32 %T6, ptr %T0

%T7 = load i32, ptr %T0
%T8 = add i32 %T7, 1
store i32 %T8, ptr %T0

%T9 = load i32, ptr %T0
%T10 = sub i32 %T9, 1
store i32 %T10, ptr %T0

%T11 = load i32, ptr %T0
%T12 = add i32 %T11, 1
store i32 %T12, ptr %T0

call void @printI(i32 %T11)
%T13 = load i32, ptr %T0
%T14 = sub i32 %T13, 1
store i32 %T14, ptr %T0

call void @printI(i32 %T13)
%T15 = load i32, ptr %T0
call void @printI(i32 %T15)
ret i32 0
}
