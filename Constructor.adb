with tablaFrecuencias, arbreBinari, heap, codificador, Ada.Command_Line, Ada.Text_IO;
use tablaFrecuencias, codificador, Ada.Command_Line, Ada.Text_IO;

-- Este archivo es el necesario para construir las estructuras y ficheros indispensables para la
-- codificacion y decodificacion futura de textos cualesquieran.

procedure Constructor is
   package arbol is new arbreBinari(item => character);
   use arbol;

   tf: abecedari; -- tabla de frecuencias
   existe: boolean := true; -- Si existe el fichero
   a: codificador.arbol.arbre;
begin
   tbuida(tf => tf); -- Vaciamos la tabla por si quedan "restos" en memoria
   -- La llenamos con las probabilidades de aparicion en el texto cuyo nombre es dado por argumento
   omple(tf => tf, name => Argument(1)&".txt", ok => existe);
   if existe = false then put("El fichero indicado no existe");
   else
      mostra(tf => tf); -- Por pantalla aparecera la "tabla" con las probabilidades leídas
      codificar_f(tf => tf, a => a); -- Se realiza el proceso de codificiacion de frecuencias
      if a.probabilitat = 1.00 then
         escriure_fitxer(nombrefichero => Argument(1), a => a);
      end if;
   end if;
end Constructor;
