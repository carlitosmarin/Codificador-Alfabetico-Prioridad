with Ada.Text_IO, Ada.Float_Text_IO, Ada.Characters.Handling;
use Ada.Text_IO, Ada.Float_Text_IO, Ada.Characters.Handling;

package body tablaFrecuencias is

   numLetras        : float := 0.0;

   -- TABLA DE FRECUENCIAS

   procedure tbuida(tf : out abecedari) is
   begin
      tf := (others => 0.0);
   end tbuida;

   --
   -- Dada una tabla de frecuencias y un texto entrado por fichero, la tabla se
   -- llenará a medida de las apariciones de las letras.
   -- @param tf tabla que contendra la probabilidad de aparicion de un caracter
   -- @param name nombre del fichero al que acceder para lecturas
   -- @param ok booleano para saber si existe el fichero y se ha llenado la tabla
   --
   procedure omple (tf : in out abecedari; name: in String; ok: in out boolean) is
      fichdatos        : File_Type;
      cAux             : character;
   begin
      Ada.Text_IO.Open(File => fichdatos, Mode => In_File, Name => name);
      put("El texto del fichero: ");
      while not End_Of_File(fichdatos) loop
         get(fichdatos,cAux); -- Asigna un carácter del fichero a una variable
         put(cAux);
         cAux := To_Lower(cAux);
         if cAux in rango'Range then -- Si es un caracter del abecedario
            tf(cAux) := tf(cAux)+1.0; -- El valor de la posicion de la letra leida
            numLetras := numLetras+1.0;
         end if;
      end loop;
      put_line("");

      -- Para cada valor de las letras, dividir sus apariciones entre el total de letras
      for i in rango'Range loop
         tf(i) := tf(i) / numLetras;
      end loop;

      close(fichdatos);
      ok := true;
   end omple;

   procedure mostra(tf: in abecedari) is
   begin
      for i in rango'Range loop
         put_line("La letra '" & i & "':" & tf(i)'Img);
      end loop;
      put_line("El numero total de letras es: " & numLetras'Img);
   end mostra;

   -- ITERADOR

   -- Busca la primera letra cuyo valor de probabilidad de aparicion sea superior
   -- a 0.0, es decir, la primera letra, ordenada alfabetiacmente, que haya aparecido
   -- en el texto leido.
   -- @param tf tabla que contendra la probabilidad de aparicion de un caracter
   -- @param it iterador que contendra la letra cuyo valor sea superior a 0.0
   --
   procedure primer(tf: in abecedari; it: out iterador) is
   begin
      it.k := rango'First;
      while tf(it.k) <= 0.0 and it.k < rango'Last loop
         it.k := character'Succ(it.k);
      end loop;
      if tf(it.k) > 0.0 then it.valid :=  true;
      else it.valid := false;
      end if;
   end primer;

   --
   -- Busca la siguiente letra cuyo valor de probabilidad de apricion sea superior
   -- a 0.0, es decir, la siguiente letra a la anteior que haya aparecido en el texto.
   -- @param tf tabla que contendra la probabilidad de aparicion de un caracter
   -- @param it iterador que contendra la letra sucesora a la anterior, cuyo valor sea
   -- superior a 0.0
   --
   procedure successor(tf : in abecedari; it: in out iterador) is
   begin
      if not it.valid then raise bad_use; end if;
      if it.k < rango'Last then
         it.k := character'Succ(it.k);
         while tf(it.k) <= 0.0 and it.k < rango'Last loop
            it.k := character'Succ(it.k);
         end loop;
         if tf(it.k) > 0.0 then it.valid :=  true;
         else it.valid := false;
         end if;
      else it.valid := false;
      end if;
   end successor;

   --
   -- Obtiene tanto el caracter como su probabilidad de aparicion de un determinado iterador
   -- @param tf tabla que contendra la probabilidad de aparicion de un caracter
   -- @param it iterador que contiene cierta letra cuyo valor de probabilidad es superior a 0.0
   -- @param c valor del caracter del iterador mencionado
   -- @param f valor de la probabilidad de aparicion del caracter mencionado en la tabla
   --
   procedure consulta(tf: in abecedari; it: in iterador; c: out character; f: out float) is
   begin
      if not it.valid then raise bad_use; end if;
      c := it.k;
      f := tf(it.k);
   end consulta;

   --
   -- Dado un iterador, devuelve true si este tiene una probabilidad superior a 0.0
   -- @param it iterador que contendra un caracter que aprezca en el texto
   --
   function es_valid(it: in iterador) return boolean is
   begin
      return it.valid;
   end es_valid;

end tablaFrecuencias;
