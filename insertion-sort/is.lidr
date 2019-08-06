# Insertion sort lab.

- Here is what we will implement:
 - Given an empty vector, return an empty vector.
 - Given the head and tail of a vector, _sort_ the tail of the vector and then
insert the head into the sorted tail such that the result remains sorted.

- At the end, you should be able to run the following at the REPL:
```idris
*VecSort> insSort [1,3,2,9,7,6,4,5,8]
[1, 2, 3, 4, 5, 6, 7, 8, 9] : Vect 9 Integer
```

I will first walk you through the development of most of the code. At the end
of the section I list your activities for this lab.

## Type-define-refine {.allowframebreaks}

- Type
We will use the `Vect` datatype available in Idris' prelude.
```idris

> import Data.Vect

```
And it is easy to grasp the signature of our function, so here it goes.
```idris
insSort : Vect n elem -> Vect n elem
```
- Define
Now we add a clause using `Ctrl+Alt+A` on `inSort`, resulting in
```idris
insSort : Vect n elem -> Vect n elem
insSort xs = ?insSort_rhs
```
and do a case split on variable `xs`.
```idris
insSort : Vect n elem -> Vect n elem
insSort [] = ?insSort_rhs_1
insSort (x :: xs) = ?insSort_rhs_2
```
- Refine
```idris
insSort : Vect n elem -> Vect n elem
insSort [] = []
insSort (x :: xs) = ?insSort_rhs_2
```

- Proof search works just fine for `?insSort_rhs_1` but not so much for
`?insSort_rhs_2`, as it simply produces
```idris
insSort (x :: xs) = ?insSort_rhs_2
```
- And why is that? Because there is no _silver bullet_ and you need to understand
the algorithm! The informal specification is quite clear: we need to insert `x` into
a sorted (tail) list.
```idris
insSort (x :: xs) = let l = insSort xs in ?insSort_rhs_2
```

- We can now ask the system to help us with `?insSort_rhs_2` in this context by
pressing Ctrl+Alt+L on it. Here is what it creates:
```idris
insSort_rhs_2 : (x : elem) -> (xs : Vect len elem) -> (l : Vect len elem) -> Vect (S len) elem
insSort (x :: xs) = let l = insSort xs in (insSort_rhs_2 x xs l)
```
It generates a _stub_ of a function with all the variables in the context.

- Since we are following quite easily `=(` what is going on, we now that we need
to rename `insSort_rhs_2` to `insert` (just for readability) and get rid of `xs`
in the application, leaving us with
```idris
insSort (x :: xs) = let l = insSort xs in (insert x l)
```

- Awesome! Let us now define `insert` as the lifting process (with Ctrl+Alt+L)
already (overly)defined its type for us. So let us add a clause on `insert`, and
case-split `l`. It leaves us with the following code once we search for a proof
for hole 1.
```idris
insert : (x : elem) -> (l : Vect len elem) -> Vect (S len) elem
insert x [] = [x]
insert x (y :: xs) = ?insSort_rhs_2
insSort : Vect n elem -> Vect n elem
insSort [] = []
insSort (x :: xs) = let l = insSort xs in (insert x l)
```

- Proof search will not help us with hole 2, as there are some things we need to
figure out. Let us think for a moment what `insert` should do.
There are two cases to consider:
 - If x < y, the result should be x :: y :: xs, because the result won’t be
_ordered_ if x is inserted after y.
 - Otherwise, the result should begin with y, and then have x inserted into
the tail xs.

- In a _type safe_ context we need to make sure that `insert` will be able to
compare `x` and `y`. In object-oriented terms, that object `x` knows how to
answer to message `<` or that the algebra of `x` and `y` is an order!

- Idris implements the concept of _type classes_, called `interfaces` in Idris
and are precisely that: they define operations that a certain datatype must fulfill.

- One such type class is `Ord`.
```idris
interface Eq a => Ord a where
    compare : a -> a -> Ordering

    (<) : a -> a -> Bool
    (>) : a -> a -> Bool
    (<=) : a -> a -> Bool
    (>=) : a -> a -> Bool
    max : a -> a -> a
    min : a -> a -> a
```

- It relies on yet another type class called `Eq`, that defines the equality relation
and defines a number of operations, including `<`.
Type-classes form an important concept in strongly-typed functional programming but
we will not explore it any further in this short-course.

- Having said that, we need to constraint `insert` such that `elem` is an _ordered_ type.
```idris

> insert : Ord elem => (x : elem) -> (l : Vect len elem) -> Vect (S len) elem
> insert x [] = [x]
> insert x (y :: xs) = ?insert_rhs

> insSort : Ord elem => Vect n elem -> Vect n elem
> insSort [] = []
> insSort (x :: xs) = let l = insSort xs in (insert x l)

```

## Lab activities

- So, finally, here is what you should do:
1. Perform all the steps described above until you reach the code above.
1. Replace the meta-variable with the appropriate `if then else` code or search
for Ctrl+Alt+M (to generate a `case`-based code) command on the web and try i.t
