with Ada.Text_IO, Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Float_Text_IO;

package body heap is

   procedure buit (q: out heap) is
   begin
      q.n := 0;
   end buit;

   function es_buit(q: in heap) return boolean is
   begin
      return q.n = 0;
   end es_buit;

   --
   -- Añade de manera ordenada segun su prioridad un nuevo elemento al heap.
   -- @param q heap que contendra los arboles y sus probabilidades
   -- @param x item generico que se le añadira al heap, en este caso, un arbol
   --
   procedure posa (q: in out heap; x: in item) is
      a: puntero renames q.posicion;
      i: natural; -- índice del nodo en el heap
      pi: natural; -- índice del padre del nodo i-ésimo
   begin
      if q.n = size then raise espai_overflow; end if;
      q.n := q.n + 1; i := q.n; pi := q.n/2;
      while pi > 0 and then a(pi) > x loop
         a(i) := a(pi); i := pi; pi := i/2;
      end loop;
      a(i) := x;
   end posa;

   --
   -- Elimina de manera ordenada el ultimo elemento del heap, cuyo probabilidad es la mas pequeña.
   -- @param q heap que contendra los arboles y sus probabilidades
   --
   procedure elimina_darrer (q: in out heap) is
      a: puntero renames q.posicion;
      x: item;
      i: natural; -- índice del nodo en el heap
      ci: natural; -- índice del hijo mínimo del nodo i-ésimo
   begin
      if q.n = 0 then raise mal_us; end if;
      x := a(q.n); q.n := q.n-1;
      i := 1; ci := i*2;
      if ci < q.n and then a(ci+1) < a(ci) then ci := ci+1; end if;
      while ci <= q.n and then a(ci) < x loop
         a(i) := a(ci); i := ci; ci := i*2;
         if ci < q.n and then a(ci+1) < a(ci) then ci := ci+1; end if;
      end loop;
      a(i) := x;
   end elimina_darrer;

   function darrer (q: in heap) return item is
   begin
      if q.n = 0 then raise mal_us; end if;
      return q.posicion(1);
   end darrer;
end heap;
