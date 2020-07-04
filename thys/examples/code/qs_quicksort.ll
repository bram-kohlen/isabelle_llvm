; Generated by Isabelle/LLVM-shallow
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"






define i64 @LLVM_Examples_qs_partition(i64* %A, i64 %lo, i64 %hi) {

  start:
    %hi1 = sub i64 %hi, 1
    %xa = getelementptr i64, i64* %A, i64 %hi1
    %pivot = load i64, i64* %xa
    %xb = insertvalue { i64, i64 } zeroinitializer, i64 %lo, 0
    %xc = insertvalue { i64, i64 } %xb, i64 %lo, 1
    br label %while_start

  while_start:
    %xaa = phi { i64, i64 } [ %x2, %ctd_if ], [ %xc, %start ]
    %i = extractvalue { i64, i64 } %xaa, 0
    %s = extractvalue { i64, i64 } %xaa, 1
    %x = icmp ult i64 %i, %hi1
    br i1 %x, label %while_body, label %while_end

  while_body:
    %i1 = extractvalue { i64, i64 } %xaa, 0
    %s1 = extractvalue { i64, i64 } %xaa, 1
    %xba = getelementptr i64, i64* %A, i64 %i1
    %Aj = load i64, i64* %xba
    %tmpa = icmp ult i64 %Aj, %pivot
    br i1 %tmpa, label %then, label %else

  then:
    %tmpaa = icmp ne i64 %s1, %i1
    br i1 %tmpaa, label %thena, label %elsea

  thena:
    %xca = getelementptr i64, i64* %A, i64 %s1
    %xd = load i64, i64* %xca
    %xe = getelementptr i64, i64* %A, i64 %i1
    %y = load i64, i64* %xe
    %p = getelementptr i64, i64* %A, i64 %s1
    store i64 %y, i64* %p
    %pa = getelementptr i64, i64* %A, i64 %i1
    store i64 %xd, i64* %pa
    br label %ctd_ifa

  elsea:
    br label %ctd_ifa

  ctd_ifa:
    %x1 = add i64 %s1, 1
    br label %ctd_if

  else:
    br label %ctd_if

  ctd_if:
    %sa = phi i64 [ %s1, %else ], [ %x1, %ctd_ifa ]
    %ia = add i64 %i1, 1
    %xca1 = insertvalue { i64, i64 } zeroinitializer, i64 %ia, 0
    %x2 = insertvalue { i64, i64 } %xca1, i64 %sa, 1
    br label %while_start

  while_end:
    %uu = extractvalue { i64, i64 } %xaa, 0
    %i2 = extractvalue { i64, i64 } %xaa, 1
    %tmpa1 = icmp ne i64 %i2, %hi1
    br i1 %tmpa1, label %thenb, label %elseb

  thenb:
    %xba1 = getelementptr i64, i64* %A, i64 %i2
    %xca2 = load i64, i64* %xba1
    %xd1 = getelementptr i64, i64* %A, i64 %hi1
    %y1 = load i64, i64* %xd1
    %p1 = getelementptr i64, i64* %A, i64 %i2
    store i64 %y1, i64* %p1
    %pa1 = getelementptr i64, i64* %A, i64 %hi1
    store i64 %xca2, i64* %pa1
    br label %ctd_ifb

  elseb:
    br label %ctd_ifb

  ctd_ifb:
    ret i64 %i2
}

define void @qs_quicksort(i64* %A, i64 %lo, i64 %hi) {

  start:
    %x = insertvalue { i64, i64 } zeroinitializer, i64 %lo, 0
    %xa = insertvalue { i64, i64 } %x, i64 %hi, 1
    call void @LLVM_Examples_qs_quicksort_f_05077276 (i64* %A, { i64, i64 } %xa)
    ret void
}

define void @LLVM_Examples_qs_quicksort_f_05077276(i64* %A, { i64, i64 } %x) {

  start:
    %lo = extractvalue { i64, i64 } %x, 0
    %hi = extractvalue { i64, i64 } %x, 1
    %tmp = icmp ult i64 %lo, %hi
    br i1 %tmp, label %then, label %else

  then:
    %p = call i64 @LLVM_Examples_qs_partition (i64* %A, i64 %lo, i64 %hi)
    %tmpa = sub i64 %p, 1
    %xd = insertvalue { i64, i64 } zeroinitializer, i64 %lo, 0
    %xe = insertvalue { i64, i64 } %xd, i64 %tmpa, 1
    call void @LLVM_Examples_qs_quicksort_f_05077276 (i64* %A, { i64, i64 } %xe)
    %tmpaa = add i64 %p, 1
    %xg = insertvalue { i64, i64 } zeroinitializer, i64 %tmpaa, 0
    %x1 = insertvalue { i64, i64 } %xg, i64 %hi, 1
    call void @LLVM_Examples_qs_quicksort_f_05077276 (i64* %A, { i64, i64 } %x1)
    br label %ctd_if

  else:
    br label %ctd_if

  ctd_if:
    ret void
}
