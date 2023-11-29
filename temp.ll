@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [7 x i8] c"%.16g\0A\00"

declare dso_local i32 @printf(i8*, ...)
declare ptr @malloc(i64 noundef)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define internal void @printD(double %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %x)
  ret void
}


define i32 @foo(i32 %T0) {
%T1 = alloca i32
store i32 %T0, ptr %T1
%T2 = load i32, ptr %T1
%T3 = load i32, ptr %T1
%T4 = mul i32 %T2, %T3
ret i32 %T4
ret i32 0
}
define i32 @main() {
%T7 = mul i32 4, 10
%T8 = sext i32 %T7 to i64
%T6 = call ptr @malloc(i64 %T8)
%T5 = alloca ptr
store ptr %T6, ptr %T5
%T10 = load ptr, ptr %T5
%T9 = getelementptr inbounds ptr, ptr %T10, i32 1
%T11 = load ptr, ptr %T9
call void @printI(i32 %T11)
ret i32 0
}
