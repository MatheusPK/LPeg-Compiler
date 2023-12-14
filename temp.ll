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


define ptr @criaMatriz(i32 %T0, i32 %T2) {
%T1 = alloca i32
store i32 %T0, ptr %T1
%T3 = alloca i32
store i32 %T2, ptr %T3
%T5 = load i32, ptr %T1
%T7 = mul i32 8, %T5
%T8 = sext i32 %T7 to i64
%T6 = call ptr @malloc(i64 %T8)
%T4 = alloca ptr
store ptr %T6, ptr %T4
%T9 = alloca i32
store i32 0, ptr %T9
br label %L10
L10:
%T13 = load i32, ptr %T9
%T14 = load i32, ptr %T1
%T15 = icmp slt i32 %T13, %T14
%T16 = zext i1 %T15 to i32
%T17 = icmp ne i32 %T16, 0
br i1 %T17, label %L11, label %L12
L11:
%T18 = load ptr, ptr %T4
%T19 = load i32, ptr %T9
%T21 = sext i32 %T19 to i64
%T20 = getelementptr inbounds ptr, ptr %T18, i64 %T21
%T22 = load i32, ptr %T3
%T24 = mul i32 4, %T22
%T25 = sext i32 %T24 to i64
%T23 = call ptr @malloc(i64 %T25)
store ptr %T23, ptr %T20
%T26 = load i32, ptr %T9
%T27 = add i32 %T26, 1
store i32 %T27, ptr %T9
br label %L10
L12:
%T28 = load ptr, ptr %T4
ret ptr %T28
%T29 = alloca ptr
ret ptr %T29
}
define void @printaMatriz(ptr %T30, i32 %T32, i32 %T34) {
%T31 = alloca ptr
store ptr %T30, ptr %T31
%T33 = alloca i32
store i32 %T32, ptr %T33
%T35 = alloca i32
store i32 %T34, ptr %T35
%T36 = alloca i32
store i32 0, ptr %T36
br label %L37
L37:
%T40 = load i32, ptr %T36
%T41 = load i32, ptr %T33
%T42 = icmp slt i32 %T40, %T41
%T43 = zext i1 %T42 to i32
%T44 = icmp ne i32 %T43, 0
br i1 %T44, label %L38, label %L39
L38:
%T45 = alloca i32
store i32 0, ptr %T45
br label %L46
L46:
%T49 = load i32, ptr %T45
%T50 = load i32, ptr %T35
%T51 = icmp slt i32 %T49, %T50
%T52 = zext i1 %T51 to i32
%T53 = icmp ne i32 %T52, 0
br i1 %T53, label %L47, label %L48
L47:
%T54 = load ptr, ptr %T31
%T55 = load i32, ptr %T36
%T57 = sext i32 %T55 to i64
%T56 = getelementptr inbounds ptr, ptr %T54, i64 %T57
%T58 = load ptr, ptr %T56
%T59 = load i32, ptr %T45
%T61 = sext i32 %T59 to i64
%T60 = getelementptr inbounds i32, ptr %T58, i64 %T61
%T62 = load i32, ptr %T60
call void @printI(i32 %T62)
%T63 = load i32, ptr %T45
%T64 = add i32 %T63, 1
store i32 %T64, ptr %T45
br label %L46
L48:
%T65 = load i32, ptr %T36
%T66 = add i32 %T65, 1
store i32 %T66, ptr %T36
br label %L37
L39:
ret void
}
define i32 @main() {
%T68 = call ptr @criaMatriz(i32 2, i32 2)
%T67 = alloca ptr
store ptr %T68, ptr %T67
%T69 = load ptr, ptr %T67
%T71 = sext i32 0 to i64
%T70 = getelementptr inbounds ptr, ptr %T69, i64 %T71
%T72 = load ptr, ptr %T70
%T74 = sext i32 0 to i64
%T73 = getelementptr inbounds i32, ptr %T72, i64 %T74
store i32 1, ptr %T73
%T75 = load ptr, ptr %T67
%T77 = sext i32 0 to i64
%T76 = getelementptr inbounds ptr, ptr %T75, i64 %T77
%T78 = load ptr, ptr %T76
%T80 = sext i32 1 to i64
%T79 = getelementptr inbounds i32, ptr %T78, i64 %T80
store i32 0, ptr %T79
%T81 = load ptr, ptr %T67
%T83 = sext i32 1 to i64
%T82 = getelementptr inbounds ptr, ptr %T81, i64 %T83
%T84 = load ptr, ptr %T82
%T86 = sext i32 0 to i64
%T85 = getelementptr inbounds i32, ptr %T84, i64 %T86
store i32 0, ptr %T85
%T87 = load ptr, ptr %T67
%T89 = sext i32 1 to i64
%T88 = getelementptr inbounds ptr, ptr %T87, i64 %T89
%T90 = load ptr, ptr %T88
%T92 = sext i32 1 to i64
%T91 = getelementptr inbounds i32, ptr %T90, i64 %T92
store i32 1, ptr %T91
%T93 = load ptr, ptr %T67
call void @printaMatriz(ptr %T93, i32 2, i32 2)
ret i32 0
}
