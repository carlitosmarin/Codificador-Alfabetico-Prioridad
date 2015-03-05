with tablaFrecuencias, arbreBinari, heap, Ada.Text_IO, Ada.Sequential_IO;
use tablaFrecuencias, Ada.Text_IO;

package codificador is
   package arbol is new arbreBinari (item => character);
   use arbol;

   procedure codificar_f (tf: in abecedari; a: out arbre);
   procedure escriure_fitxer (nombrefichero : in String; a: in out arbre);
   procedure toBit (nombrefichero: in String);
   procedure fromBit (nombrefichero: in String; nombrebinario : in String);

end codificador;
