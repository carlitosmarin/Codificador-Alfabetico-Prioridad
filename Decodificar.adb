with codificador, Ada.Command_Line, Ada.Text_IO;
use codificador, Ada.Command_Line, Ada.Text_IO;

-- Cuando el usuario quiere decodificar un texto, sabiendo
-- previamente el patrón de la codificacion de las letras. (de bits a letra)

procedure Decodificar is
begin
   if Argument_Count = 2 then
      -- Si le metemos dos parametros en los argumentos:
      -- Argument(1): es el fichero del cual sacaremos las estructuras para decodificar
      -- Argument(2): es el fichero del cual decodificaremos el texto.
      fromBit(nombrefichero => Argument(1), nombrebinario => Argument(2));
   elsif Argument_Count = 1 then
      -- Si le metemos un parametro en los argumentos:
      -- Argument(1): es el fichero del cual sacaremos las estructuras para decodificar
      -- y Argument(1)&"bin" es el fichero del cual decodificaremos el texto.
      fromBit(nombrefichero => Argument(1), nombrebinario => Argument(1)&"bin");
   end if;
end Decodificar;
