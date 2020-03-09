# Type-define-refine approach

- The approach is threefold:

1. Type—Either write a type to begin the process, or inspect the type
of a hole to decide how to continue the process.
1. Define—Create the structure of a function definition either by creating an
outline of a definition or breaking it down into smaller components.
1. Refine—Improve an existing definition either by filling in a hole
or making its type more precise.

Following the TDD book [Brady17](#Brady17), we use the Atom editor to illustrate the process.
(Idris defines an IDE API such that editors like Atom, Emacs or Vi can interact
with the REPL.)

## The `allLenghts` function {.allowframebreaks}

- Let us write a function that given a list of strings computes a list of integers
denoting the length of each string in the given list.

- Type.
Which should be the type for `allLenghts`? Our "problem statement" has already
specified it so we just have to write it down:
```idris
allLenghts : List String -> List Nat
```

- After loading the file `tdr.lidr` we get the following.
```idris
Type checking ./tdr.lidr
Holes: Main.allLenghts
*tdr> allLenghts
allLenghts : List String -> List Nat
Holes: Main.allLenghts
```

- There is no surprise with the type but there is a `Hole` in our program. Obviously
is because we did not declare the equations that define `allLenghts`. This may
also occur when Idris fails to type-check a given program.

- Define
Idris may help us think about which cases our function must handle. In the Atom
editor, we press Ctrl+Alt+A, producing the following definition:
```idris
allLenghts : List String -> List Nat
allLenghts xs = ?allLenghts_rhs
```

- Of course this is not enough. Here is what Idris says when we load it like this:
```idris
Type checking ./tdr.lidr
Holes: Main.allLenghts_rhs
```

- Let us think about it: what just happened here? Nothing more than create an
equation saying that when the `xs` list is given, "something"
`?allLenghts_rhs`-ish will happen. Simple but useful when we repeat this
process. It is even more useful as a learning tool. Let's continue!

- Idris won't leave us with our hands hanging here. It can assist us on thinking
about what `?allLenghts_rhs` should look like if we inspect `xs`.

- If we press Ctrl+Alt+C on `xs` the editor spits out the following code:
```idris
allLenghts : List String -> List Nat
allLenghts [] = ?allLenghts_rhs_1
allLenghts (x :: xs) = ?allLenghts_rhs_2
```

- Two equations were produced because lists in Idris are defined either as the
empty list, denoted by `[]`, or a non-empty list denoted by the _pattern_
`x :: as`, where `x` is the first element of the given list, which is
concatenated to the rest of list in `xs` by the operator `::`.

- Nice, and now we have two holes to think about, when the given list is empty
and otherwise. Idris allows us to check the type of each hole using the command
Ctrl+Alt+T when the cursor is on top of each variable.

```idris
--------------------------------------
allLenghts_rhs_1 : List Nat

x : String
xs : List String
--------------------------------------
allLenghts_rhs_2 : List Nat
```

- Refine.
The refinement of `allLenghts_rhs_1` is trivial: Ctrl+Alt+S (_proof search_)
on it gives us `[]`.

- For `allLenghts_rhs_2` we need to know however that there exists a `length`
operation on strings. We should than apply it `x` and "magically" build the
rest of the resulting string. Our code now looks like this:
```idris
allLenghts : List String -> List Nat
allLenghts [] = []
allLenghts (x :: xs) = (length x) :: ?magic
```

- Atom and Idris may help us identify what
[kind of magic](https://open.spotify.com/track/5RYLa5P4qweEAKq5U1gdcK?si=TV5gMDD6R2mDlFGoVjPU4Q)
is this. We just have to Ctrl+Alt+T it to get:
```idris
x : String
xs : List String
--------------------------------------
magic : List Nat
```

- So now we need _faith on recursion_ (as Roberto Ierusalimschy, a co-author of
Lua, says) and let the rest of the problem "solve itself".
Finally, we reach the following implementation:

```idris

> module Main
>
> allLenghts : List String -> List Nat
> allLenghts [] = []
> allLenghts (x :: xs) = (length x) :: allLenghts xs

```

- Awesome! For our final magic trick, I would like to know if Idris has a function
that given a string produces a list of strings whose elements are the substrings
of the first. Try this on the REPL:

```idris
*type-define-refine/tdr> :search String -> List String
= Prelude.Strings.lines : String -> List String
Splits a string into a list of newline separated strings.
= Prelude.Strings.words : String -> List String
Splits a string into a list of whitespace separated
strings.
...
```

- It turns out that `words` is exactly what I was looking for!
Run the following:
```idris
*type-define-refine/tdr>
:let l = "Here we are, born to be kings,
       	        we are princess of the universe!"
*type-define-refine/tdr> words l
["Here",
 "we",
 "are,",
 "born",
 "to",
 "be",
 "kings,",
 "we",
 "are",
 "princess",
 "of",
 "the",
 "universe!"] : List String
```

- And Finally
```idris
*type-define-refine/tdr> :let w = words l
*type-define-refine/tdr> allLenghts w
[4, 2, 4, 4, 2, 2, 6, 2, 3, 8, 2, 3, 9] : List Nat
```

## Lab {.allowframebreaks}

In the labs in this short-course you will have to complete or fix some Idris code.

- First lab.

The first lab is to complete the code below using what we have discussed so far.

```idris

> wordCount : String -> Nat
> -- Type-define-refine this function!
> -- Start by running `Ctrl+Alt+A` to add a definition, 
> -- than `Ctrl+Alt+C` to split cases and finally 
> -- `Ctrl+Alt+S` to search for proofs(!) that represent
> -- the code you need! (Intrigued? Ask the instructor 
> -- for an advanced course on this topic than = ) 
>
> average : (str : String) -> Double
> average str = 
>         let numWords = wordCount str
>             totalLength = 
>                   sum (allLenghts (words str))
>         in ?w
> -- Which is the type of `?w1`?
> -- Proof search won't help you here, unfortunately...
> -- Run `:doc sum` at the REPL. Just read the 
> -- documentation at the moment, not the type of `sum`.
>
> showAverage : String -> String
> showAverage str =
>   let m = "The average word length is: "
>       a = average ?w
>   in m ++ show (a) ++ "\n"
> -- Check the type o `w` and think about it!
>
> main : IO ()
> main = repl "Enter a string: " showAverage

```

- Using the example string from above, you should get the following spit at you:
```idris
Sat Aug 03@18:05:17:type-define-refine$ 
idris --nobanner tdr.lidr
Type checking ./tdr.lidr
*tdr> :exec main
Enter a string: 
Here we are, born to be kings, 
  we are princess of the universe!
The average word length is: 3.923076923076923
```

- Moreover, you may _compile it_ to an executable with the following command line:
```shell
idris --nobanner tdr.lidr -o tdr
```
and then execute it, as follows.
```shell
Sun Aug 04@12:39:21:type-define-refine$ ./tdr
Enter a string:
```
