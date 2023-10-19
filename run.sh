cat input.txt | lua compiler.lua > temp.ll
llc temp.ll
clang temp.s
./a.out