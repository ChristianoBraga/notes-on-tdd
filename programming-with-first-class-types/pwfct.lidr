
# Programming with type-level functions

Here are a couple of examples where first-class types can be useful:
- Given an HTML form on a web page, you can calculate the type of a function to process inputs in the form.
- Given a database schema, you can calculate types for queries on that
  database. In other words, the type of a value returned by a database
  query may vary _depending on_ the database _schema_ and the _query_
  itself, calculated by **type-level functions**.

This should be useful in a number of contexts such as Data validation
in Robotic Process Automation, SQL Injection, (Business) Process
Protocol Validation, just to name a few.

In this section we discuss and illustrate how this way of programming
is available in the Idris language.

## Formatted output example

This examples explores some of the components for the RPA scenario. It
explores how to make strings from properly-typed data using
type-functions.

```idris

> module Format
> 
> data Format = 
> Number Format
> | Str Format
> | Lit String Format
> | End

```

Try this at the REPL:
```idris
*pwfct> Str (Lit " = " (Number End))
Str (Lit " = " (Number End)) : Format
```

```idris

> PrintfType : Format -> Type
> PrintfType (Number fmt) = (i : Int) -> PrintfType fmt
> PrintfType (Str fmt) = (str : String) -> PrintfType fmt
> PrintfType (Lit str fmt) = PrintfType fmt
> PrintfType End = String

```

Try this at the REPL:
```idris
*pwfct> PrintfType (Str (Lit " = " (Number End)))
String -> Int -> String : Type
```

```idris

> printfFmt : (fmt : Format) -> (acc : String) -> PrintfType fmt
> printfFmt (Number fmt) acc = \i => printfFmt fmt (acc ++ show i)
> printfFmt (Str fmt) acc = \str => printfFmt fmt (acc ++ str)
> printfFmt (Lit lit fmt) acc = printfFmt fmt (acc ++ lit)
> printfFmt End acc = acc

```

```idris

> toFormat : (xs : List Char) -> Format
> toFormat [] = End
> toFormat ('%' :: 'd' :: chars) = Number (toFormat chars)
> toFormat ('%' :: 's' :: chars) = Str (toFormat chars)
> toFormat ('%' :: chars) = Lit "%" (toFormat chars)
> toFormat (c :: chars) = case toFormat chars of
>                             Lit lit chars' => Lit (strCons c lit) chars'
>                             fmt => Lit (strCons c "") fmt

```

```idris                           

> printf : (fmt : String) -> PrintfType (toFormat (unpack fmt))
> printf fmt = printfFmt _ ""

```

Try this out at the REPL:
```idris
*pwfct> :let msg = "The author of %s, published in %d, is %s."
*pwfct> :let b = "A Brief History of Time"
*pwfct> :let a = "Stephen Hawking"
*pwfct> :let y = the Int 1988
*pwfct> printf msg b y a
"The author of A Brief History of Time, published in 1988, is Stephen Hawking." : String
```

For variable `y` we had to make sure it is an `Int` (finite), not an
`Integer` (infinite) number, due to `PrintfType` definition. This is
what `the Int 1988` does. Try it without the casting and see what
happens...

## Caveats
(From TDD book.)

In general, it’s best to consider type-level functions in exactly the
same way as ordinary functions. This isn’t
always the case, though. There are a couple of technical differences
that are useful to know about: 

- Type-level  functions  exist  at  _compile_ time  only.  There’s  no
runtime representation of Type, and no way to inspect a Type directly,
such as pattern matching.

- Only functions that are total will be evaluated at the type level. A
function that isn’t total may not terminate, or may not cover all
possible inputs. Therefore, to ensure that type-checking itself
terminates, functions that are not total are treated as constants at
the type level, and don’t evaluate further.
