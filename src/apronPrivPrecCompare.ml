(* Utility program to compare precision of results of the apron analysis with different privatizations and/or differents apron domains *)
(* The result files that can be compared here may be created by passing an output file name in "exp.apron-prec-dump" to Goblint *)
module B = PrePrivPrecCompare.ComparePrec (PrivPrecCompareUtil.ApronUtil)

let () =
  B.main ()
