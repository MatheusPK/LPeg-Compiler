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
%T18 = load i32, ptr %T3
%T20 = mul i32 4, %T18
%T21 = sext i32 %T20 to i64
%T19 = call ptr @malloc(i64 %T21)
%T22 = load i32, ptr %T9
%T24 = sext i32 %T22 to i64
%T25 = load ptr, ptr %T4
%T23 = getelementptr inbounds ptr, ptr %T25, i64 %T24
store ptr %T19, ptr %T23
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
%T58 = load i32, ptr %T45
%T60 = sext i32 %T58 to i64
%T61 = load ptr, ptr %T56
%T59 = getelementptr inbounds i32, ptr %T61, i64 %T60
%T62 = load i32, ptr %T59
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
%T70 = sext i32 0 to i64
%T71 = load ptr, ptr %T67
%T69 = getelementptr inbounds ptr, ptr %T71, i64 %T70
%T73 = sext i32 0 to i64
%T74 = load ptr, ptr %T69
%T72 = getelementptr inbounds i32, ptr %T74, i64 %T73
store i32 1, ptr %T72
%T76 = sext i32 0 to i64
%T77 = load ptr, ptr %T67
%T75 = getelementptr inbounds ptr, ptr %T77, i64 %T76
%T79 = sext i32 1 to i64
%T80 = load ptr, ptr %T75
%T78 = getelementptr inbounds i32, ptr %T80, i64 %T79
store i32 0, ptr %T78
%T82 = sext i32 1 to i64
%T83 = load ptr, ptr %T67
%T81 = getelementptr inbounds ptr, ptr %T83, i64 %T82
%T85 = sext i32 0 to i64
%T86 = load ptr, ptr %T81
%T84 = getelementptr inbounds i32, ptr %T86, i64 %T85
store i32 0, ptr %T84
%T88 = sext i32 1 to i64
%T89 = load ptr, ptr %T67
%T87 = getelementptr inbounds ptr, ptr %T89, i64 %T88
%T91 = sext i32 1 to i64
%T92 = load ptr, ptr %T87
%T90 = getelementptr inbounds i32, ptr %T92, i64 %T91
store i32 1, ptr %T90
%T93 = load ptr, ptr %T67
call void @printaMatriz(ptr %T93, i32 2, i32 2)
ret i32 0
}
