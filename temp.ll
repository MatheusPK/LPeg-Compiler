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
%T16 = sext i32 6 to i64
%T17 = load ptr, ptr %T12
%T15 = getelementptr inbounds i32, ptr %T17, i64 %T16
%T18 = load i32, ptr %T15
call void @printI(i32 %T18)
%T20 = sext i32 9 to i64
%T21 = load ptr, ptr %T12
%T19 = getelementptr inbounds i32, ptr %T21, i64 %T20
store i32 20, ptr %T19
%T24 = fptosi double 9.5 to i32
%T25 = sext i32 %T24 to i64
%T26 = load ptr, ptr %T12
%T23 = getelementptr inbounds i32, ptr %T26, i64 %T25
%T27 = load i32, ptr %T23
call void @printI(i32 %T27)
ret i32 0
}
