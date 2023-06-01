(** Domains for mvalues: simplified lvalues, which start with a {!GoblintCil.varinfo}.
    Mvalues are the result of resolving {{!GoblintCil.Mem} pointer dereferences} in lvalues. *)

open GoblintCil
open Pretty

module M = Messages

module type OffsS =
sig
  type idx
  include Printable.S with type t = idx Offset.t
  val add_offset: t -> t -> t
  val type_offset: typ -> t -> typ
  exception Type_offset of typ * string
  val to_cil: t -> offset
  val prefix: t -> t -> t option
  val is_zero_offset: t -> bool
end

module MakePrintable (Offs: OffsS) =
struct
  type idx = Offs.idx
  include Printable.StdLeaf
  (* TODO: version with Basetype.Variables and RichVarinfo for AddressDomain *)
  type t = CilType.Varinfo.t * Offs.t [@@deriving eq, ord, hash]

  let name () = Format.sprintf "lval (%s)" (Offs.name ())

  let show ((v, o): t): string = CilType.Varinfo.show v ^ Offs.show o
  include Printable.SimpleShow (
    struct
      type nonrec t = t
      let show = show
    end
    )

  let add_offset (v, o) o' = (v, Offs.add_offset o o')

  let get_type_addr (v,o) = try Offs.type_offset v.vtype o with Offs.Type_offset (t,_) -> t

  let prefix (v1,ofs1) (v2,ofs2) =
    if CilType.Varinfo.equal v1 v2 then
      Offs.prefix ofs1 ofs2
    else
      None

  let to_cil ((v, o): t): lval = (Var v, Offs.to_cil o)
  let to_cil_exp lv = Lval (to_cil lv)
end

module type OffsT =
sig
  include OffsS
  val semantic_equal: xtyp:typ -> xoffs:t -> ytyp:typ -> yoffs:t -> bool option
  val is_definite: t -> bool
  val leq: t -> t -> bool
  val top_indices: t -> t
  val merge: [`Join | `Widen | `Meet | `Narrow] -> t -> t -> t
  val remove_offset: t -> t
  val to_cil: t -> offset
  val of_exp: exp Offset.t -> t
  val to_exp: t -> exp Offset.t
end

module MakeLattice (Offs: OffsT) =
struct
  include MakePrintable (Offs)
  module Offs = Offs

  let semantic_equal (x, xoffs) (y, yoffs) =
    if CilType.Varinfo.equal x y then
      let xtyp = x.vtype in
      let ytyp = y.vtype in
      Offs.semantic_equal ~xtyp ~xoffs ~ytyp ~yoffs
    else
      Some false

  let is_definite (_, o) = Offs.is_definite o

  let leq (x,o) (y,u) = CilType.Varinfo.equal x y && Offs.leq o u
  let top_indices (x, o) = (x, Offs.top_indices o)
  let merge cop (x,o) (y,u) =
    if CilType.Varinfo.equal x y then
      (x, Offs.merge cop o u)
    else
      raise Lattice.Uncomparable
end



module Unit = MakePrintable (Offset.Unit)
module Exp = MakePrintable (Offset.Exp)
