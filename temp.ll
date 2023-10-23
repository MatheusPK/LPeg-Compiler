@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define i32 @fat(i32 %T0) {
  %T1 = alloca i32
  store i32 %T0, i32* %T1
  %T5 = load i32, i32* %T1
  %T6 = icmp eq i32 %T5, 0
  %T7 = zext i1 %T6 to i32
  %T8 = icmp ne i32 %T7, 0
  br i1 %T8, label %L2, label %L4
  L2:
  ret i32 1
  br label %L4
  L4:
  %T9 = load i32, i32* %T1
  %T10 = load i32, i32* %T1
  %T11 = sub i32 %T10, 1
  %T12 = call i32 @fat(i32 %T11)

  %T13 = mul i32 %T9, %T12
  ret i32 %T13
}
define i32 @fatWhile(i32 %T14) {
  %T15 = alloca i32
  store i32 %T14, i32* %T15
  %T19 = load i32, i32* %T15
  %T20 = icmp eq i32 %T19, 0
  %T21 = zext i1 %T20 to i32
  %T22 = icmp ne i32 %T21, 0
  br i1 %T22, label %L16, label %L18
  L16:
  ret i32 1
  br label %L18
  L18:
  %T23 = alloca i32
  store i32 1, i32* %T23
  br label %L24
  L24:
  %T27 = load i32, i32* %T15
  %T28 = icmp sgt i32 %T27, 0
  %T29 = zext i1 %T28 to i32
  %T30 = icmp ne i32 %T29, 0
  br i1 %T30, label %L25, label %L26
  L25:
  %T31 = load i32, i32* %T23
  %T32 = load i32, i32* %T15
  %T33 = mul i32 %T31, %T32
  store i32 %T33, i32* %T23
  %T34 = load i32, i32* %T15
  %T35 = sub i32 %T34, 1
  store i32 %T35, i32* %T15
  br label %L24
  L26:
  %T36 = load i32, i32* %T23
  ret i32 %T36
}
define i32 @main() {
  %T37 = call i32 @fat(i32 5)

  %T38 = call i32 @fat(i32 4)

  %T39 = add i32 %T37, %T38
  call void @printI(i32 %T39)
  %T40 = call i32 @fatWhile(i32 5)

  %T41 = call i32 @fatWhile(i32 4)

  %T42 = add i32 %T40, %T41
  call void @printI(i32 %T42)
  ret i32 0
}
