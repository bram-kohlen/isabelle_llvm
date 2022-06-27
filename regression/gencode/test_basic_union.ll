; Generated by Isabelle/LLVM-shallow
target datalayout = "e-m:e-p:64:64:64-a:0:64-n8:16:32:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f16:16:16-f32:32:32-f64:64:64-f128:128:128"
target triple = "x86_64-pc-linux-gnu"





attributes #0 = { strictfp }

define double @LLVM_Examples_ll_sum_mk_left(i32 %x) #0 {

  start:
    %a = alloca i32
    store i32 %x, i32* %a
    %b = bitcast i32* %a to double*
    %x1 = load double, double* %b
    ret double %x1
}

define double @LLVM_Examples_ll_sum_mk_right(double %x) #0 {

  start:
    %a = alloca double
    store double %x, double* %a
    %b = bitcast double* %a to double*
    %x1 = load double, double* %b
    ret double %x1
}

define i32 @LLVM_Examples_ll_sum_extr_left(double %x) #0 {

  start:
    %a = alloca double
    store double %x, double* %a
    %b = bitcast double* %a to i32*
    %x1 = load i32, i32* %b
    ret i32 %x1
}

define double @LLVM_Examples_ll_sum_extr_right(double %x) #0 {

  start:
    %a = alloca double
    store double %x, double* %a
    %b = bitcast double* %a to double*
    %x1 = load double, double* %b
    ret double %x1
}
