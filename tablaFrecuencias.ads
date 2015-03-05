package tablaFrecuencias is

   subtype rango is character range 'a'..'z';
   type abecedari is private;

   bad_use: exception;

   procedure tbuida(tf: out abecedari);
   procedure omple (tf: in out abecedari; name: in String; ok: in out boolean);
   procedure mostra(tf: in abecedari);

   type iterador is private;

   procedure primer(tf: in abecedari; it: out iterador);
   procedure successor(tf: in abecedari; it: in out iterador);
   procedure consulta(tf: in abecedari; it: in iterador; c: out character; f: out float);
   function es_valid(it: in iterador) return boolean;

   pragma inline(primer, successor, consulta, es_valid);

private
   type abecedari is array (rango) of float;

   type iterador is
      record
         k: character;
         valid: boolean;
      end record;

end tablaFrecuencias;
