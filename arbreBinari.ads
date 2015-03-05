generic
   type item is private;

package arbreBinari is
   type tipusnode is(pare,fill);
   type node;
   type pnode is access node;

   -- Declaración del tipo ARBOL
   type arbre is
      record
         arrel            : pnode; -- La arrel de los árboles son punteros a nodos.
         probabilitat     : float; -- La probabilidad TOTAL del árbol.
      end record;

   -- Declaración del tipo NODO
   type node(tnd: tipusnode) is -- tipusnode es un enumerado (pare, fill).
      record
         case tnd is
         when pare =>
            e,d           : pnode; -- Si es padre, contendrá dos punteros pnode.
         when fill =>
            x             : item; -- Si es hijo, contendrá el item genérico.
         end case;
      end record;

   mal_us, espai_overflow : exception;

   procedure buit(a       : out arbre);
   function es_buit(a     : in arbre) return boolean;
   function arrel(a       : in arbre) return tipusnode;
   procedure construeix(a : out arbre; fe,fd:in arbre; f: out float);
   procedure construeix(a : out arbre; x:in item; f:in float);
   procedure esquerra(a   : in arbre; fe: out arbre);
   procedure dreta(a      : in arbre; fd:out arbre);
   function "<" (a1,a2    : in arbre) return boolean;
   function ">" (a1,a2    : in arbre) return boolean;

end arbreBinari;
