with Ada.Text_IO, Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Float_Text_IO;

package body arbreBinari is

   procedure buit(a: out arbre) is
   begin
      a.arrel:= null;
      a.probabilitat:= 0.0;
   end buit;

   function es_buit(a: in arbre) return boolean is
   begin
      return a.arrel = null;
   end es_buit;

   --
   -- Devuelve el tipo de nodo de la raiz del arbol entrado por parametro.
   -- Los tipos de nodos son: "pare" y "fill"
   -- @param a arbol que contendra las probabilidades de aparicion de los caracteres
   --
   function arrel(a: in arbre) return tipusnode is
   begin
      return a.arrel.tnd;
   end arrel;

   --
   -- Construye un nodo de tipo "pare", asignandole un hijo izquierdo
   -- y uno derecho ademas de una probabilidad asignada por la suma
   -- de las probabilidades de sus hijos.
   -- @param a arbol que contendra la probabilidad total de aparicion de los caracteres
   -- @param fe arbol que contendra las probabilidades de aparicion de los caracteres propios
   -- @param fd arbol que contendra las probabilidades de aparicion de los caracteres propios
   -- @param f variable que almacena la suma total de las probabilidades
   --
   procedure construeix(a: out arbre; fe,fd:in arbre; f: out float) is
      p                      : pnode renames a.arrel;
      pfe                    : pnode renames fe.arrel;
      pfd                    : pnode renames fd.arrel;
   begin
      p:= new node(pare);
      p.all:=(pare,pfe,pfd); -- Raices de los otros arboles nuevos hijos.
      a.probabilitat := fe.probabilitat + fd.probabilitat;
      -- Nueva probabilidad (suma de la de los hijos)
      f := a.probabilitat;
   exception
      when storage_error => raise espai_overflow;
   end construeix;

   --
   -- Construye un nodo de tipo "fill", asignandole un tipo item y una probabilidad.
   -- @param a arbol que contendra las probabilidades de aparicion de los caracteres
   -- @param x letra del alfabeto la cual tiene cierta probabilidad de aparicion
   -- @param f la probabilidad de aparicion de la letra
   --
   procedure construeix(a: out arbre; x:in item; f:in float) is
      p                      : pnode renames a.arrel;
   begin
      p:= new node(fill);
      p.all.x := x; -- Asignamos item por parametro al nuevo nodo tipo "fill".
      a.probabilitat := f;
   end construeix;

   --
   -- Asignamos la raiz del arbol izquierdo al hijo izquierdo del arbol.
   -- @param a arbol que contendra las probabilidades de aparicion de los caracteres
   -- @param fe arbol que sera apuntado por el nodo padre 'a'
   --
   procedure esquerra(a: in arbre; fe: out arbre) is
      p                      : pnode renames a.arrel;
      pfe                    : pnode renames fe.arrel;
   begin
      pfe:=p.e;
   exception
      when constraint_error => raise mal_us;
   end esquerra;

   --
   -- Asignamos la raiz del arbol derecho al hijo derecho del arbol.
   -- @param a arbol que contendra las probabilidades de aparicion de los caracteres
   -- @param fd arbol que sera apuntado por el nodo padre 'a'
   --
   procedure dreta(a: in arbre; fd:out arbre) is
      p                      : pnode renames a.arrel;
      pfd                    : pnode renames fd.arrel;
   begin
      pfd:=p.d;
   exception
      when constraint_error => raise mal_us;
   end dreta;

   --
   -- Devuelve true si la probabilidad del a1 es mas pequeña que la del a2.
   -- @param a1 arbol con el que se evaluaran las probabilidades para determinar el órden
   -- @param a2 arbol con el que se evaluaran las probabilidades para determinar el órden
   --
   function "<" (a1,a2: in arbre) return boolean is
   begin
      return a1.probabilitat < a2.probabilitat;
   end "<";

   function ">" (a1,a2: in arbre) return boolean is
   begin
      return a1.probabilitat > a2.probabilitat;
   end ">";
end arbreBinari;
