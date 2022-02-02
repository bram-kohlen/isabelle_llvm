theory Sorting_Ex_Array_Idxs
imports Sorting_Introsort
begin

subsection \<open>Compare Indexes into Value Array\<close>

term nao_assn
term narray_assn

lemma narray_assn_alt: "narray_assn 
  = mk_assn (\<lambda>xs p. if xs=[] then \<up>(p=null) else \<upharpoonleft>LLVM_DS_Array.array_assn xs p)"
  by (auto simp: narray_assn_def fun_eq_iff split: list.splits)

definition "woarray_slice_diff_assn n p \<equiv> if n=0 then \<up>(p=null) else \<upharpoonleft>array_base_assn n p"  
  

find_theorems abase

context begin
  interpretation llvm_prim_mem_setup .
  (* TODO: Move *)
  lemma ll_malloc_tag_null[sep_algebra_simps]: "ll_malloc_tag n null = sep_false"
    unfolding ll_malloc_tag_def null_def llvm_blockp_def
    by simp


  (* TODO: Move *)
  lemma array_base_assn_simps[sep_algebra_simps]:
    "\<upharpoonleft>array_base_assn 0 null = \<box>"
    "\<upharpoonleft>array_base_assn 0 p = \<up>(p=null)"
    "\<upharpoonleft>array_base_assn n null = \<up>(n=0)"
    unfolding array_base_assn_def
    by (auto simp: sep_algebra_simps) 

end  
  

lemma wo_array_assn_to_slice: "woarray_assn A xs p = 
  (woarray_slice_assn A xs p ** woarray_slice_diff_assn (length xs) p)"  
  unfolding woarray_assn_conv eoarray_assn_def Proto_EOArray.nao_assn_def
     array_assn_split hr_comp_def
  apply (clarsimp simp add: sep_algebra_simps fun_eq_iff)
  unfolding woarray_slice_assn_conv eoarray_slice_assn_def sao_assn_def woarray_slice_diff_assn_def 
  apply (cases "xs=[]"; cases "p=null"; simp)
  subgoal by (auto simp: sep_algebra_simps)
  subgoal by (clarsimp simp: sep_algebra_simps)
  subgoal by (clarsimp simp: sep_algebra_simps)
  apply (clarsimp simp: sep_algebra_simps sep_conj_c)
  apply safe
  subgoal for s xs'
    apply (cases "length xs = length xs'"; simp)
    apply auto
    done
  subgoal for s xs'
    apply (cases "length xs = length xs'"; cases "xs'\<noteq>[]"; simp)
    apply auto
    done
  done      

lemma pure_part_invalid_assn: "pure_part (invalid_assn A x xi) \<Longrightarrow> invalid_assn A x xi = \<box>"
  unfolding invalid_assn_def by (auto simp: sep_algebra_simps)


lemma wo_array_sort_adapt: 
  assumes LP: "\<And>p xs l h. s p xs l h \<le>\<^sub>n SPEC (\<lambda>xs'. length xs'=length xs)"
  assumes A: "(si,uncurry3 s) \<in> [\<lambda>_. True]\<^sub>c A\<^sup>k *\<^sub>a (woarray_slice_assn elem_assn)\<^sup>d *\<^sub>a size_assn\<^sup>k *\<^sub>a size_assn\<^sup>k \<rightarrow> (woarray_slice_assn elem_assn) [\<lambda>(((_, ai), _), _) r. r = ai]\<^sub>c"
  shows "(si,uncurry3 s) \<in> [\<lambda>_. True]\<^sub>c A\<^sup>k *\<^sub>a (woarray_assn elem_assn)\<^sup>d *\<^sub>a size_assn\<^sup>k *\<^sub>a size_assn\<^sup>k \<rightarrow> woarray_assn elem_assn [\<lambda>(((_, ai), _), _) r. r = ai]\<^sub>c"
proof -
  {
    fix p xs l h xs'
    assume "nofail (s p xs l h)" "RETURN xs' \<le> s p xs l h"
    hence "length xs' = length xs"
      using LP by (auto simp: pw_leof_iff pw_le_iff)
  
  } note [simp] = this

  show ?thesis
    apply sepref_to_hoare
    subgoal for h hi l li xs xsi p pi
      unfolding wo_array_assn_to_slice
      apply clarsimp
      supply R = A[to_hnr, simplified, THEN hn_refineD, unfolded hn_ctxt_def]
      supply [vcg_rules] = R
      supply [simp] = pure_def
      apply vcg
      (* TODO: Hack! Handle the hn-invalid cleanly *)
      apply vcg_try_solve
      apply (auto dest!: pure_part_split_conj simp: pure_part_invalid_assn sep_algebra_simps FRI_END_def FRAME_INFER_def)
      done
    done
  
qed      
    
  
lemma woarray_iterator: "random_access_iterator (woarray_assn snat_assn) (eoarray_assn snat_assn) snat_assn 
  Mreturn Mreturn
  eo_extract_impl
  array_upd"  
  apply unfold_locales
  apply (rule eo_hnr_dep)+
  done
  



lemma list_assn_oelem_assn_map_Some: 
  "\<upharpoonleft>(list_assn (oelem_assn A)) (map Some xs) xsi 
  = \<upharpoonleft>(list_assn A) xs xsi"
  apply (cases "length xs = length xsi"; simp?)
  apply (induction xs xsi rule: list_induct2)
  by (auto)
  

lemma nao_to_wo_assn: "\<upharpoonleft>(nao_assn A Map.empty) = woarray_assn (\<upharpoonleft>A)"
  unfolding woarray_assn_conv eoarray_assn_def 
  unfolding nao_assn_def Proto_EOArray.nao_assn_def hr_comp_def
  apply (auto simp: sep_algebra_simps fun_eq_iff list_assn_oelem_assn_map_Some)
  unfolding list_assn_def
  apply (auto simp: sep_algebra_simps dest: sym)
  done

lemma wo_to_nao_assn: 
  "woarray_assn A = \<upharpoonleft>(nao_assn (mk_assn A) Map.empty)"
  unfolding nao_to_wo_assn sel_mk_assn
  ..
    
  
locale idxs_comp = INNER: sort_impl_context inner_less_eq inner_less inner_less_impl A
  for inner_less_eq inner_less :: "'a \<Rightarrow> 'a \<Rightarrow> bool"
  and inner_less_impl :: "'ai::llvm_rep \<Rightarrow> 'ai \<Rightarrow> 1 word llM"
  and A :: "'a \<Rightarrow> 'ai \<Rightarrow> assn"
begin

  definition idx_cdom :: "'a list \<Rightarrow> nat set" where "idx_cdom vs \<equiv> {0..<length vs}"

  definition "idx_less vs i j \<equiv> (inner_less (vs!i) (vs!j))"

  definition "idx_pcmp vs i j \<equiv> 
    if i=j then RETURN False 
    else INNER.mop_cmp_idxs vs i j"
      
  lemma snat_assn_eq_refine: 
    "\<lbrakk>\<flat>\<^sub>psnat.assn ba bia; \<flat>\<^sub>psnat.assn b bi\<rbrakk> \<Longrightarrow> bia = bi \<longleftrightarrow> ba=b"
    apply (simp add: snat.assn_def)
    by (metis snat_eq_unat_aux2 unsigned_word_eqI)
    
  sepref_register idx_pcmp  
  sepref_def idx_pcmp_impl is "uncurry2 (PR_CONST idx_pcmp)" 
    :: "(woarray_slice_assn A)\<^sup>k *\<^sub>a size_assn\<^sup>k *\<^sub>a size_assn\<^sup>k \<rightarrow>\<^sub>a bool1_assn"
    unfolding PR_CONST_def
    unfolding idx_pcmp_def 
    by sepref
    
    
  interpretation weak_ordering_on_lt "idx_cdom vs" "idx_less vs" 
    apply unfold_locales
    unfolding idx_less_def
    apply (erule INNER.asym)
    apply (erule INNER.itrans)
    done
    
  
  interpretation parameterized_weak_ordering idx_cdom idx_less "PR_CONST idx_pcmp"
    apply unfold_locales
    unfolding idx_pcmp_def PR_CONST_def
    apply refine_vcg
    apply (auto simp: idx_less_def idx_cdom_def)
    done

  sublocale parameterized_sort_impl_context 
    "woarray_assn size_assn" "eoarray_assn size_assn" size_assn 
    Mreturn Mreturn
    eo_extract_impl
    array_upd
    idx_cdom idx_less "PR_CONST idx_pcmp" idx_pcmp_impl "woarray_slice_assn A"
    apply unfold_locales
    apply (rule eo_hnr_dep)+
    unfolding GEN_ALGO_def refines_param_relp_def (* TODO: thm gen_refines_param_relpI *)
    by (rule idx_pcmp_impl.refine)
    
  term introsort_param_impl  
  
  find_theorems introsort_param_impl
  
  
  term arr_assn
  
  thm introsort_param_impl_correct wo_array_sort_adapt
  
    
end






(*
definition idx_less :: "'a::linorder list \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow> bool" where "idx_less vs i j \<equiv> vs!i < vs!j"
definition idx_cdom :: "'a::linorder list \<Rightarrow> nat set" where "idx_cdom vs \<equiv> {0..<length vs}"

definition "idx_pcmp vs i j \<equiv> do {
  ASSERT (i<length vs \<and> j<length vs);
  RETURN (vs!i < vs!j)
}"

sepref_def idx_pcmp_impl is "uncurry2 idx_pcmp" :: 
  "(al_assn snat_assn)\<^sup>k *\<^sub>a size_assn\<^sup>k *\<^sub>a size_assn\<^sup>k \<rightarrow>\<^sub>a bool1_assn"
  unfolding idx_pcmp_def
  by sepref
  

interpretation IDXO: weak_ordering_on_lt "idx_cdom vs" "idx_less vs"
  apply unfold_locales
  unfolding idx_less_def by auto

interpretation IDXO: parameterized_weak_ordering idx_cdom idx_less idx_pcmp
  apply unfold_locales
  unfolding idx_pcmp_def
  apply refine_vcg
  apply (auto simp: idx_less_def idx_cdom_def)
  done

  
  
    
global_interpretation IDXO: parameterized_sort_impl_context 
  "woarray_assn snat_assn" "eoarray_assn snat_assn" snat_assn 
  return return
  eo_extract_impl
  array_upd
  idx_cdom idx_less idx_pcmp idx_pcmp_impl "al_assn snat_assn"
  defines 
          IDXO_is_guarded_insert_impl = IDXO.is_guarded_param_insert_impl
      and IDXO_is_unguarded_insert_impl = IDXO.is_unguarded_param_insert_impl
      and IDXO_unguarded_insertion_sort_impl = IDXO.unguarded_insertion_sort_param_impl
      and IDXO_guarded_insertion_sort_impl = IDXO.guarded_insertion_sort_param_impl
      and IDXO_final_insertion_sort_impl = IDXO.final_insertion_sort_param_impl
      (*and IDXO_mop_lchild_impl  = IDXO.mop_lchild_impl 
      and IDXO_mop_rchild_impl  = IDXO.mop_rchild_impl 
      and IDXO_has_rchild_impl  = IDXO.has_rchild_impl 
      and IDXO_has_lchild_impl  = IDXO.has_lchild_impl *)
      
      and IDXO_pcmpo_idxs_impl  = IDXO.pcmpo_idxs_impl
      and IDXO_pcmpo_v_idx_impl  = IDXO.pcmpo_v_idx_impl
      and IDXO_pcmpo_idx_v_impl  = IDXO.pcmpo_idx_v_impl
      and IDXO_pcmp_idxs_impl  = IDXO.pcmp_idxs_impl
      
      and IDXO_mop_geth_impl    = IDXO.mop_geth_impl  
      and IDXO_mop_seth_impl    = IDXO.mop_seth_impl  
      and IDXO_sift_down_impl   = IDXO.sift_down_impl
      and IDXO_heapify_btu_impl = IDXO.heapify_btu_impl
      and IDXO_heapsort_impl    = IDXO.heapsort_param_impl
      and IDXO_qsp_next_l_impl       = IDXO.qsp_next_l_impl
      and IDXO_qsp_next_h_impl       = IDXO.qsp_next_h_impl
      and IDXO_qs_partition_impl     = IDXO.qs_partition_impl
(*      and IDXO_qs_partitionXXX_impl     = IDXO.qs_partitionXXX_impl *)
      and IDXO_partition_pivot_impl  = IDXO.partition_pivot_impl 
      and IDXO_introsort_aux_impl = IDXO.introsort_aux_param_impl
      and IDXO_introsort_impl        = IDXO.introsort_param_impl
      and IDXO_move_median_to_first_impl = IDXO.move_median_to_first_param_impl
  
  apply unfold_locales
  apply (rule eo_hnr_dep)+
  unfolding GEN_ALGO_def refines_param_relp_def (* TODO: thm gen_refines_param_relpI *)
  by (rule idx_pcmp_impl.refine)
  

(* TODO: This seems to be a quirk in llvm monadify and inline! FIXME! *)  
lemmas [abs_def,llvm_inline] = array_upd_def eo_extract_impl_def
  
(*llvm_deps "IDXO_heapsort_impl :: 32 word ptr \<Rightarrow> _" *)

  
  
  
  
locale pure_eo_adapter =
  fixes elem_assn :: "'a \<Rightarrow> 'ai::llvm_rep \<Rightarrow> assn"  
    and wo_assn :: "'a list \<Rightarrow> 'oi::llvm_rep \<Rightarrow> assn"
    and wo_get_impl :: "'oi \<Rightarrow> 'size::len2 word \<Rightarrow> 'ai llM"
    and wo_set_impl :: "'oi \<Rightarrow> 'size::len2 word \<Rightarrow> 'ai \<Rightarrow> 'oi llM"
  assumes pure[safe_constraint_rules]: "is_pure elem_assn" 
      and get_hnr: "(uncurry wo_get_impl,uncurry mop_list_get) \<in> wo_assn\<^sup>k *\<^sub>a snat_assn\<^sup>k \<rightarrow>\<^sub>a elem_assn"
      and set_hnr: "(uncurry2 wo_set_impl,uncurry2 mop_list_set) 
        \<in> [\<lambda>_.True]\<^sub>c wo_assn\<^sup>d *\<^sub>a snat_assn\<^sup>k *\<^sub>a elem_assn\<^sup>k \<rightarrow> wo_assn [\<lambda>((ai,_),_) r. r=ai]\<^sub>c"
begin      
  
  lemmas [sepref_fr_rules] = get_hnr set_hnr


  definition "only_some_rel \<equiv> {(a, Some a) | a. True} \<union> {(x, None) | x. True}"

  definition "eo_assn \<equiv> hr_comp wo_assn (\<langle>only_some_rel\<rangle>list_rel)"
  
  definition "eo_extract1 p i \<equiv> doN { r \<leftarrow> mop_list_get p i; RETURN (r,p) }"
  sepref_definition eo_extract_impl is "uncurry eo_extract1" 
    :: "wo_assn\<^sup>d *\<^sub>a (snat_assn' TYPE('size))\<^sup>k \<rightarrow>\<^sub>a elem_assn \<times>\<^sub>a wo_assn"
    unfolding eo_extract1_def
    by sepref
     
  lemma mop_eo_extract_aux: "mop_eo_extract p i = doN { r \<leftarrow> mop_list_get p i; ASSERT (r\<noteq>None \<and> i<length p); RETURN (the r, p[i:=None]) }"  
    by (auto simp: pw_eq_iff refine_pw_simps)

  lemma assign_none_only_some_list_rel:
    assumes SR[param]: "(a, a') \<in> \<langle>only_some_rel\<rangle>list_rel" and L: "i < length a'"
      shows "(a, a'[i := None]) \<in> \<langle>only_some_rel\<rangle>list_rel"
  proof -
    have "(a[i := a!i], a'[i := None]) \<in> \<langle>only_some_rel\<rangle>list_rel"
      apply (parametricity)
      by (auto simp: only_some_rel_def)
    also from L list_rel_imp_same_length[OF SR] have "a[i := a!i] = a" by auto
    finally show ?thesis .  
  qed     
        
    
  lemma eo_extract1_refine: "(eo_extract1, mop_eo_extract) \<in> \<langle>only_some_rel\<rangle>list_rel \<rightarrow> nat_rel \<rightarrow> \<langle>Id \<times>\<^sub>r \<langle>only_some_rel\<rangle>list_rel\<rangle>nres_rel"
    unfolding eo_extract1_def mop_eo_extract_aux
    supply R = mop_list_get.fref[THEN frefD, OF TrueI prod_relI, unfolded uncurry_apply, THEN nres_relD]
    apply (refine_rcg R)
    apply assumption
    apply (clarsimp simp: assign_none_only_some_list_rel)
    by (auto simp: only_some_rel_def)

  lemma eo_list_set_refine: "(mop_list_set, mop_eo_set) \<in> \<langle>only_some_rel\<rangle>list_rel \<rightarrow> Id \<rightarrow> Id \<rightarrow> \<langle>\<langle>only_some_rel\<rangle>list_rel\<rangle>nres_rel"
    unfolding mop_list_set_alt mop_eo_set_alt 
    apply refine_rcg
    apply (simp add: list_rel_imp_same_length)
    apply simp
    apply parametricity
    apply (auto simp: only_some_rel_def)
    done
  
  
  lemma set_hnr': "(uncurry2 wo_set_impl,uncurry2 mop_list_set) \<in> wo_assn\<^sup>d *\<^sub>a snat_assn\<^sup>k *\<^sub>a elem_assn\<^sup>k \<rightarrow>\<^sub>a wo_assn"
    apply (rule hfref_cons[OF set_hnr])
    apply (auto simp: entails_lift_extract_simps sep_algebra_simps)
    done
  
    
    
  context
    notes [fcomp_norm_unfold] = eo_assn_def[symmetric]
  begin  
    lemmas eo_extract_refine_aux = eo_extract_impl.refine[FCOMP eo_extract1_refine]  

    lemma eo_extract_refine: "(uncurry eo_extract_impl, uncurry mop_eo_extract) 
      \<in> [\<lambda>_. True]\<^sub>c eo_assn\<^sup>d *\<^sub>a snat_assn\<^sup>k \<rightarrow> (elem_assn \<times>\<^sub>a eo_assn) [\<lambda>(ai,_) (_,r). r=ai]\<^sub>c"
      unfolding 
      
      
      oops
      apply (sepref_to_hnr)
      apply (rule hn_refine_nofailI)
      unfolding cnc_assn_prod_conv
      apply (rule hnr_ceq_assnI)  
      subgoal 
        supply R = eo_extract_refine_aux[to_hnr, unfolded APP_def]
        apply (rule hn_refine_cons[OF _ R])
        apply (auto simp: sep_algebra_simps entails_lift_extract_simps hn_ctxt_def pure_def invalid_assn_def)
        done
      subgoal
        unfolding eo_extract_impl_def mop_eo_extract_def hn_ctxt_def eo_assn_def hr_comp_def
        supply R = get_hnr[to_hnr, THEN hn_refineD, unfolded APP_def hn_ctxt_def]
        thm R
        supply [vcg_rules] = R
        supply [simp] = refine_pw_simps list_rel_imp_same_length
        apply (vcg)
        done
      done
    
      
    lemmas eo_set_refine_aux = set_hnr'[FCOMP eo_list_set_refine]  
    
    lemma pure_part_cnc_imp_eq: "pure_part (cnc_assn (\<lambda>x. x = cc) wo_assn a c) \<Longrightarrow> c=cc"
      by (auto simp: pure_part_def cnc_assn_def pred_lift_extract_simps)
    
    (* TODO: Move *)  
    lemma pure_entails_empty: "is_pure A \<Longrightarrow> A a c \<turnstile> \<box>"  
      by (auto simp: is_pure_def sep_algebra_simps entails_lift_extract_simps)
    
      
    lemma eo_set_refine: "(uncurry2 wo_set_impl, uncurry2 mop_eo_set) \<in> eo_assn\<^sup>d *\<^sub>a snat_assn\<^sup>k *\<^sub>a elem_assn\<^sup>d \<rightarrow>\<^sub>a\<^sub>d (\<lambda>_ ((ai, _), _). cnc_assn (\<lambda>x. x = ai) eo_assn)"
      apply (sepref_to_hnr)
      apply (rule hn_refine_nofailI)
      apply (rule hnr_ceq_assnI)  
      subgoal
        supply R = eo_set_refine_aux[to_hnr, unfolded APP_def]
        apply (rule hn_refine_cons[OF _ R])
        apply (auto simp: sep_algebra_simps entails_lift_extract_simps hn_ctxt_def pure_def invalid_assn_def pure_entails_empty[OF pure])
        done
      subgoal  
        unfolding hn_ctxt_def eo_assn_def hr_comp_def
        supply R = set_hnr[to_hnr, THEN hn_refineD, unfolded APP_def hn_ctxt_def]
        supply [vcg_rules] = R
        supply [simp] = refine_pw_simps list_rel_imp_same_length pure_part_cnc_imp_eq
        apply (vcg')
        done
      done 
      
  end
  thm mop_eo_extract_def

  
  find_theorems mop_eo_set mop_list_set
  
  thm mop_eo_set_alt
  
  lemma id_Some_only_some_rel: "(id, Some) \<in> Id \<rightarrow> only_some_rel"
    by (auto simp: only_some_rel_def)
  
  lemma map_some_only_some_rel_iff: "(xs, map Some ys) \<in> \<langle>only_some_rel\<rangle>list_rel \<longleftrightarrow> xs=ys"  
    apply (rule iffI)
    subgoal
      apply (induction xs "map Some ys" arbitrary: ys rule: list_rel_induct)
      apply (auto simp: only_some_rel_def)
      done
    subgoal
      apply (rewrite in "(\<hole>,_)" list.map_id[symmetric])
      apply (parametricity add: id_Some_only_some_rel)
      by simp
    done      
  
    
  lemma wo_assn_conv: "wo_assn xs ys = eo_assn (map Some xs) ys"
    unfolding eo_assn_def hr_comp_def
    by (auto simp: pred_lift_extract_simps sep_algebra_simps fun_eq_iff map_some_only_some_rel_iff)
  
  lemma to_eo_conv_refine: "(return, mop_to_eo_conv) \<in> wo_assn\<^sup>d \<rightarrow>\<^sub>a\<^sub>d (\<lambda>_ ai. cnc_assn (\<lambda>x. x = ai) eo_assn)"
    unfolding mop_to_eo_conv_def cnc_assn_def 
    apply sepref_to_hoare
    apply (rewrite wo_assn_conv)
    apply vcg
    done
  
  lemma "None \<notin> set xs \<longleftrightarrow> (\<exists>ys. xs = map Some ys)"  
    using None_not_in_set_conv by auto
    
  lemma to_wo_conv_refine: "(return, mop_to_wo_conv) \<in> eo_assn\<^sup>d \<rightarrow>\<^sub>a\<^sub>d (\<lambda>_ ai. cnc_assn (\<lambda>x. x = ai) wo_assn)"  
    unfolding mop_to_wo_conv_def cnc_assn_def eo_assn_def hr_comp_def
    apply sepref_to_hoare
    apply (auto simp add: refine_pw_simps map_some_only_some_rel_iff elim!: None_not_in_set_conv)
    by vcg
      
  lemma random_access_iterator: "random_access_iterator wo_assn eo_assn elem_assn 
    return return
    eo_extract_impl
    wo_set_impl"  
    apply unfold_locales
    using to_eo_conv_refine to_wo_conv_refine eo_extract_refine eo_set_refine
    apply blast+
    done
    
  sublocale random_access_iterator wo_assn eo_assn elem_assn 
    return return
    eo_extract_impl
    wo_set_impl
    by (rule random_access_iterator)        
  
    
  find_theorems "?a = UNPROTECT ?a"
    
end

  

(*global_interpretation IDXO: random_access_iterator 
  "woarray_assn snat_assn" "eoarray_assn snat_assn" snat_assn 
  return return
  eo_extract_impl
  array_upd
  defines IDXO_swap_eo_impl = IDXO.swap_eo_impl
  apply unfold_locales
  apply (rule eo_hnr_dep)+
  done
*)  
  
print_named_simpset llvm_inline  
  
  



  
lemma al_pure_eo: "is_pure A \<Longrightarrow> pure_eo_adapter A (al_assn A) arl_nth arl_upd"
  apply unfold_locales
  apply assumption
  apply (rule al_nth_hnr_mop; simp)
  subgoal
    apply (sepref_to_hnr)
    apply (rule hn_refine_nofailI)
    apply (rule hnr_ceq_assnI)  
    subgoal
      supply R = al_upd_hnr_mop[to_hnr, unfolded APP_def, of A]
      apply (rule hn_refine_cons[OF _ R])
      apply (auto simp: hn_ctxt_def pure_def invalid_assn_def sep_algebra_simps entails_lift_extract_simps)
      done
    subgoal
      unfolding hn_ctxt_def al_assn_def hr_comp_def pure_def in_snat_rel_conv_assn
      apply (erule is_pureE)
      apply (simp add: refine_pw_simps)
      supply [simp] = list_rel_imp_same_length
      by vcg
    done  
  done
  

global_interpretation 
  ALO: pure_eo_adapter snat_assn "al_assn snat_assn" arl_nth arl_upd  
  defines ALO_eo_extract_impl = ALO.eo_extract_impl
  apply (rule al_pure_eo)
  by simp

  
global_interpretation ALO: parameterized_sort_impl_context 
  "al_assn snat_assn" "ALO.eo_assn" snat_assn 
  return return
  ALO_eo_extract_impl
  arl_upd
  idx_cdom idx_less idx_pcmp idx_pcmp_impl "al_assn snat_assn"
  defines 
          ALO_is_guarded_insert_impl = ALO.is_guarded_param_insert_impl
      and ALO_is_unguarded_insert_impl = ALO.is_unguarded_param_insert_impl
      and ALO_unguarded_insertion_sort_impl = ALO.unguarded_insertion_sort_param_impl
      and ALO_guarded_insertion_sort_impl = ALO.guarded_insertion_sort_param_impl
      and ALO_final_insertion_sort_impl = ALO.final_insertion_sort_param_impl
      (*and ALO_mop_lchild_impl  = ALO.mop_lchild_impl 
      and ALO_mop_rchild_impl  = ALO.mop_rchild_impl 
      and ALO_has_rchild_impl  = ALO.has_rchild_impl 
      and ALO_has_lchild_impl  = ALO.has_lchild_impl *)
      
      and ALO_pcmpo_idxs_impl  = ALO.pcmpo_idxs_impl
      and ALO_pcmpo_v_idx_impl  = ALO.pcmpo_v_idx_impl
      and ALO_pcmpo_idx_v_impl  = ALO.pcmpo_idx_v_impl
      and ALO_pcmp_idxs_impl  = ALO.pcmp_idxs_impl
      
      and ALO_mop_geth_impl    = ALO.mop_geth_impl  
      and ALO_mop_seth_impl    = ALO.mop_seth_impl  
      and ALO_sift_down_impl   = ALO.sift_down_impl
      and ALO_heapify_btu_impl = ALO.heapify_btu_impl
      and ALO_heapsort_impl    = ALO.heapsort_param_impl
      and ALO_qsp_next_l_impl       = ALO.qsp_next_l_impl
      and ALO_qsp_next_h_impl       = ALO.qsp_next_h_impl
      and ALO_qs_partition_impl     = ALO.qs_partition_impl
(*      and ALO_qs_partitionXXX_impl     = ALO.qs_partitionXXX_impl *)
      and ALO_partition_pivot_impl  = ALO.partition_pivot_impl 
      and ALO_introsort_aux_impl = ALO.introsort_aux_param_impl
      and ALO_introsort_impl        = ALO.introsort_param_impl
      and ALO_move_median_to_first_impl = ALO.move_median_to_first_param_impl
  
  apply unfold_locales
  unfolding GEN_ALGO_def refines_param_relp_def (* TODO: thm gen_refines_param_relpI *)
  apply (rule idx_pcmp_impl.refine)
  done


lemmas [llvm_inline] = ALO.eo_extract_impl_def[THEN meta_fun_cong, THEN meta_fun_cong]  
  
print_named_simpset llvm_inline

find_in_thms ALO_partition_pivot_impl in llvm_code


(*oops llvm_deps "ALO_heapsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"*)

(*export_llvm "ALO_heapsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"*)

export_llvm 
  "ALO_heapsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"
  "ALO_introsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"





export_llvm
  "ALO_heapsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"
  "ALO_introsort_impl :: (32 word,64) array_list \<Rightarrow> (64 word,64) array_list \<Rightarrow> _"
  "IDXO_heapsort_impl :: (32 word,64) array_list \<Rightarrow> _" is "uint64_t* heapsort_idxs(array_list_32_64, uint64_t*, int64_t, int64_t)"
  "IDXO_introsort_impl :: (32 word,64) array_list \<Rightarrow> _" is "uint64_t* introsort_idxs(array_list_32_64, uint64_t*, int64_t, int64_t)"
  defines \<open>
    typedef struct {int64_t size; struct {int64_t capacity; int32_t *data;};} array_list_32_64;
    typedef struct {int64_t size; struct {int64_t capacity; int64_t *data;};} array_list_64_64;
    
    \<close>
  file "../code/introsort_param.ll"

  
  thm ALO.introsort_param_impl_correct
*)  
  
end
