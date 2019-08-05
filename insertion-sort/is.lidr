# Insertion sort lab.

Here is what we will implement:
- Given an empty vector, return an empty vector.
- Given the head and tail of a vector, _sort_ the tail of the vector and then
insert the head into the sorted tail such that the result remains sorted.

1. Type
We will use the `Vect` datatype avaiable in Idris' prelude.
```idris

> import Data.Vect

```
And it is easy to grasp the signature of our function, so here it goes.
```idris

> insSort : Vect n elem -> Vect n elem

```
1. Define
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
1. Refine
```idris
insSort : Vect n elem -> Vect n elem

> insSort [] = []

insSort (x :: xs) = ?insSort_rhs_2
```
Proof search works just fine for `?insSort_rhs_1` but not so much for
`?insSort_rhs_2`, as it simply produces
```idris
insSort (x :: xs) = ?insSort_rhs_2
```
And why is that? Because there is no _silver bullet_ and you need to understand
the algorithm! But you can use expression search to help fill in the details.
Here, we can sort the tail with a recursive call to `insSort xs` and bind the
result to a locally defined variable:
