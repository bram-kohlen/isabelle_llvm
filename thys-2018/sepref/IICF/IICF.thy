section \<open>The LLVM Imperative Isabelle Collection Framework\<close>
theory IICF
imports 
  (* Sets *)
  "Intf/IICF_Set"

  (* Multisets *)
  "Intf/IICF_Multiset"
  "Intf/IICF_Prio_Bag"


  (* Maps *)
  "Intf/IICF_Map"
  "Intf/IICF_Prio_Map"

  (* Lists *)
  "Intf/IICF_List"

  "Impl/IICF_Array"
  "Impl/IICF_Array_List"

  (* Matrix *)
  (*"Intf/IICF_Matrix"*)


begin
  thy_deps
end
