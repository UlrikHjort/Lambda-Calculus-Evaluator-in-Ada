-- ***************************************************************************
--                      Lambda - Package Specification
--
--           Copyright (C) 2026 By Ulrik Hørlyk Hjort
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ***************************************************************************

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

package Lambda is

   type Term;
   type Term_Ptr is access Term;

   package Term_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Unbounded_String);

   type Term_Kind is (Variable, Abstraction, Application);

   type Term (Kind : Term_Kind := Variable) is record
      case Kind is
         when Variable =>
            Name : Unbounded_String;
         when Abstraction =>
            Param     : Unbounded_String;
            Abs_Body  : Term_Ptr;
         when Application =>
            Func : Term_Ptr;
            Arg  : Term_Ptr;
      end case;
   end record;

   -- Creates a variable term node
   function Make_Var (Name : String) return Term_Ptr;

   -- Creates a lambda abstraction (/param.body)
   function Make_Abs (Param : String; Abs_Body : Term_Ptr) return Term_Ptr;

   -- Creates a function application (func arg)
   function Make_App (Func : Term_Ptr; Arg : Term_Ptr) return Term_Ptr;

   -- Collects all free (unbound) variables in a term
   function Free_Variables (T : Term_Ptr) return Term_Vectors.Vector;

   -- Generates a fresh variable name not in the Avoid set
   function Fresh_Var (Base : String; Avoid : Term_Vectors.Vector) return String;

   -- Substitutes Value for Var in T with alpha-conversion
   function Substitute (T : Term_Ptr; Var : String; Value : Term_Ptr) return Term_Ptr;

   -- Creates a deep copy of a term
   function Copy_Term (T : Term_Ptr) return Term_Ptr;

   -- Performs one beta-reduction step, returns null if normal form
   function Eval_Step (T : Term_Ptr) return Term_Ptr;

   -- Fully evaluates a term to normal form
   function Eval (T : Term_Ptr; Max_Steps : Natural := 1000) return Term_Ptr;

   -- Converts a term to its string representation
   function To_String (T : Term_Ptr) return String;

end Lambda;
