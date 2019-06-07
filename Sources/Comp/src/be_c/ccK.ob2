(** Copyright (c) 1996,97 XDS Ltd, Russia. All Rights Reserved. *)
(** C back-end: common declarations, options *)
MODULE ccK; (* Ned 17-Mar-96 *)

(* Modifications:
   24/Mar/96 Ned  2.12  back-end version 4.13
   27/Mar/96 Ned  2.12  back-end version 4.14
*)


IMPORT
   pc:=pcK
  ,env:=xiEnv
  ;
IMPORT SYSTEM;
CONST
(** sets of language flags *)
  special_proclass* = pc.LangSet{pc.flag_p,pc.flag_stdcall,pc.flag_syscall};
  default_proclass* = pc.LangSet{pc.flag_o2,pc.flag_m2};
  c_like_flags*     = pc.LangSet{pc.flag_c,pc.flag_p,pc.flag_stdcall,pc.flag_syscall};

CONST (** tags: valid range 8..15 *)

(** object tags *)
  otag_declared*   =VAL(pc.OTAG, 8); (** declared, may be not defined         *)
  otag_declaring*  =VAL(pc.OTAG, 9); (** declaration in progress              *)
  otag_defining*   =VAL(pc.OTAG,10); (** definition in progress               *)
  otag_pub_defined*=VAL(pc.OTAG,11); (** public part is defined               *)
  otag_pri_defined*=VAL(pc.OTAG,12); (** private part is def. (func.body, td) *)
  otag_versionkey* =VAL(pc.OTAG,13); (** version key in module body name      *)
  otag_notype*     =VAL(pc.OTAG,13); (** object declared with wrong type      *)
  otag_headerfile* =VAL(pc.OTAG,14); (** header file exist, may be extern     *)
  otag_bitfield*   =VAL(pc.OTAG,14); (** bit filed, has "&" operator for SL1  *)
  otag_bitfield_nm*=VAL(pc.OTAG,15); (** bit field with additional name       *)
  otag_reference*  =VAL(pc.OTAG,15); (** obj. name is reference to object     *)

(** type tags *)
  ttag_ownheader*  =VAL(pc.TTAG,  8); (** header file was made by this back-end *)
  ttag_nocode*     =VAL(pc.TTAG,  9); (** C text of module is not generated by this back-end *)
  ttag_cstdlib*    =VAL(pc.TTAG, 10); (** CSTDLIB was set while compile the module *)
  ttag_union*      =VAL(pc.TTAG, 11); (** record is union, not struct          *)

VAR
(** options *)
  op_index16   *: BOOLEAN; (** INDEX16 *)
  op_address16 *: BOOLEAN; (** DIFADR16 *)
  op_int16     *: BOOLEAN; (** TARGET16 *)
  op_gensize   *: BOOLEAN; (** GENSIZE *)
  op_debug     *: BOOLEAN; (** GENDEBUG *)
  op_profile   *: BOOLEAN; (** GENPROFILE *)
  op_lineno    *: BOOLEAN; (** LINENO *)
  op_cdiv      *: BOOLEAN; (** GENCDIV *)
  op_comments  *: BOOLEAN; (** COMMENT *)
  op_krc       *: BOOLEAN; (** GENKRC *)
  op_cpp       *: BOOLEAN; (** GENCPP *)
  op_proclass  *: BOOLEAN; (** GENPROCLASS *)
  op_gendll    *: BOOLEAN; (** GENDLL *)
  op_gencnsexp *: BOOLEAN; (** GENCNSEXP *)
  op_constenum *: BOOLEAN; (** GENCONSTENUM *)

VAR
  vers*: ARRAY 16 OF CHAR; (** back-end version *)

PROCEDURE ini*;
BEGIN
  op_index16  :=env.config.Option("INDEX16");
  op_address16:=env.config.Option("DIFADR16");
  op_int16    :=env.config.Option("TARGET16");
  op_gensize  :=env.config.Option("GENSIZE");
  op_profile  :=env.config.Option("GENPROFILE");
  op_debug    :=env.config.Option("GENDEBUG") OR op_profile;
  op_lineno   :=env.config.Option("LINENO");
  op_cdiv     :=env.config.Option("GENCDIV");
  op_comments :=env.config.Option("COMMENT");
  op_krc      :=env.config.Option("GENKRC");
  op_cpp      :=env.config.Option("GENCPP");
  op_proclass :=env.config.Option("GENPROCLASS");
  op_gendll   :=env.config.Option("GENDLL");
  op_gencnsexp:=env.config.Option("GENCNSEXP");
  op_constenum:=env.config.Option("GENCONSTENUM");
END ini;

PROCEDURE exi*;
BEGIN
END exi;

PROCEDURE DeclareOptions*;

  PROCEDURE options(s-: ARRAY OF CHAR);
    VAR i,n: INTEGER; name: ARRAY 16 OF CHAR;
  BEGIN
    i:=0;
    REPEAT
      n:=0;
      WHILE (s[i]#';') & (s[i]#'+') DO name[n]:=s[i]; INC(n); INC(i) END;
      name[n]:=0X;
      env.config.NewOption(name,s[i]='+',SYSTEM.VAL(env.CompilerOption,-1));
      INC(i)
    UNTIL s[i]=0X;
  END options;

  CONST opts = "NOEXTERN;GENSIZE;INDEX16;"
             + "CONVHDRNAME;VERSIONKEY;"
	     + "GENTYPEDEF;DIFADR16;GENCTYPES;GENKRC;"
             + "TARGET16;GENDEBUG;LINENO;GENFULLFNAME;GENCDIV;"
	     + "GENPROCLASS+GENCPP;NOOPTIMIZE;GENPROFILE;"
             + "GENDATE+GENDLL;GENCNSEXP;GENCONSTENUM;GENPTRTOARR;"
	     ;

BEGIN
  env.config.NewOption("GENTYPEDEF",FALSE,env.no_struct);
  env.config.NewEquation("COPYRIGHT");
  env.config.NewEquation("GENIDLEN");
  env.config.SetEquation("GENIDLEN","30");
  env.config.NewEquation("GENWIDTH");
  env.config.SetEquation("GENWIDTH","77");
  env.config.NewEquation("GENINDENT");
  env.config.SetEquation("GENINDENT","3");
  options(opts);
END DeclareOptions;

(**--------------------------------------------------------------
                declaration     public def.     private def.

ob_proc         profile         -               body
ob_xproc        profile         -               body
ob_cproc        profile         -               body
ob_cproc        profile         -               -
ob_type
  rename        typedef         -               -
  ty_record     struct X        struct X { }    type descriptor
  ty_array_of   struct X        struct X { }    -
  other         typedef         -               -
ob_module       profile         -               body, descriptor

-----------------------------------------------------------------*)

BEGIN
  vers:="ANSI C v4.20";
END ccK.
