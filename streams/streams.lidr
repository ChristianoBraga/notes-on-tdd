# Infinite data and processes

## Infinite data {.allowframebreaks}

- Streams are infinite sequences of values, and you can process one
  value at a time.

- When you write a function to generate a Stream, you give a prefix of
the Stream and generate the remainder recursively. You can think of an
interactive program as being a program that produces a potentially
infinite sequence of interactive actions.
```idris

> %default total
> data InfIO : Type where
>     Do : IO a -> (a -> Inf InfIO) -> InfIO
> (>>=) : IO a -> (a -> Inf InfIO) -> InfIO
> (>>=) = Do
> loopPrint : String -> InfIO
> loopPrint msg = do putStrLn msg
>                    loopPrint msg
> partial
> run : InfIO -> IO ()
> run (Do action cont) = do res <- action
>                           run (cont res)

```

- Try the following at the REPL:
```idris
:exec run (loopPrint "on and on and on...")
```
and a non-terminating execution will present itself.
As expected, `run` is *not* total:
```
*streams/streams> :total run
Main.run is possibly not total due to recursive path:
    Main.run, Main.run
```

- The type `InfIO`, as the name suggests, is a type of infinite IO
  actions, denoted by the type variable `a`. The `Do` constructor
  receives an IO action and produces an infinite IO action, by
  recursion.

- Function `loopPrint` is one such _action generator_.

- Let us take this slowly: First of all, what is the `Inf` type?
```idris
Inf : Type -> Type
Delay : (value : ty) -> Inf ty
Force : (computation : Inf ty) -> ty
```
  - `Inf` is a generic type of potentially infinite computations. 
  - `Delay`
  is a function that states that its argument should only be evaluated
  when its result is forced. 
  - Force is a function that returns the result from a delayed computation.                          

## Another example with infinite data {.allowframebreaks}

- `InfList` is similar to the List generic type, with two significant differences:
  - There’s no `Nil` constructor, only a `(::)` constructor, so there’s no way to end the list.
  - The recursive argument is wrapped inside `Inf`.

```idris

> data InfList : Type -> Type where
>     (::) : (value : elem) -> Inf (InfList elem) -> 
>     InfList elem

```

- Function `countFrom` is an example on how to use `Inf`.
```idris

> countFrom : Integer -> InfList Integer
> countFrom x = x :: Delay (countFrom (x + 1))

```
The Delay means that the remainder of the list will only be calculated when explicitly requested using Force.

Try the following at the REPL:
```idris
*streams> countFrom 0
0 :: Delay (countFrom 1) : InfList Integer
```

## Streams {.allowframebreaks}

- Idris has streams in its prelude. 

```idris
data Stream : Type -> Type where
   (::) : (value : elem) -> Inf (Stream elem) -> 
                            Stream elem
repeat : elem -> Stream elem
take : (n : Nat) -> (xs : Stream elem) -> List elem
iterate : (f : elem -> elem) -> (x : elem) -> Stream elem
```

- Execute 
```idris
 (iterate (+1) 0)
*streams/streams> (iterate (+1) 0)
0 ::
Delay (iterate (\ARG => prim__addBigInt ARG 1) 1) : Stream Integer
```
and try to grasp which type is this.

- Here are some cool stuff we can do with streams, try it out:
```idris
Idris> take 10 [1..]
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10] : List Integer
```
The syntax [1..] generates a Stream counting upwards from 1. 

- This works for any countable numeric type, as in the following example:
```idris
Idris> the (List Int) take 10 [1..]
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10] : List Int
```
or
```idris
Idris> the (List Int) (take 10 [1,3..])
[1, 3, 5, 7, 9, 11, 13, 15, 17, 19] : List Int
```

- Now, which is the relationship between all this machinery and the
  motivation presented at the beginning of the course?
  - Are there any relations among IOT sensors and 
streams?

- You should probably have realized by now that `run` is an _infinite
  process_ executing on an _infinite stream_ of data!

## Making infinite processes total {.allowframebreaks}

- As trivial as it may sound, a way to make a function terminate is
  simply to define a "time out".

- In the following example, this is denoted by the `Fuel`
  datatype. The `Lazy` datatype is similar to the `Inf` we have seen
  before, it "encapsulates" infinite data and only computes it when
  necessary. 

```idris

> data Fuel =
>  Dry | More (Lazy Fuel)
>
> tank : Nat -> Fuel
> tank Z = Dry
> tank (S k) = More (tank k)
>
> partial
> runPartial : InfIO -> IO ()
> runPartial (Do action f) = 
>            do res <- action
>               runPartial (f res)
>
> run2 : Fuel -> InfIO -> IO ()
> run2 (More fuel) (Do c f) = 
>      do res <- c
>         run2 fuel (f res)
> run2 Dry p = putStrLn "Out of fuel"
>
> partial
> main : IO ()
> main = run2 (tank 10) (loopPrint "vroom")

```

## `Inf` vs. `Lazy` {.allowframebreaks}

- If the argument has type Lazy ty, for some type ty, it’s considered
  smaller than the constructor expression.

- If the argument has type Inf ty, for some type ty, it’s not
  considered smaller than the constructor expression, because it may
  continue expanding indefi- nitely. Instead, Idris will check that
  the overall expression is productive


