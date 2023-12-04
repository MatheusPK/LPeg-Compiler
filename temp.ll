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


define ptr @foo(i32 %T0) {
%T1 = alloca i32
store i32 %T0, ptr %T1
%T3 = load i32, ptr %T1
%T5 = mul i32 4, %T3
%T6 = sext i32 %T5 to i64
%T4 = call ptr @malloc(i64 %T6)
%T2 = alloca ptr
store ptr %T4, ptr %T2
%T8 = sext i32 6 to i64
%T9 = load ptr, ptr %T2
%T7 = getelementptr inbounds i32, ptr %T9, i64 %T8
store i32 120, ptr %T7
%T10 = load ptr, ptr %T2
ret ptr %T10
%T11 = alloca ptr
ret ptr %T11
}
define i32 @main() {
%T13 = call ptr @foo(i32 10)
%T12 = alloca ptr
store ptr %T13, ptr %T12
%T14 = load ptr, ptr %T12
%T16 = sext i32 6 to i64
%T15 = getelementptr inbounds i32, ptr %T14, i64 %T16
%T17 = load i32, ptr %T15
call void @printI(i32 %T17)
%T18 = load ptr, ptr %T12
%T19 = fptosi double 10.0 to i32
%T21 = sext i32 %T19 to i64
%T20 = getelementptr inbounds i32, ptr %T18, i64 %T21
%T22 = load i32, ptr %T20
call void @printI(i32 %T22)
ret i32 0
}
