; Generated by Isabelle/LLVM-shallow
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"



declare void @isabelle_llvm_free(i8*)
declare i8* @isabelle_llvm_calloc(i64, i64)


define void @LLVM_DS_Array_arraycpy(i64* %dst, i64* %src, i64 %n) {

  start:
    br label %while_start

  while_start:
    %i = phi i64 [ %x1, %while_body ], [ 0, %start ]
    %x = icmp ult i64 %i, %n
    br i1 %x, label %while_body, label %while_end

  while_body:
    %xa = getelementptr i64, i64* %src, i64 %i
    %xaa = load i64, i64* %xa
    %p = getelementptr i64, i64* %dst, i64 %i
    store i64 %xaa, i64* %p
    %x1 = add i64 %i, 1
    br label %while_start

  while_end:
    ret void
}

define i64 @cr_big_al(i64 %n) {

  start:
    %tmp = icmp eq i64 8, 0
    br i1 %tmp, label %then, label %else

  then:
    br label %ctd_if

  else:
    %t = getelementptr i64, i64* null, i64 1
    %a = ptrtoint i64* %t to i64
    %b = call i8* @isabelle_llvm_calloc (i64 8, i64 %a)
    %x = bitcast i8* %b to i64*
    br label %ctd_if

  ctd_if:
    %aa = phi i64* [ %x, %else ], [ null, %then ]
    %xb = insertvalue { i64, { i64, i64* } } zeroinitializer, i64 0, 0
    %xca = insertvalue { i64, i64* } zeroinitializer, i64 8, 0
    %tmpba = insertvalue { i64, i64* } %xca, i64* %aa, 1
    %aaa = insertvalue { i64, { i64, i64* } } %xb, { i64, i64* } %tmpba, 1
    %xea = insertvalue { i64, { i64, { i64, i64* } } } zeroinitializer, i64 %n, 0
    %xfa = insertvalue { i64, { i64, { i64, i64* } } } %xea, { i64, { i64, i64* } } %aaa, 1
    br label %while_start

  while_start:
    %xaa = phi { i64, { i64, { i64, i64* } } } [ %x5, %ctd_ifa ], [ %xfa, %ctd_if ]
    %n1 = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 0
    %ab = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 1
    %x1 = icmp ult i64 0, %n1
    br i1 %x1, label %while_body, label %while_end

  while_body:
    %n2 = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 0
    %ab1 = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 1
    %l = extractvalue { i64, { i64, i64* } } %ab1, 0
    %xba = extractvalue { i64, { i64, i64* } } %ab1, 1
    %ca = extractvalue { i64, i64* } %xba, 0
    %ac = extractvalue { i64, i64* } %xba, 1
    %lb = add i64 %l, 1
    %lc = extractvalue { i64, { i64, i64* } } %ab1, 0
    %xcaa = extractvalue { i64, { i64, i64* } } %ab1, 1
    %cb = extractvalue { i64, i64* } %xcaa, 0
    %ad = extractvalue { i64, i64* } %xcaa, 1
    %cok = icmp sle i64 %lb, %cb
    br i1 %cok, label %thena, label %elsea

  thena:
    %xdaa = insertvalue { i64, { i64, i64* } } zeroinitializer, i64 %lc, 0
    %xsa = insertvalue { i64, i64* } zeroinitializer, i64 %cb, 0
    %tmpda = insertvalue { i64, i64* } %xsa, i64* %ad, 1
    %x2 = insertvalue { i64, { i64, i64* } } %xdaa, { i64, i64* } %tmpda, 1
    br label %ctd_ifa

  elsea:
    %xra = insertvalue { i64, i64* } zeroinitializer, i64 %cb, 0
    %tmpcb = insertvalue { i64, i64* } %xra, i64* %ad, 1
    %xsa1 = insertvalue { i64, { i64, i64* } } zeroinitializer, i64 %lc, 0
    %x3 = insertvalue { i64, { i64, i64* } } %xsa1, { i64, i64* } %tmpcb, 1
    %x4 = call { i64, { i64, i64* } } @LLVM_DS_Array_List_arl_resize (i64 %lb, { i64, { i64, i64* } } %x3)
    br label %ctd_ifa

  ctd_ifa:
    %al = phi { i64, { i64, i64* } } [ %x4, %elsea ], [ %x2, %thena ]
    %ld = extractvalue { i64, { i64, i64* } } %al, 0
    %xdaa1 = extractvalue { i64, { i64, i64* } } %al, 1
    %cc = extractvalue { i64, i64* } %xdaa1, 0
    %ae = extractvalue { i64, i64* } %xdaa1, 1
    %p = getelementptr i64, i64* %ae, i64 %ld
    store i64 %n2, i64* %p
    %le = add i64 %ld, 1
    %xeaa = insertvalue { i64, { i64, i64* } } zeroinitializer, i64 %le, 0
    %xxa = insertvalue { i64, i64* } zeroinitializer, i64 %cc, 0
    %tmpda1 = insertvalue { i64, i64* } %xxa, i64* %ae, 1
    %af = insertvalue { i64, { i64, i64* } } %xeaa, { i64, i64* } %tmpda1, 1
    %na = sub i64 %n2, 1
    %xfaa = insertvalue { i64, { i64, { i64, i64* } } } zeroinitializer, i64 %na, 0
    %x5 = insertvalue { i64, { i64, { i64, i64* } } } %xfaa, { i64, { i64, i64* } } %af, 1
    br label %while_start

  while_end:
    %uu = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 0
    %ab2 = extractvalue { i64, { i64, { i64, i64* } } } %xaa, 1
    %xia = insertvalue { i64, i64 } zeroinitializer, i64 %n, 0
    %xja = insertvalue { i64, i64 } %xia, i64 0, 1
    br label %while_starta

  while_starta:
    %xba1 = phi { i64, i64 } [ %x7, %while_bodya ], [ %xja, %while_end ]
    %n3 = extractvalue { i64, i64 } %xba1, 0
    %s = extractvalue { i64, i64 } %xba1, 1
    %x6 = icmp ult i64 0, %n3
    br i1 %x6, label %while_bodya, label %while_enda

  while_bodya:
    %n4 = extractvalue { i64, i64 } %xba1, 0
    %s1 = extractvalue { i64, i64 } %xba1, 1
    %na1 = sub i64 %n4, 1
    %l1 = extractvalue { i64, { i64, i64* } } %ab2, 0
    %xcaa1 = extractvalue { i64, { i64, i64* } } %ab2, 1
    %ca1 = extractvalue { i64, i64* } %xcaa1, 0
    %ac1 = extractvalue { i64, i64* } %xcaa1, 1
    %xdaa2 = getelementptr i64, i64* %ac1, i64 %na1
    %xeaa1 = load i64, i64* %xdaa2
    %sa = add i64 %xeaa1, %s1
    %xfaa1 = insertvalue { i64, i64 } zeroinitializer, i64 %na1, 0
    %x7 = insertvalue { i64, i64 } %xfaa1, i64 %sa, 1
    br label %while_starta

  while_enda:
    %uua = extractvalue { i64, i64 } %xba1, 0
    %x8 = extractvalue { i64, i64 } %xba1, 1
    ret i64 %x8
}

define void @LLVM_DS_NArray_narray_free(i64* %p) {

  start:
    %a = ptrtoint i64* %p to i64
    %b = ptrtoint i64* null to i64
    %tmp = icmp eq i64 %a, %b
    br i1 %tmp, label %then, label %else

  then:
    br label %ctd_if

  else:
    %c = bitcast i64* %p to i8*
    call void @isabelle_llvm_free (i8* %c)
    br label %ctd_if

  ctd_if:
    ret void
}

define { i64, { i64, i64* } } @LLVM_DS_Array_List_arl_resize(i64 %c, { i64, { i64, i64* } } %al) {

  start:
    %l = extractvalue { i64, { i64, i64* } } %al, 0
    %xb = extractvalue { i64, { i64, i64* } } %al, 1
    %c1 = extractvalue { i64, i64* } %xb, 0
    %a = extractvalue { i64, i64* } %xb, 1
    %r = sub i64 0, 1
    %max = lshr i64 %r, 1
    %maxa = udiv i64 %max, 2
    %b = icmp ule i64 %c1, %maxa
    br i1 %b, label %then, label %else

  then:
    %ca = mul i64 %c1, 2
    %cok = icmp sle i64 %c, %ca
    br i1 %cok, label %thena, label %elsea

  thena:
    br label %ctd_ifa

  elsea:
    br label %ctd_ifa

  ctd_ifa:
    %x = phi i64 [ %c, %elsea ], [ %ca, %thena ]
    br label %ctd_if

  else:
    br label %ctd_if

  ctd_if:
    %ca1 = phi i64 [ %c, %else ], [ %x, %ctd_ifa ]
    %tmpa = icmp eq i64 %ca1, 0
    br i1 %tmpa, label %thenb, label %elseb

  thenb:
    br label %ctd_ifb

  elseb:
    %t = getelementptr i64, i64* null, i64 1
    %d = ptrtoint i64* %t to i64
    %e = call i8* @isabelle_llvm_calloc (i64 %ca1, i64 %d)
    %x1 = bitcast i8* %e to i64*
    br label %ctd_ifb

  ctd_ifb:
    %a1 = phi i64* [ %x1, %elseb ], [ null, %thenb ]
    call void @LLVM_DS_Array_arraycpy (i64* %a1, i64* %a, i64 %l)
    call void @LLVM_DS_NArray_narray_free (i64* %a)
    %xaa = insertvalue { i64, { i64, i64* } } zeroinitializer, i64 %l, 0
    %xja = insertvalue { i64, i64* } zeroinitializer, i64 %ca1, 0
    %tmpca = insertvalue { i64, i64* } %xja, i64* %a1, 1
    %x2 = insertvalue { i64, { i64, i64* } } %xaa, { i64, i64* } %tmpca, 1
    ret { i64, { i64, i64* } } %x2
}
