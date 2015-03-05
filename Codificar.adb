with codificador, Ada.Command_Line, Ada.Text_IO;
use codificador, Ada.Command_Line, Ada.Text_IO;

-- Cuando el usuario quiere codificar un texto.(de letra a bits)

procedure Codificar is
begin
   toBit(nombrefichero => Argument(1));
end Codificar;
