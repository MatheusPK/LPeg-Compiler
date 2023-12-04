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


define i32 @bigger(ptr %T0, i32 %T2) {
%T1 = alloca ptr
store ptr %T0, ptr %T1
%T3 = alloca i32
store i32 %T2, ptr %T3
%T4 = alloca i32
store i32 0, ptr %T4
%T6 = load i32, ptr %T4
%T5 = alloca i32
store i32 %T6, ptr %T5
br label %L7
L7:
%T10 = load i32, ptr %T4
%T11 = load i32, ptr %T3
%T12 = sub i32 %T11, 1
%T13 = icmp slt i32 %T10, %T12
%T14 = zext i1 %T13 to i32
%T15 = icmp ne i32 %T14, 0
br i1 %T15, label %L8, label %L9
L8:
%T19 = load ptr, ptr %T1
%T20 = load i32, ptr %T4
%T22 = sext i32 %T20 to i64
%T21 = getelementptr inbounds i32, ptr %T19, i64 %T22
%T23 = load i32, ptr %T21
%T24 = load ptr, ptr %T1
%T25 = load i32, ptr %T4
%T26 = add i32 %T25, 1
%T28 = sext i32 %T26 to i64
%T27 = getelementptr inbounds i32, ptr %T24, i64 %T28
%T29 = load i32, ptr %T27
%T30 = icmp slt i32 %T23, %T29
%T31 = zext i1 %T30 to i32
%T32 = icmp ne i32 %T31, 0
br i1 %T32, label %L16, label %L18
L16:
%T33 = load i32, ptr %T4
%T34 = add i32 %T33, 1
store i32 %T34, ptr %T5
br label %L18
L18:
%T35 = load i32, ptr %T4
%T36 = add i32 %T35, 1
store i32 %T36, ptr %T4
br label %L7
L9:
%T37 = load i32, ptr %T5
ret i32 %T37
ret i32 0
}
define void @arrayAoQuadrado(ptr %T38, i32 %T40) {
%T39 = alloca ptr
store ptr %T38, ptr %T39
%T41 = alloca i32
store i32 %T40, ptr %T41
%T42 = alloca i32
store i32 0, ptr %T42
br label %L43
L43:
%T46 = load i32, ptr %T42
%T47 = load i32, ptr %T41
%T48 = icmp slt i32 %T46, %T47
%T49 = zext i1 %T48 to i32
%T50 = icmp ne i32 %T49, 0
br i1 %T50, label %L44, label %L45
L44:
%T51 = load ptr, ptr %T39
%T52 = load i32, ptr %T42
%T54 = sext i32 %T52 to i64
%T53 = getelementptr inbounds i32, ptr %T51, i64 %T54
%T55 = load i32, ptr %T53
%T56 = load ptr, ptr %T39
%T57 = load i32, ptr %T42
%T59 = sext i32 %T57 to i64
%T58 = getelementptr inbounds i32, ptr %T56, i64 %T59
%T60 = load i32, ptr %T58
%T61 = mul i32 %T55, %T60
%T62 = load i32, ptr %T42
%T64 = sext i32 %T62 to i64
%T65 = load ptr, ptr %T39
%T63 = getelementptr inbounds i32, ptr %T65, i64 %T64
store i32 %T61, ptr %T63
%T66 = load i32, ptr %T42
%T67 = add i32 %T66, 1
store i32 %T67, ptr %T42
br label %L43
L45:
ret void
}
define void @imprimeArray(ptr %T68, i32 %T70) {
%T69 = alloca ptr
store ptr %T68, ptr %T69
%T71 = alloca i32
store i32 %T70, ptr %T71
%T72 = alloca i32
store i32 0, ptr %T72
br label %L73
L73:
%T76 = load i32, ptr %T72
%T77 = load i32, ptr %T71
%T78 = icmp slt i32 %T76, %T77
%T79 = zext i1 %T78 to i32
%T80 = icmp ne i32 %T79, 0
br i1 %T80, label %L74, label %L75
L74:
%T81 = load ptr, ptr %T69
%T82 = load i32, ptr %T72
%T84 = sext i32 %T82 to i64
%T83 = getelementptr inbounds i32, ptr %T81, i64 %T84
%T85 = load i32, ptr %T83
call void @printI(i32 %T85)
%T86 = load i32, ptr %T72
%T87 = add i32 %T86, 1
store i32 %T87, ptr %T72
br label %L73
L75:
ret void
}
define i32 @main() {
%T88 = alloca ptr
%T90 = mul i32 4, 10
%T91 = sext i32 %T90 to i64
%T89 = call ptr @malloc(i64 %T91)
store ptr %T89, ptr %T88
%T93 = sext i32 0 to i64
%T94 = load ptr, ptr %T88
%T92 = getelementptr inbounds i32, ptr %T94, i64 %T93
store i32 1, ptr %T92
%T96 = sext i32 1 to i64
%T97 = load ptr, ptr %T88
%T95 = getelementptr inbounds i32, ptr %T97, i64 %T96
store i32 2, ptr %T95
%T99 = sext i32 2 to i64
%T100 = load ptr, ptr %T88
%T98 = getelementptr inbounds i32, ptr %T100, i64 %T99
store i32 3, ptr %T98
%T102 = sext i32 3 to i64
%T103 = load ptr, ptr %T88
%T101 = getelementptr inbounds i32, ptr %T103, i64 %T102
store i32 4, ptr %T101
%T105 = sext i32 4 to i64
%T106 = load ptr, ptr %T88
%T104 = getelementptr inbounds i32, ptr %T106, i64 %T105
store i32 5, ptr %T104
%T108 = sext i32 5 to i64
%T109 = load ptr, ptr %T88
%T107 = getelementptr inbounds i32, ptr %T109, i64 %T108
store i32 6, ptr %T107
%T111 = sext i32 6 to i64
%T112 = load ptr, ptr %T88
%T110 = getelementptr inbounds i32, ptr %T112, i64 %T111
store i32 7, ptr %T110
%T114 = sext i32 7 to i64
%T115 = load ptr, ptr %T88
%T113 = getelementptr inbounds i32, ptr %T115, i64 %T114
store i32 8, ptr %T113
%T117 = sext i32 8 to i64
%T118 = load ptr, ptr %T88
%T116 = getelementptr inbounds i32, ptr %T118, i64 %T117
store i32 9, ptr %T116
%T120 = sext i32 9 to i64
%T121 = load ptr, ptr %T88
%T119 = getelementptr inbounds i32, ptr %T121, i64 %T120
store i32 10, ptr %T119
%T122 = load ptr, ptr %T88
%T123 = load ptr, ptr %T88
%T124 = call i32 @bigger(ptr %T123, i32 10)
%T126 = sext i32 %T124 to i64
%T125 = getelementptr inbounds i32, ptr %T122, i64 %T126
%T127 = load i32, ptr %T125
call void @printI(i32 %T127)
%T128 = load ptr, ptr %T88
call void @imprimeArray(ptr %T128, i32 10)
%T129 = load ptr, ptr %T88
call void @arrayAoQuadrado(ptr %T129, i32 10)
%T130 = load ptr, ptr %T88
call void @imprimeArray(ptr %T130, i32 10)
ret i32 0
}
