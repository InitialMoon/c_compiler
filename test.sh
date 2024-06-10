#!/usr/bin/env fish
# 复制到build文件夹执行

# Directory for the standard outputs
set standard_output_dir "../../answers"

# Loop through e01.c to e08.c
for i in (seq -w 1 8)
    set filename "../../input/e0$i.c"

    # Step 1: Compile .c file to res.s using Compilerlab3
    echo "Compiling $filename to res.s"
    ./Compilerlab4 $filename > ans/res$i.s
    if test $status -ne 0
        echo "Compilation failed for $filename"
        continue
    end

    # Step 2: Compile res.s to executable res using gcc
    echo "Compiling res.s to executable res$i"
    gcc -m32 -no-pie -g ans/res$i.s -o res
    if test $status -ne 0
        echo "GCC compilation failed for $filename"
        continue
    end

    # Step 3: Run the executable res
    echo "Running executable res"
    ./res > ans/$i.output
    if test $status -ne 0
        echo "Execution failed for $filename"
        continue
    end

    # Step 4: Compare outputs
    set expected_output_file "$standard_output_dir/e0$i.ans"
    diff ans/$i.output $expected_output_file > /dev/null
    if test $status -ne 0
        echo "Output mismatch for $filename"
    else
        echo "Output match for $filename"
    end
end

# Summary of mismatched outputs
echo "Summary of mismatched outputs:"
for i in (seq -w 1 8)
    set expected_output_file "$standard_output_dir/e0$i.ans"
    diff ans/$i.output $expected_output_file > /dev/null
    if test $status -ne 0
        echo "Output mismatch for e0$i.c"
    end
end