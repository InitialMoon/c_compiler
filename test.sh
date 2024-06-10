#!/usr/bin/env fish
# 复制到build文件夹执行

# Loop through e01.c to e08.c
for i in (seq -w 1 8)
    set filename "../../input/e$i.c"

    # Step 1: Compile .c file to res.s using Compilerlab3
    echo "Compiling $filename to res.s"
    ./Compilerlab3 $filename > res.s
    if test $status -ne 0
        echo "Compilation failed for $filename"
        continue
    end

    # Step 2: Compile res.s to executable res using gcc
    echo "Compiling res.s to executable res"
    gcc -m32 -no-pie -g res.s -o res
    if test $status -ne 0
        echo "GCC compilation failed for $filename"
        continue
    end

    # Step 3: Run the executable res
    echo "Running executable res"
    ./res > ans/$i.output
    if test $status -ne 0
        echo "Execution failed for $filename"
     

