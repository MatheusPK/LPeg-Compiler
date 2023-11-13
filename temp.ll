@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [6 x i8] c"%.16g\00"

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
   %T0 = fptosi double 10.8 to i32
   %T1 = sitofp i32 %T0 to double
   %T2 = fptosi double %T1 to i32
   %T3 = sitofp i32 %T2 to double
   %T4 = alloca double
   store double %T3, ptr %T4
   %T5 = load double, double* %T4
   %T6 = fadd double %T5, 0.1
   call void @printD(double %T6)
   ret i32 0
}
