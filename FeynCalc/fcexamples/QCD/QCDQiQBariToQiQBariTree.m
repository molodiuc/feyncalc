(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: QCDQiQBariToQiQBariTree                                          *)

(*
   This software is covered by the GNU Lesser General Public License 3.
   Copyright (C) 1990-2015 Rolf Mertig
   Copyright (C) 1997-2015 Frederik Orellana
   Copyright (C) 2014-2015 Vladyslav Shtabovenko
*)

(* :Summary:  Computation of the matrix element squared for the
              q_i qbar_i -> q_i qbar_i scattering in QCD at tree level      *)

(* ------------------------------------------------------------------------ *)



(* ::Section:: *)
(*Load FeynCalc, FeynArts and PHI*)


If[ $FrontEnd === Null,
    $FeynCalcStartupMessages = False;
    Print["Computation of the matrix element squared for the q_i qbar_i -> q_i qbar_i scattering in QCD at tree level"];
];
If[$Notebooks === False, $FeynCalcStartupMessages = False];
$LoadTARCER = False;
$LoadPhi =$LoadFeynArts= True;
<<HighEnergyPhysics`FeynCalc`
$FAVerbose = 0;


(* ::Section:: *)
(*Generate Feynman diagrams*)


topQiQBariToQiQBari = CreateTopologies[0, 2 -> 2];
diagsQiQBariToQiQBari =
  InsertFields[topQiQBariToQiQBari, {F[3, {1}], -F[3, {1}]} -> {F[
      3, {1}], -F[3, {1}]}, InsertionLevel -> {Classes},
   Model -> "SMQCD", ExcludeParticles -> {S[1], S[2], V[1],V[2]}];
Paint[diagsQiQBariToQiQBari, ColumnsXRows -> {2, 1}, Numbering -> None];


(* ::Section:: *)
(*Obtain corresponding amplitudes*)


ampQiQBariToQiQBari =
 Map[ReplaceAll[#, FeynAmp[_, _, amp_, ___] :> amp] &,
   Apply[List,
    FCPrepareFAAmp[CreateFeynAmp[diagsQiQBariToQiQBari,
     Truncated -> False]]]] //. {(a1__ DiracGamma[6] a2__ +
      a1__ DiracGamma[7] a2__) :> a1 a2, NonCommutative[x___] -> x,
   FermionChain -> DOT,
   FourMomentum[Outgoing, 1] -> p3, FourMomentum[Outgoing, 2] -> p4,
   FourMomentum[Incoming, 1] -> p1, FourMomentum[Incoming, 2] -> p2,
   DiracSpinor -> Spinor,Index[Lorentz, x_] :> LorentzIndex[ToExpression["Lor" <> ToString[x]]]
,Index[Gluon,x_]:>SUNIndex[ToExpression["Glu"<>ToString[x]]],
Index[Colour,x_]:>SUNFIndex[ToExpression["Col"<>ToString[x]]],
SumOver[__]:>1,MetricTensor->MT
}/.{SUNT->SUNTF}


(* ::Section:: *)
(*Unpolarized process  q_i qbar_i -> q_i qbar_i *)


SetMandelstam[s, t, u, p1, p2, -p3, -p4, MU, MU, MU, MU];
sqAmpQiQBariToQiQBari =(1/3^2)*
 (Total[ampQiQBariToQiQBari] Total[(ComplexConjugate[ampQiQBariToQiQBari]//FCRenameDummyIndices)])//PropagatorDenominatorExplicit//Contract//
    FermionSpinSum[#, ExtraFactor -> 1/2^2, SpinorCollect -> True]&//SUNSimplify[#,Explicit->True,SUNNToCACF->False]&//
ReplaceAll[#,{DiracTrace->Tr,SUNN->3}]&//Contract//Simplify


masslesssqAmpQiQBariToQiQBari = (sqAmpQiQBariToQiQBari /. {MU -> 0})//Simplify


masslesssqAmpQiQBariToQiQBariEllis=((4/9)Gstrong^4 ((s^2+u^2)/t^2+(t^2+u^2)/s^2)-(8/27)Gstrong^4 u^2/(s t));
Print["Check with Ellis, Stirling and Weber, Table 7.1: ",
      If[Simplify[(masslesssqAmpQiQBariToQiQBariEllis-masslesssqAmpQiQBariToQiQBari)]===0, "Correct.", "Mistake!"]];