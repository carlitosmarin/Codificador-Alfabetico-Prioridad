generic
   size: positive;
   type item is private;
   with function "<" (x1,x2: in item) return boolean;
   with function ">" (x1,x2: in item) return boolean;

package heap is
   type heap is limited private;

   mal_us: exception;
   espai_overflow: exception;

   procedure buit (q: out heap);
   function es_buit(q: in heap) return boolean;
   procedure posa (q: in out heap; x: in item);
   procedure elimina_darrer (q: in out heap);
   function darrer (q: in heap) return item;

private
   type puntero is array (1..size) of item;

   type heap is
      record
         posicion: puntero;
         n: natural;
      end record;

end heap;
