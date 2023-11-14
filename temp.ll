@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [6 x i8] c"%.16g\00"

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


define i32 @greater(ptr %T0, i32 %T2) {
   %T1 = alloca ptr
   store ptr %T0, ptr %T1
   %T3 = alloca i32
   store i32 %T2, ptr %T3
   %T4 = alloca i32
   store i32 0, ptr %T4
   br label %L5
 L5:
   %T8 = load i32, ptr %T4
   %T9 = load i32, ptr %T3
   %T10 = icmp slt i32 %T8, %T9
   %T11 = zext i1 %T10 to i32
   %T12 = icmp ne i32 %T11, 0
   br i1 %T12, label %L6, label %L7
 L6:
   %T14 = load i32, ptr %T4
  %T15 = load ptr, ptr %T1
  %T13 = getelementptr inbounds i32, ptr %T15, i32 %T14
   %T16 = load i32, ptr %T13
   call void @printI(i32 %T16)
   %T17 = load i32, ptr %T4
   %T18 = add i32 %T17, 1
   store i32 %T18, ptr %T4
   br label %L5
 L7:
   ret i32 0
   ret i32 0
}
define i32 @main() {
   %T19 = call ptr @malloc(i64 4)
   %T20 = alloca ptr
   store ptr %T19, ptr %T20
  %T22 = load ptr, ptr %T20
  %T21 = getelementptr inbounds i32, ptr %T22, i32 0
   store i32 1, ptr %T21
  %T24 = load ptr, ptr %T20
  %T23 = getelementptr inbounds i32, ptr %T24, i32 1
   store i32 2, ptr %T23
  %T26 = load ptr, ptr %T20
  %T25 = getelementptr inbounds i32, ptr %T26, i32 2
   store i32 3, ptr %T25
  %T28 = load ptr, ptr %T20
  %T27 = getelementptr inbounds i32, ptr %T28, i32 3
   store i32 4, ptr %T27
  %T30 = load ptr, ptr %T20
  %T29 = getelementptr inbounds i32, ptr %T30, i32 4
   store i32 5, ptr %T29
   %T31 = load ptr, ptr %T20
   %T32 = call i32 @greater(ptr %T31, i32 5)
   ret i32 0
}
