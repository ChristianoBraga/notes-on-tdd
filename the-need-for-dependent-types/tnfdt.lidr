# The need for dependent types

- Overflow conditions in software appear to be a simple thing to
implement. An important counter-example is the Ariane 5 rocket that
exploded due to a down cast from 64-bit number into a 16-bit one.
\begin{quote}
The Ariane 5 had cost nearly \$8 billion to develop, and was carrying a \$500 million satellite payload when it exploded.
\end{quote}
[11 of the most costly software errors in
history](https://raygun.com/blog/costly-software-errors-history/)

- In this chapter we look at a simplified version of the `Vector`
datatype, available in Idris' library, to try and understand how
_dependent typing_ can be useful to have type-safe array handling that
could help prevent catastrophes such as the Ariane 5 explosion.

## `Vector` {.allowframebreaks}

- A datatype is nothing but an implementation of some "domain of
information". It could very well represent low level information such
as data acquired by a sensor in a Internet of Things (IoT) system or
the structure that organizes the decision making process in planning.

- Our datatype here is quite simple but illustrates very well how
dependent types may help safe data modeling and implementation.

```idris

> module Vect
> data Vect : Nat -> Type -> Type where
>     Nil  : Vect Z a
>     (::) : (x : a) -> (xs : Vect k a) -> Vect (S k) a

```

- An array or vector is built or _constructed_ using either one of the constructor operations (unary) `Nil`
or (binary) `::`. (The `module` keyword here simply defines a
_namespace_ where `Vect` will live.) After loading this file in Idris
you could try
```idris
*tnfdt> 1 :: Vect.Nil
[1] : Vect 1 Integer
```
at the REPL.

- This says that the term `[1]` has type `Vect 1 Integer` meaning that
it is a vector with one element and that its elements of the `Integer`
type, Idris' basic types.

- Maybe this is a lot to take! _[Just
breath](https://open.spotify.com/track/6i81qFkru6Kj1IEsB7KNp2?si=Gpz_flIlTOSn67r_InFBfg)_
and let us think about it for a moment.

- Types are defined in terms of constructor operators. This means that
an _instance_ of this type is written down as `1 :: Vect.Nil`. In a
procedural language you could write it with a code similar to
```python
v = insert(1, createVect(1))
```
where `createVect` returns a vector of a given size and `insert` puts
an element on the given vector. The point is that we usually create
objects or allocate memory to represent data in variables (so called
_side effects_) while in
functional programming we _symbolically_ manipulate them, as in the
example above.

- This is a major paradigm-shift for those not familiar with functional
programming. Be certain that it will become easier as time goes by,
but let's move on!

## Dependency {.allowframebreaks}

- Let's look at the instance first and then to the type
declaration. Note that the type of `[1]` is `Vect 1 Integer`. The type
of a Vect _depends_ on its _size_! Think about examples of vectors in
programming languages you know. If you query for the type of a given
vector, if at all possible, what the run-time of your programming
language will answer?

- In Python, for instance, you would get something like,
```python
v = [1,2,3]
type(v)
<class 'list'>
```
that is, is a `list` and that's all! In C an array is a pointer! (A
reference to a memory address, for crying out loud!)

- In Idris, we know it is a vector and its size, an important property
of this datatype. Cool! And so what?

- We can take advantage of that while programming. We could write a
function that does _not_, under no circumstances, goes beyond the limits
of a vector, that is, index it beyond its range!

## The `zip` function {.allowframebreaks}

- The `zip` function simple creates pairs of elements out of two
instances of `Vect` _with the same size_. Here is what it look like:
```idris

> zip : Vect n a -> Vect n b -> Vect n (a, b)
> zip Nil Nil = Nil
> zip (x :: xs) (y :: ys) = (x, y) :: zip xs ys

```
- What on earth is it? Do you remember how to declare a function in
Idris? Well, is pretty-much that. The difference here is that we are
now programming with _pattern matching_. 

- And what is it? Simply define
a function by _cases_. 

- When we hit an instance of `Vect`, how does it
look like? It is either the empty vector, built with constructor
`Nil`, or a non-empty vector, built using operator `::`. 

- These two
cases are represented by each equation above. The first equation
declares the case of "zipping" two _empty_ vectors and the second one
handles two _non-empty_ vectors, specified by the _pattern_ `x :: xs`,
that is, a vector whose first element is `x` and its remaining
elements are represented by a (sub)vector `xs`.

- For instance, if we could write
```idris
*tnfdt> Vect.zip [1,2,3] ["a", "b", "c"]
[(1, "a"), (2, "b"), (3, "c")] : Vect 3 (Integer, String)
```
and get the expected vector of pairs produced by `zip`. (I used
`Vect.zip` only because there are other `zip` functions coming from
Idris' standard library.) 

- Note that the type of `[(1, "a"), (2, "b"),
(3, "c")]` is `Vect 3 (Integer, String)` where $3$ is the size of the
vector and `(Integer, String)`, denoting pairs of integers and
strings, is the type of the elements of vector that `zip` calculates.

- Note some additional interesting things about `zip`'s declaration:
The signature of `zip` is
`zip : Vect n a -> Vect n b -> Vect n (a, b)`. The variable `n` here
stands for the size of the vector. Variables `a` and `b` denote the
types of the elements of the vectors being zipped. 

- That is, the `Vect`
type is _generic_, as the type of its elements are underspecified, and
is _dependent_ on the **number** denoting its size. Again, `n` is a
_number_, and `a` (or `b`, for that matter) is a _type_!

- Now, take a look at this:
```idris
*tnfdt> Vect.zip [1,2,3] ["a", "b"]
(input):1:19-21:When checking argument xs to constructor Vect.:::
        Type mismatch between
                Vect 0 a (Type of [])
        and
                Vect 1 String (Expected type)

        Specifically:
                Type mismatch between
                        0
                and
                        1
```
- What does this mean? This is a _type checking_ error, complaining
about an attempt to zip vectors of different sizes. This is _not_ an
exception, raised while trying to execute `zip`. This is a _compile_
type message, regarding the case of zip a vector of length $1$ (the
last element of the first vector), and a $0$-sized vector (from the
second vector).

**In Idris, types can be manipulated just like any other language construct.**

## Conclusion.

Ariane 5 would not have exploded (from the bit
conversion perspective) if the function that accidentally
cast a 64-bit vector into a 16-bit one was written with this approach.

## Wrapping-up

1. Defining datatypes.
1. Defining dependent datatypes.
1. Using dependent datatypes to find errors at compile time.
1. Type expressions.
