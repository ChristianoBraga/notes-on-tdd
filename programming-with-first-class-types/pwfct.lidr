
# Programming with type-level functions {.allowframebreaks}

- Here are a couple of examples where first-class types can be useful:
  - Given an HTML form on a web page, you can calculate the type of a function to process inputs in the form.
  - Given a database schema, you can calculate types for queries on that
  database. In other words, the type of a value returned by a database
  query may vary _depending on_ the database _schema_ and the _query_
  itself, calculated by **type-level functions**.

- This should be useful in a number of contexts such as Data validation
in Robotic Process Automation, SQL Injection, (Business) Process
Protocol Validation, just to name a few.

- In this section we discuss and illustrate how this way of programming
is available in the Idris language.

## Formatted output example {.allowframebreaks}

- This examples explores some of the components for the RPA scenario. It
exemplifies how to make strings from properly-typed data using
type-functions, similarly to the `printf` function in the C
programming language.

```idris

> module Format
> 
> data Format = 
> Number Format
> | Str Format
> | Lit String Format
> | End

```

- The `Format` datatype is an _inductive_ one: is a "list" such that its
elements are either `Number`, `Str`, `Lit s` (where `s` is string) or
`End`. It will be used to _encode_, or to represent, in Idris, a
formatting string.

- Try this at the REPL:
```idris
*pwfct> Str (Lit " = " (Number End))
Str (Lit " = " (Number End)) : Format
```

- This instance of `Format` represents the formatting string "%s = %d"
in C's `printf`.

- So far, nothing new, despite the fact that we now realize that our
datatypes can be recursive.
 
- Function `PrintfType` is a _type-level function_. It describes the
_functional type_ associated with a format. 

```idris

> PrintfType : Format -> Type
> PrintfType (Number fmt) = (i : Int) -> PrintfType fmt
> PrintfType (Str fmt) = (str : String) -> PrintfType fmt
> PrintfType (Lit str fmt) = PrintfType fmt
> PrintfType End = String

```

- Recall that a functional type is built using the `->` constructor. The
first equation declares that a `Number` format is denoted by an `Int`
in the associated type. The remaining equations define similar
denotations.

- Try this at the REPL:
```idris
*pwfct> PrintfType (Str (Lit " = " (Number End)))
String -> Int -> String : Type
```

- As I mentioned before, the format `(Str (Lit " = " (Number End)))`
encodes the C formatting string "%s = %d". The functional type that
denotes it is `String -> Int -> String`, that is, a function that
receives a string and an integer and returns a string.

- Again, `PrintfType` is a type-function, that is, it defines a type. Of
course, we can use it to specify, for instance, the return type of a
function. The recursive function `printfFmt` receives a format, a
string and returns a term of `PrintfType` that _depends on the format
given as first argument_!

```idris

> printfFmt : (fmt : Format) -> (acc : String) -> PrintfType fmt
> printfFmt (Number fmt) acc = \i => printfFmt fmt (acc ++ show i)
> printfFmt (Str fmt) acc = \str => printfFmt fmt (acc ++ str)
> printfFmt (Lit lit fmt) acc = printfFmt fmt (acc ++ lit)
> printfFmt End acc = acc

```

- Function `toFormat` is a normal function that transforms a string denoting a format and creates a _type_ `Format`. Function `printf` is defined next.

```idris

> toFormat : (xs : List Char) -> Format
> toFormat [] = End
> toFormat ('%' :: 'd' :: chars) = Number (toFormat chars)
> toFormat ('%' :: 's' :: chars) = Str (toFormat chars)
> toFormat ('%' :: chars) = Lit "%" (toFormat chars)
> toFormat (c :: chars) = case toFormat chars of
>                             Lit lit chars' => Lit (strCons c lit) chars'
>                             fmt => Lit (strCons c "") fmt
> printf : (fmt : String) -> PrintfType (toFormat (unpack fmt))
> printf fmt = printfFmt _ ""

```

- Try this out at the REPL:
```idris
*pwfct> :let msg = "The author of %s, published in %d, is %s."
*pwfct> :let b = "A Brief History of Time"
*pwfct> :let a = "Stephen Hawking"
*pwfct> :let y = the Int 1988
*pwfct> printf msg b y a
"The author of A Brief History of Time, published in 1988, is Stephen Hawking." : String
```

- At this point you should be able `=(` to understand what is going
  on. Why does `printf` takes four arguments? Shouldn't it be just
  one? (The `fmt : String` above.)

- For variable `y` we had to make sure it is an `Int` (finite), not an
`Integer` (infinite) number, due to `PrintfType` definition. This is
what `the Int 1988` does. Try it without the casting and see what
happens...

## Conclusion

- The point here is that we can use types to help organize the
world. 

- Recall the SQL Injection example from the introductory section. The problem there was the fact that everything was a string. 

- Using the concepts discussed here we could type information coming
from forms and check them before sending them to the DBMS!

## Caveats {.allowframebreaks}
(From TDD book.)

- In general, it’s best to consider type-level functions in exactly the
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
