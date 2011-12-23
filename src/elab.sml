(* Copyright (c) 2008-2011, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *)

structure Elab = struct

type 'a located = 'a ErrorMsg.located

datatype kind' =
         KType
       | KArrow of kind * kind
       | KName
       | KRecord of kind
       | KUnit
       | KTuple of kind list

       | KError
       | KUnif of ErrorMsg.span * string * kunif ref
       | KTupleUnif of ErrorMsg.span * (int * kind) list * kunif ref

       | KRel of int
       | KFun of string * kind

and kunif =
    KUnknown of kind -> bool (* Is the kind a valid unification? *)
  | KKnown of kind

withtype kind = kind' located

datatype explicitness =
         Explicit
       | Implicit

datatype con' =
         TFun of con * con
       | TCFun of explicitness * string * kind * con
       | TRecord of con
       | TDisjoint of con * con * con

       | CRel of int
       | CNamed of int
       | CModProj of int * string list * string
       | CApp of con * con
       | CAbs of string * kind * con

       | CKAbs of string * con
       | CKApp of con * kind
       | TKFun of string * con

       | CName of string

       | CRecord of kind * (con * con) list
       | CConcat of con * con
       | CMap of kind * kind

       | CUnit

       | CTuple of con list
       | CProj of con * int

       | CError
       | CUnif of int * ErrorMsg.span * kind * string * cunif ref

and cunif =
    Unknown of con -> bool (* Is the constructor a valid unification? *)
  | Known of con

withtype con = con' located

datatype datatype_kind = datatype DatatypeKind.datatype_kind

datatype patCon =
         PConVar of int
       | PConProj of int * string list * string

datatype pat' =
         PWild
       | PVar of string * con
       | PPrim of Prim.t
       | PCon of datatype_kind * patCon * con list * pat option
       | PRecord of (string * pat * con) list

withtype pat = pat' located

datatype exp' =
         EPrim of Prim.t
       | ERel of int
       | ENamed of int
       | EModProj of int * string list * string
       | EApp of exp * exp
       | EAbs of string * con * con * exp
       | ECApp of exp * con
       | ECAbs of explicitness * string * kind * exp

       | EKAbs of string * exp
       | EKApp of exp * kind

       | ERecord of (con * exp * con) list
       | EField of exp * con * { field : con, rest : con }
       | EConcat of exp * con * exp * con
       | ECut of exp * con * { field : con, rest : con }
       | ECutMulti of exp * con * { rest : con }

       | ECase of exp * (pat * exp) list * { disc : con, result : con }

       | EError
       | EUnif of exp option ref

       | ELet of edecl list * exp * con

and edecl' =
    EDVal of pat * con * exp
  | EDValRec of (string * con * exp) list

withtype exp = exp' located
     and edecl = edecl' located

datatype sgn_item' =
         SgiConAbs of string * int * kind
       | SgiCon of string * int * kind * con
       | SgiDatatype of (string * int * string list * (string * int * con option) list) list
       | SgiDatatypeImp of string * int * int * string list * string * string list * (string * int * con option) list
       | SgiVal of string * int * con
       | SgiStr of string * int * sgn
       | SgiSgn of string * int * sgn
       | SgiConstraint of con * con
       | SgiClassAbs of string * int * kind
       | SgiClass of string * int * kind * con

and sgn' =
    SgnConst of sgn_item list
  | SgnVar of int
  | SgnFun of string * int * sgn * sgn
  | SgnWhere of sgn * string * con
  | SgnProj of int * string list * string
  | SgnError

withtype sgn_item = sgn_item' located
and sgn = sgn' located

datatype decl' =
         DCon of string * int * kind * con
       | DDatatype of (string * int * string list * (string * int * con option) list) list
       | DDatatypeImp of string * int * int * string list * string * string list * (string * int * con option) list
       | DVal of string * int * con * exp
       | DValRec of (string * int * con * exp) list
       | DSgn of string * int * sgn
       | DStr of string * int * sgn * str
       | DFfiStr of string * int * sgn
       | DConstraint of con * con
       | DExport of int * sgn * str
       | DTable of int * string * int * con * exp * con * exp * con
       | DSequence of int * string * int
       | DView of int * string * int * exp * con
       | DClass of string * int * kind * con
       | DDatabase of string
       | DCookie of int * string * int * con
       | DStyle of int * string * int
       | DTask of exp * exp
       | DPolicy of exp
       | DOnError of int * string list * string

     and str' =
         StrConst of decl list
       | StrVar of int
       | StrProj of str * string
       | StrFun of string * int * sgn * sgn * str
       | StrApp of str * str
       | StrError

withtype decl = decl' located
     and str = str' located
               
type file = decl list

end
