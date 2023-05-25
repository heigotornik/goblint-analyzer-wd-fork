(** An analysis tracking the type of a mutex. *)

open GoblintCil
open Analyses

module MAttr = ValueDomain.MutexAttr
module LF = LibraryFunctions



module Spec : Analyses.MCPSpec with module D = Lattice.Unit and module C = Lattice.Unit =
struct
  include Analyses.DefaultSpec
  module V = VarinfoV

  let name () = "pthreadMutexType"
  module D = Lattice.Unit
  module C = Lattice.Unit

  (* Removing indexes here avoids complicated lookups inside the map for a varinfo, at the price that different types of mutexes in arrays are not dinstinguished *)
  module G = MapDomain.MapBot_LiftTop (Lval.OffsetNoIdx) (MAttr)

  (* transfer functions *)
  let assign ctx (lval:lval) (rval:exp) : D.t =
    (* replaces the rightmost offset with r *)
    let rec replace_no_offset o r = match o with
      | `NoOffset -> r
      | `Field (f,o) -> `Field (f, replace_no_offset o r)
      | `Index (i,o) -> `Index (i, replace_no_offset o r)
    in
    match lval with
    | (Var v, o) ->
      (* There's no way to use the PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP etc for accesses via pointers *)
      let rec helper o t = function
        | Field ({fname = "__data"; _}, Field ({fname = "__kind"; _}, NoOffset)) when ValueDomain.Compound.is_mutex_type t ->
          let kind =
            (match Cil.constFold true rval with
             | Const (CInt (c, _, _)) -> MAttr.of_int c
             | _ -> `Top)
          in
          let r = G.singleton (o) kind in
          ctx.sideg v r;
          ctx.local
        | Index (i,o') -> helper (replace_no_offset o (`Index (Lval.OffsetNoIdx.SomeIdx,`NoOffset))) (Cilfacade.typeOffset t (Index (i,NoOffset))) o'
        | Field (f,o') -> helper (replace_no_offset o (`Field (f,`NoOffset)))  (Cilfacade.typeOffset t (Field (f,NoOffset))) o'
        | NoOffset -> ctx.local
      in
      helper `NoOffset v.vtype o
    | _ -> ctx.local

  let branch ctx (exp:exp) (tv:bool) : D.t =
    ctx.local

  let body ctx (f:fundec) : D.t =
    ctx.local

  let return ctx (exp:exp option) (f:fundec) : D.t =
    ctx.local

  let enter ctx (lval: lval option) (f:fundec) (args:exp list) : (D.t * D.t) list =
    [ctx.local, ctx.local]

  let combine_env ctx (lval:lval option) fexp (f:fundec) (args:exp list) fc (au:D.t) (f_ask:Queries.ask) : D.t =
    au

  let combine_assign ctx (lval:lval option) fexp (f:fundec) (args:exp list) fc (au:D.t) (f_ask: Queries.ask) : D.t =
    ctx.local

  let special ctx (lval: lval option) (f:varinfo) (arglist:exp list) : D.t =
    let desc = LF.find f in
    match desc.special arglist with
    | MutexInit {mutex = mutex; attr = attr} ->
      let mutexes = ctx.ask (Queries.MayPointTo mutex) in
      let attr = ctx.ask (Queries.EvalMutexAttr attr) in
      (* It is correct to iter over these sets here, as mutexes need to be intialized before being used, and an analysis that detects usage before initialization is a different analysis. *)
      Queries.LS.iter (function (v, o) ->
          let r = G.singleton (Lval.OffsetNoIdx.of_offs o) attr in
          ctx.sideg v r) mutexes;
      ctx.local
    | _ -> ctx.local

  let startstate v = D.bot ()
  let threadenter ctx lval f args = [D.top ()]
  let threadspawn ctx lval f args fctx = ctx.local
  let exitstate  v = D.top ()

  let query ctx (type a) (q: a Queries.t): a Queries.result =
    match q with
    | Queries.MutexType (v,o) -> let r = ctx.global v in (G.find o r:MutexAttrDomain.t)
    | _ -> Queries.Result.top q
end

let _ =
  MCP.register_analysis (module Spec : MCPSpec)
