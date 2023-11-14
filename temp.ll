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


define i32 @main() {
   %T0 = call ptr @malloc(i64 8)
   %T1 = alloca ptr
   store ptr %T0, ptr %T1
   %T2 = call ptr @malloc(i64 4)
  %T4 = load ptr, ptr %T1
  %T3 = getelementptr inbounds ptr, ptr %T4, i32 0
   store ptr %T2, ptr %T3
   %T5 = call ptr @malloc(i64 4)
  %T7 = load ptr, ptr %T1
  %T6 = getelementptr inbounds ptr, ptr %T7, i32 1
   store ptr %T5, ptr %T6
  %T9 = load ptr, ptr %T1
  %T8 = getelementptr inbounds ptr, ptr %T9, i32 0
  %T11 = load ptr, ptr %T8
  %T10 = getelementptr inbounds i32, ptr %T11, i32 0
   store i32 1, ptr %T10
  %T13 = load ptr, ptr %T1
  %T12 = getelementptr inbounds ptr, ptr %T13, i32 0
  %T15 = load ptr, ptr %T12
  %T14 = getelementptr inbounds i32, ptr %T15, i32 1
   store i32 3, ptr %T14
  %T17 = load ptr, ptr %T1
  %T16 = getelementptr inbounds ptr, ptr %T17, i32 1
  %T19 = load ptr, ptr %T16
  %T18 = getelementptr inbounds i32, ptr %T19, i32 0
   store i32 2, ptr %T18
  %T21 = load ptr, ptr %T1
  %T20 = getelementptr inbounds ptr, ptr %T21, i32 1
  %T23 = load ptr, ptr %T20
  %T22 = getelementptr inbounds i32, ptr %T23, i32 1
   store i32 4, ptr %T22
  %T25 = load ptr, ptr %T1
  %T24 = getelementptr inbounds ptr, ptr %T25, i32 0
