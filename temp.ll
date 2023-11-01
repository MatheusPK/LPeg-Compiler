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
   %T0 = alloca i32
   store i32 10, ptr %T0
   %T1 = load i32, i32* %T0
   %T2 = sitofp i32 %T1 to double
   %T3 = alloca double
   store double %T2, ptr %T3
   %T4 = load double, double* %T3
   %T5 = fadd double %T4, 0.5
   call void @printD(double %T5)
   %T6 = load double, double* %T3
   %T7 = fptosi double %T6 to i32
   %T8 = add i32 %T7, 4
   call void @printI(i32 %T8)
   %T9 = load double, double* %T3
   %T10 = fptosi double %T9 to i32
