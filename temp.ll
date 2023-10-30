@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define internal void @printD(double %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.strD, i64 0, i64 0), double %x)
  ret void
}


define i32 @main() {
   br label %L0
 L0:
   %T3 = fsub double 0.0, 2.0
   %T4 = fcmp ogt double 1.0, %T3
   %T5 = zext i1 %T4 to i32
   %T6 = icmp ne i32 %T5, 0
   br i1 %T6, label %L1, label %L2
 L1:
   call void @printI(i32 3)
   br label %L0
 L2:
   ret i32 0
}
