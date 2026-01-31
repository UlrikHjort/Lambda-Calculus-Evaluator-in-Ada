-- ***************************************************************************
--                      Lambda - Package Body
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

package body Lambda is

   -- Creates a variable term node
   function Make_Var (Name : String) return Term_Ptr is
   begin
      return new Term'(Kind => Variable, Name => To_Unbounded_String (Name));
   end Make_Var;

   -- Creates a lambda abstraction (/param.body)
   function Make_Abs (Param : String; Abs_Body : Term_Ptr) return Term_Ptr is
   begin
      return new Term'(Kind => Abstraction,
                       Param => To_Unbounded_String (Param),
                       Abs_Body => Abs_Body);
   end Make_Abs;

   -- Creates a function application (func arg)
   function Make_App (Func : Term_Ptr; Arg : Term_Ptr) return Term_Ptr is
   begin
      return new Term'(Kind => Application, Func => Func, Arg => Arg);
   end Make_App;

   -- Collects all free (unbound) variables in a term
   function Free_Variables (T : Term_Ptr) return Term_Vectors.Vector is
      Result : Term_Vectors.Vector;
   begin
      case T.Kind is
         when Variable =>
            Result.Append (T.Name);
         when Abstraction =>
            Result := Free_Variables (T.Abs_Body);
            for I in Result.First_Index .. Result.Last_Index loop
               if Result (I) = T.Param then
                  Result.Delete (I);
                  exit;
               end if;
            end loop;
         when Application =>
            Result := Free_Variables (T.Func);
            declare
               Arg_FV : constant Term_Vectors.Vector := Free_Variables (T.Arg);
            begin
               for FV of Arg_FV loop
                  if not Result.Contains (FV) then
                     Result.Append (FV);
                  end if;
               end loop;
            end;
      end case;
      return Result;
   end Free_Variables;

   -- Generates a fresh variable name not in the Avoid set
   function Fresh_Var (Base : String; Avoid : Term_Vectors.Vector) return String is
      Candidate : Unbounded_String := To_Unbounded_String (Base);
      Counter   : Natural := 0;
   begin
      while Avoid.Contains (Candidate) loop
         Counter := Counter + 1;
         Candidate := To_Unbounded_String (Base & Natural'Image (Counter)(2 .. Natural'Image (Counter)'Last));
      end loop;
      return To_String (Candidate);
   end Fresh_Var;

   -- Creates a deep copy of a term
   function Copy_Term (T : Term_Ptr) return Term_Ptr is
   begin
      case T.Kind is
         when Variable =>
            return Make_Var (To_String (T.Name));
         when Abstraction =>
            return Make_Abs (To_String (T.Param), Copy_Term (T.Abs_Body));
         when Application =>
            return Make_App (Copy_Term (T.Func), Copy_Term (T.Arg));
      end case;
   end Copy_Term;

   -- Substitutes Value for Var in T with alpha-conversion to avoid capture
   function Substitute (T : Term_Ptr; Var : String; Value : Term_Ptr) return Term_Ptr is
   begin
      case T.Kind is
         when Variable =>
            if To_String (T.Name) = Var then
               return Copy_Term (Value);
            else
               return Copy_Term (T);
            end if;
         when Abstraction =>
            if To_String (T.Param) = Var then
               return Copy_Term (T);
            else
               declare
                  Value_FV : constant Term_Vectors.Vector := Free_Variables (Value);
               begin
                  if Value_FV.Contains (T.Param) then
                     declare
                        Body_FV   : constant Term_Vectors.Vector := Free_Variables (T.Abs_Body);
                        All_FV    : Term_Vectors.Vector := Body_FV;
                        New_Param : String := Fresh_Var (To_String (T.Param), All_FV);
                        New_Body  : Term_Ptr;
                     begin
                        for FV of Value_FV loop
                           if not All_FV.Contains (FV) then
                              All_FV.Append (FV);
                           end if;
                        end loop;
                        New_Param := Fresh_Var (To_String (T.Param), All_FV);
                        New_Body := Substitute (T.Abs_Body, To_String (T.Param), Make_Var (New_Param));
                        New_Body := Substitute (New_Body, Var, Value);
                        return Make_Abs (New_Param, New_Body);
                     end;
                  else
                     return Make_Abs (To_String (T.Param), Substitute (T.Abs_Body, Var, Value));
                  end if;
               end;
            end if;
         when Application =>
            return Make_App (Substitute (T.Func, Var, Value),
                           Substitute (T.Arg, Var, Value));
      end case;
   end Substitute;

   -- Performs one beta-reduction step, returns null if in normal form
   function Eval_Step (T : Term_Ptr) return Term_Ptr is
   begin
      case T.Kind is
         when Variable =>
            return null;
         when Abstraction =>
            declare
               Body_Step : constant Term_Ptr := Eval_Step (T.Abs_Body);
            begin
               if Body_Step /= null then
                  return Make_Abs (To_String (T.Param), Body_Step);
               else
                  return null;
               end if;
            end;
         when Application =>
            if T.Func.Kind = Abstraction then
               return Substitute (T.Func.Abs_Body, To_String (T.Func.Param), T.Arg);
            else
               declare
                  Func_Step : constant Term_Ptr := Eval_Step (T.Func);
               begin
                  if Func_Step /= null then
                     return Make_App (Func_Step, T.Arg);
                  else
                     declare
                        Arg_Step : constant Term_Ptr := Eval_Step (T.Arg);
                     begin
                        if Arg_Step /= null then
                           return Make_App (T.Func, Arg_Step);
                        else
                           return null;
                        end if;
                     end;
                  end if;
               end;
            end if;
      end case;
   end Eval_Step;

   -- Fully evaluates a term to normal form (up to Max_Steps)
   function Eval (T : Term_Ptr; Max_Steps : Natural := 1000) return Term_Ptr is
      Current : Term_Ptr := Copy_Term (T);
      Next    : Term_Ptr;
   begin
      for I in 1 .. Max_Steps loop
         Next := Eval_Step (Current);
         exit when Next = null;
         Current := Next;
      end loop;
      return Current;
   end Eval;

   -- Converts a term to its string representation
   function To_String (T : Term_Ptr) return String is
   begin
      case T.Kind is
         when Variable =>
            return To_String (T.Name);
         when Abstraction =>
            return "/" & To_String (T.Param) & "." & To_String (T.Abs_Body);
         when Application =>
            declare
               Func_Str : constant String := To_String (T.Func);
               Arg_Str  : constant String := To_String (T.Arg);
            begin
               if T.Arg.Kind = Application then
                  return Func_Str & " (" & Arg_Str & ")";
               else
                  return Func_Str & " " & Arg_Str;
               end if;
            end;
      end case;
   end To_String;

end Lambda;
