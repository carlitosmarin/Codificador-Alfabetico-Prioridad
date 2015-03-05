with Ada.Text_IO, Ada.Characters.Handling;
use Ada.Text_IO, Ada.Characters.Handling;

package body codificador is

   -- VARIABLES GLOBALES
   -- Implementación de la tabla de codificación
   type valor is array (integer range 0..rango'Range_Length-1) of integer; -- 0,1 y 2; donde el 2 es el valor del centinela
   type t_cod is array (rango) of valor;

   -- Implementación de una transición de estados del autómata
   type transicio is
      record
         estatI, estatF                                : natural;
         simbol                                        : integer; --0,1
         significat                                    : character;
      end record;

   type estatsAutomata is array (Positive range<>, Integer range<>) of natural;
   type t_estadosAutomata is array (Positive range<>) of character;

   package Codificar is new Ada.Sequential_IO(t_cod);
   package Decodificar is new Ada.Sequential_IO(transicio);
   package ficheroEstados is new Ada.Sequential_IO(integer);
   use Codificar;
   use Decodificar;
   use ficheroEstados;

   iteracion                                           : integer := 0;
   codigo                                              : valor;
   profundidad                                         : integer := 0;
   nEstados                                            : integer := 1;
   tablaCodigo                                         : t_cod;

   -- Ficheros en los que incluiremos la informacion para crear estructuras
   ficheroTrans                                        : Decodificar.File_Type;
   ficheroCod                                          : Codificar.File_Type;
   numEstados                                          : ficheroEstados.File_Type;

   -- ALGORITMOS

   --
   -- Dada una tabla de frecuencias, iterando por sus valores positivos, se llenara el heap con los arboles de
   -- cada caracter. Con todos los arboles unitarios se crearan arboles con hijo izquierdo y derecho con el
   -- objetivo de crear un arbol generador de los codigos, ordenado de tal manera que el nodo superior tenga la
   -- probabilidad de 1.0 y sus nodos inferiores su correspondiente, segun la letra.
   -- @param tf tabla que contendra la probabilidad de aparicion de un caracter
   -- @param a arbol que contendra las probabilidades de aparicion de los caracteres, será el arbol generador
   --
   procedure codificar_f (tf: in abecedari; a: out arbre) is
      package cola is new heap(size => rango'Range_Length, item => arbre, "<" => arbol. "<", ">" => arbol. ">");
      use cola;

      it                                               : iterador;
      b, c                                             : arbre;
      car                                              : character;
      probabilidad                                     : float := 0.0;
      hip                                              : cola.heap;
   begin
      -- Vaciamos el heap y los árboles por si hay "basura" contenida en ellos
      buit(q => hip); buit(a => a); buit(a => b); buit(a => c);

      -- Iniciamos el iterador con el primer valor de la tabla de frecuencias
      primer(tf => tf, it => it);
      -- Para todos los iteradores válidos creamos su árbol y lo inserimos de manera ordenada en el heap
      while es_valid(it => it) loop
         consulta(tf => tf, it => it, c => car, f  => probabilidad); -- Obtenemos el caracter y su probabilidad
         construeix(a => a, x => car, f => probabilidad); -- Creamos un arbol tipo "hijo"
         posa(q => hip, x => a);
         successor(tf => tf, it => it);
      end loop;

      -- Construimos el árbol generador a partir de los árboles del heap
      while a.probabilitat < 1.00 and then not es_buit(q => hip) loop
         -- Con los dos ultimos arboles del heap creamos un arbol tipo "padre"
         b := darrer(q => hip); elimina_darrer(q => hip);
         c := darrer(q => hip); elimina_darrer(q => hip);
         construeix(a => a, fe => b, fd => c, f => probabilidad);
         -- Lo añadimos al heap de manera ordenada segun su probabilidad
         posa(q => hip, x => a);
      end loop;

      if probabilidad > 1.00 then put_line("Error fatal, arbre no construït correctament"); end if;
   end codificar_f;

   --
   -- Crea, escribe y cierra los ficheros que se utilizaran para futuras codificacions y decodificaciones con el mismo patron
   -- de apariciones.
   -- @param nombrefichero nombre basico con el que se cearan los archivos de codificar, decodificar y el fichero de estados
   -- @param a arbol generador
   --
   procedure escriure_fitxer (nombrefichero: in String; a: in out arbre) is

      ficheroGrafico : Ada.Text_IO.File_Type;

      --
      -- Dado un arbol generado, crearemos la tabla de codigos a traves de las profundidades del arbol y las transiciones
      -- @param a arbol generador
      --
      procedure profunditat (a: in out arbre) is

         t : transicio;

         --
         -- Genera transiciones a traves de los parametros recibidos al llamar el procedimiento
         -- Además, crea el archivo con el que se puede graficar el arbol generador.
         --
         -- Se necesita de la libreria "Graphviz": $ sudo apt-get install Graphviz
         -- Una vez instalada la libreria: $ dot -Tpng nombreficheroTrans.dot -O
         --
         -- @param eI, eF estado inicial y final que generan la transicion
         -- @param simbol valor binario que genera la transicion
         -- @param car caracter al cual se llega con la transicion, si es un nodo padre, el caracter es '&'
         --
         procedure g_trans (eI, simbol, eF: natural; car : character) is
         begin
            t := (eI, eF, simbol, car);
            if eF = 0 then
               Put_Line(File => ficheroGrafico, Item => eI'Img & " -> " & car);
            else
               Put_Line(File => ficheroGrafico, Item => eI'Img & " ->" & eF'Img & " [ label = """ & simbol'Img(2..2) &  """ ]");
            end if;
            iteracion := iteracion +1;
         end g_trans;

         b                                             : arbre;
         estadoInicio                                  : natural;

      begin
         if (a.arrel.tnd = pare) then
            estadoInicio := nEstados;
            nEstados := nEstados+1;
            esquerra(a => a, fe => b);
            codigo(profundidad) := 0;
            profundidad := profundidad+1;
            g_trans(eI => estadoInicio, eF => nEstados, simbol => 0, car => '&');
            Decodificar.Write(File => ficheroTrans, Item => t);
            profunditat(a => b);
            profundidad := profundidad-1;

            dreta(a => a, fd => b);
            codigo(profundidad) := 1;
            profundidad := profundidad+1;
            nEstados := nEstados+1;
            g_trans(eI => estadoInicio, eF => nEstados, simbol => 1, car => '&');
            Decodificar.Write(File => ficheroTrans, Item => t);
            profunditat(a => b);
            profundidad := profundidad-1;
         else
            if nEstados = 1 then -- En el caso de que el texto sea de una letra
               codigo(profundidad) := 0;
               profundidad := profundidad+1;
            end if;
            codigo(profundidad) := 2;
            g_trans(eI => nEstados, eF => 0, simbol => 0, car => a.arrel.x);
            Decodificar.Write(File => ficheroTrans, Item => t);
            tablaCodigo(a.arrel.x) := codigo;
         end if;
      end profunditat;
   begin
      -- Creacion de los ficheros, "namefichero" + el tipo de archivo que sera, co: codificador, de: decodificador, num: numero de estados
      Codificar.Create(File => ficheroCod, Mode => Codificar.Out_File, Name => nombrefichero & ".co");
      Decodificar.Create(File => ficheroTrans, Mode => Decodificar.Out_File, Name => nombrefichero & ".de");
      ficheroEstados.Create(File => numEstados, Mode => Out_File, Name => nombrefichero & ".num");
      Create(File => ficheroGrafico, Mode => Out_File, Name => nombrefichero & "Trans.dot");
      Put(File => ficheroGrafico, Item => "digraph G {");

      profunditat(a => a);

      -- Escribimos en Codificar y numEstados, ya que Decodificar lo hemos escrito en la funcion profundidad
      Codificar.Write(File => ficheroCod, Item => tablaCodigo);
      ficheroEstados.Write(File => numEstados, Item => nEstados);
      Put(File => ficheroGrafico, Item => "}");

      -- Cerramos los ficheros una vez escritos
      Codificar.Close(File => ficheroCod);
      Decodificar.Close(File => ficheroTrans);
      ficheroEstados.Close(File => numEstados);
      Close(File => ficheroGrafico);
   end escriure_fitxer;

   --
   -- Con el archivo creado para codificar, se hace un recorrido del archivo ".txt" que contiene un texto que debe seguir
   -- el mismo patron de probabilidades, y letra a letra, si esta dentro del rango de la tabla de frecuencias ('a'..'z'), se
   -- sustituira dicho caracter por su correspondiente valor codificado.
   -- @param nombrefichero nombre basico con el que se han creado el archivo de codificar
   --
   procedure toBit (nombrefichero: in String) is
      tabla                                            : t_cod;
      fichdatos, binario                               : Ada.Text_IO.File_Type;
      car                                              : character;
      num, i                                           : integer := 0;
      codigo                                           : valor;
   begin
      Codificar.Open(File => ficheroCod, Mode => Codificar.In_File, Name => nombrefichero & ".co");
      Codificar.Read(File => ficheroCod, Item => tabla); -- Cargamos la tabla que leemos en el fichero de codificacion en "tabla"
      Open(File => fichdatos, Mode => In_File, Name => nombrefichero & ".txt");
      Create(File => binario, Mode => Out_File, Name => nombrefichero & "bin.txt");
      put_line("El texto del fichero '"&nombrefichero &"' codificado es el siguiente: ");
      while not End_Of_File(fichdatos) loop
         get(fichdatos,car); -- Asigna un carácter del fichero a una variable
         car := To_Lower(car);
         if car in rango then
            codigo := tabla(car);
            num := codigo(0);
            i:= 0;
            while num < 2 and i in 0..rango'Range_Length-1 loop
               put(num'Img(2..2));
               Ada.Text_IO.Put(File => binario, Item => num'Img(2..2));
               i := i+1;
               num := codigo(i);
            end loop;
         else
            put(car); -- Sacar la codificación por pantalla
            Ada.Text_IO.Put(File => binario, Item => car); -- Escribirla en un fichero
         end if;
      end loop;
      Codificar.Close(File => ficheroCod);
      Close(File => fichdatos);
      Close(File => binario);
   end toBit;

   --
   -- Con el archivo que se ha creado para decodificar y el que almacena el numero de estados, decodificaremos el texto
   -- que se leera en "nombrebinario".txt, utilizando los automatas ya creados a la hora de crear los archivos iniciales.
   -- @param nombrefichero nombre basico con el que se han creado el archivo de decodificar
   -- @param nombrebinario nombre del archivo que contiene los codigos a decodificar
   --
   procedure fromBit (nombrefichero: in String; nombrebinario : in String) is

      --
      -- Ídem al mecanismo para codificar, leeremos caracter a caracter hasta encontrar a traves de los automatas, el caracter
      -- al que corresponde dicha cadena de bits.
      -- @param nombrefichero nombre basico con el que se han creado el archivo de decodificar
      -- @param nombrebinario nombre del archivo que contiene los codigos a decodificar
      -- @param estados cantidad de estados enlazados hasta llegar al caracter correspondiente
      --
      procedure decodificarAutomata (nombrefichero : in String; nombrebinario: in String; estados : in integer) is
         ficheroBits                               : Ada.Text_IO.File_Type;
         t                                         : transicio;
         car                                       : character;
         i,j                                       : integer := 1;
         estadosFuturos                            : estatsAutomata(1..estados,0..1);
         caracter                                  : t_estadosAutomata(1..estados);
      begin
         caracter := (others => '&');
         Decodificar.Open(File => ficheroTrans, Mode => Decodificar.In_File, Name => nombrefichero & ".de");

         -- Creamos los automatas para decodificar el texto
         while Decodificar.End_Of_File(File => ficheroTrans) = false loop
            Decodificar.Read(File => ficheroTrans, Item => t);
            if t.estatF = 0 then
               caracter(t.estatI) := t.significat;
               estadosFuturos(t.estatI,0):= 0;
               estadosFuturos(t.estatI,1):= 0;
            else
               estadosFuturos(t.estatI,t.simbol) := t.estatF;
            end if;
         end loop;

         -- Desde el texto en binario obtenemos, mediante el automata creado, el códgio traducido
         Open(File => ficheroBits, Mode => In_File, Name => nombrebinario & ".txt");
         put("Texto codificado: ");
         while not End_Of_file(File => ficheroBits) loop
            get(File => ficheroBits, Item => car);
            if car = '0' or car = '1' then
               if estadosFuturos(i,0) /= 0 then
                  if car = '0' then j := estadosFuturos(i,0);
                  else j := estadosFuturos(i,1);
                  end if;
                  i := j;
                  if estadosFuturos(i,0) = 0 then
                     put(caracter(i));
                     i := 1;
                  end if;
               else
                  put(caracter(i));
                  i := 1;
               end if;
            else
               put(car);
            end if;
         end loop;
         Close(File => ficheroBits);
         Decodificar.Close(File => ficheroTrans);

      end decodificarAutomata;

      num: integer; -- Numero de estados que se leera en le fichero numeEstados
   begin
      ficheroEstados.Open(File => numEstados, Mode => In_File, Name => nombrefichero & ".num");
      ficheroEstados.Read(File => numEstados, Item => num);
      decodificarAutomata(nombrefichero => nombrefichero, nombrebinario => nombrebinario, estados => num);
      ficheroEstados.Close(File => numEstados);
   end fromBit;

end codificador;
