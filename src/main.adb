-- ***************************************************************************
--                  Main - Lambda Calculus REPL
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

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Command_Line;
with Interfaces.C_Streams;
with Lambda; use Lambda;
with Lambda_Parser; use Lambda_Parser;

procedure Main is

   procedure Process_Line (Line : String) is
      Term   : Term_Ptr;
      Result : Term_Ptr;
   begin
      if Line'Length = 0 or else Line (Line'First) = '#' then
         return;
      end if;

      Term := Parse (Line);
      Result := Eval (Term);
      Put_Line (To_String (Result));
   exception
      when Parse_Error =>
         Put_Line ("Parse error!");
      when E : others =>
         Put_Line ("Error: " & Ada.Exceptions.Exception_Name (E));
   end Process_Line;

   function Is_Terminal return Boolean is
      function isatty (fd : Interfaces.C_Streams.int) return Interfaces.C_Streams.int
        with Import => True, Convention => C, External_Name => "isatty";
   begin
      return isatty (0) /= 0;
   end Is_Terminal;

   Line : Unbounded_String;
   Is_Interactive : Boolean;

begin
   Is_Interactive := Is_Terminal;

   if Is_Interactive then
      Put_Line ("Lambda Calculus REPL");
      Put_Line ("Type expressions, press Enter to evaluate");
      Put_Line ("Example: /x.x or (/x.x) y");
      Put_Line ("Press Ctrl+D to exit");
      New_Line;
   end if;

   loop
      if Is_Interactive then
         Put ("> ");
         Flush;
      end if;

      exit when End_Of_File;

      Line := To_Unbounded_String (Get_Line);
      Process_Line (To_String (Line));

   end loop;

   if Is_Interactive then
      New_Line;
   end if;

end Main;
