; Generated by Isabelle/LLVM-shallow
target datalayout = "e-m:e-p:64:64:64-a:0:64-n8:16:32:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f16:16:16-f32:32:32-f64:64:64-f128:128:128"
target triple = "x86_64-pc-linux-gnu"

%list_cell_i1 = type { i1, %list_cell_i1* }



attributes #0 = { strictfp }

define %list_cell_i1 @LLVM_Examples_llist_append(i1 %x, %list_cell_i1* %l) #0 {

  start:
    %r = insertvalue %list_cell_i1 zeroinitializer, i1 %x, 0
    %x1 = insertvalue %list_cell_i1 %r, %list_cell_i1* %l, 1
    ret %list_cell_i1 %x1
}
