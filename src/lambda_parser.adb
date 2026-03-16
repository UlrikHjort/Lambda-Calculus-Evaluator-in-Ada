-- ***************************************************************************
--                 Lambda_Parser - Package Body
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

with Ada.Strings.Fixed; use Ada.Strings.Fixed;

package body Lambda_Parser is

   type Token_Kind is (TK_Slash, TK_Dot, TK_LParen, TK_RParen, TK_Ident, TK_EOF);

   type Token is record
      Kind  : Token_Kind;
      Value : String (1 .. 100);
      Len   : Natural := 0;
   end record;

   Pos : Natural;
   Input_Str : access constant String;

   -- Returns the character at current position (NUL if past end)
   function Current_Char return Character is
   begin
      if Pos > Input_Str'Last then
         return ASCII.NUL;
      else
         return Input_Str (Pos);
      end if;
   end Current_Char;

   -- Moves the position forward by one character
   procedure Advance is
   begin
      Pos := Pos + 1;
   end Advance;

   -- Skips whitespace characters (space, tab, newline, CR)
   procedure Skip_Whitespace is
   begin
      while Pos <= Input_Str'Last and then
            (Input_Str (Pos) = ' ' or Input_Str (Pos) = ASCII.HT or
             Input_Str (Pos) = ASCII.LF or Input_Str (Pos) = ASCII.CR)
      loop
         Advance;
      end loop;
   end Skip_Whitespace;

   -- Lexer: returns the next token from input
   function Next_Token return Token is
      T : Token;
   begin
      Skip_Whitespace;

      if Pos > Input_Str'Last then
         T.Kind := TK_EOF;
         return T;
      end if;

      case Current_Char is
         when '/' =>
            T.Kind := TK_Slash;
            Advance;
         when '.' =>
            T.Kind := TK_Dot;
            Advance;
         when '(' =>
            T.Kind := TK_LParen;
            Advance;
         when ')' =>
            T.Kind := TK_RParen;
            Advance;
         when 'a' .. 'z' | 'A' .. 'Z' =>
            T.Kind := TK_Ident;
            T.Len := 0;
            while Pos <= Input_Str'Last and then
                  (Input_Str (Pos) in 'a' .. 'z' or Input_Str (Pos) in 'A' .. 'Z' or
                   Input_Str (Pos) in '0' .. '9' or Input_Str (Pos) = '_')
            loop
               T.Len := T.Len + 1;
               T.Value (T.Len) := Input_Str (Pos);
               Advance;
            end loop;
         when others =>
            raise Parse_Error with "Unexpected character: " & Current_Char;
      end case;

      return T;
   end Next_Token;

   Current_Token : Token;

   -- Consumes current token if it matches Expected, else raises Parse_Error
   procedure Consume (Expected : Token_Kind) is
   begin
      if Current_Token.Kind /= Expected then
         raise Parse_Error with "Expected token kind";
      end if;
      Current_Token := Next_Token;
   end Consume;

   function Parse_Atom return Term_Ptr;
   function Parse_Application return Term_Ptr;
   function Parse_Expr return Term_Ptr;

   -- Parses atomic expressions: variables, parenthesized expr, or lambda
   function Parse_Atom return Term_Ptr is
   begin
      case Current_Token.Kind is
         when TK_Ident =>
            declare
               Name : constant String := Current_Token.Value (1 .. Current_Token.Len);
               Result : constant Term_Ptr := Make_Var (Name);
            begin
               Consume (TK_Ident);
               return Result;
            end;
         when TK_LParen =>
            Consume (TK_LParen);
            declare
               Result : constant Term_Ptr := Parse_Expr;
            begin
               Consume (TK_RParen);
               return Result;
            end;
         when TK_Slash =>
            Consume (TK_Slash);
            if Current_Token.Kind /= TK_Ident then
               raise Parse_Error with "Expected parameter name after /";
            end if;
            declare
               Param : constant String := Current_Token.Value (1 .. Current_Token.Len);
            begin
               Consume (TK_Ident);
               Consume (TK_Dot);
               return Make_Abs (Param, Parse_Expr);
            end;
         when others =>
            raise Parse_Error with "Unexpected token in atom";
      end case;
   end Parse_Atom;

   -- Parses left-associative function application (f x y = (f x) y)
   function Parse_Application return Term_Ptr is
      Result : Term_Ptr := Parse_Atom;
   begin
      while Current_Token.Kind in TK_Ident | TK_LParen | TK_Slash loop
         Result := Make_App (Result, Parse_Atom);
      end loop;
      return Result;
   end Parse_Application;

   -- Top-level expression parser
   function Parse_Expr return Term_Ptr is
   begin
      return Parse_Application;
   end Parse_Expr;

   -- Entry point: parses a lambda expression string into an AST
   function Parse (Input : String) return Term_Ptr is
   begin
      Input_Str := Input'Unrestricted_Access;
      Pos := Input'First;
      Current_Token := Next_Token;
      return Parse_Expr;
   end Parse;

end Lambda_Parser;
