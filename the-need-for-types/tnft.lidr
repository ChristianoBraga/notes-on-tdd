# The need for types {.allowframebreaks}

This section motivates the use of strong typing with a very very
simple example: Bhaskara's theorem. In a tutorial way, we
illustrate how types are necessary and, more specifically, how Idris'
strong-typing presents itslef as a powerful development tool.

## Bhaskara's theorem 

From school: Bhaskara's theorem\footnote{For solving $2^{nd}$ degree
polynomials. But this could might as well be an Excel formula, for
instance! I mention Excel because that Microsoft is devoting serious
efforts to develop a type system for Excel.}

\begin{eqnarray*}
ax^2 + bx + c  = 0 & \Rightarrow & x = \frac{-b \stackrel{+}{-} \sqrt{\delta}}{2a} \\
&& \text{where } \delta = b^2 - 4acb
\end{eqnarray*}

### As functions

\begin{multline*}
\mathtt{bhask}(a,b,c) = \\
\left( -b + \sqrt{\mathtt{delta}(a,b,c)} / 2a \mathbf{,}
-b - \sqrt{\mathtt{delta}(a,b,c)} / 2a\right) 
\end{multline*}

\begin{eqnarray*}
\mathtt{delta}(a,b,c) = & b^2 - 4acb
\end{eqnarray*}

## First attempt: no types. {.allowframebreaks}

- In Python:
```python
from math import sqrt

def delta(a,b,c):
    return  (b * b) - (4 * a * c)

def bhask(a,b,c):
    d = delta(a,b,c)
    sr = sqrt(d)
    r1 = (-b + sr) / 2 * a
    r2 = (-b - sr) / 2 * a
    return (r1, r2)
```
- When we run `bhask(1,2,3)` the following is spit out:
```python
Traceback (most recent call last):
  File "bhask.py", line 16, in <module>
    bhask(1,2,3)
  File "bhask.py", line 9, in bhask
    sr = sqrt(d)
ValueError: math domain error
```
- This cryptic answer is only because we rushed into a direct
implementation and forgot that `delta(a,b,c)` may return a _negative_ value!

## Second attempt: still no types. {.allowframebreaks}

- Now, assuming we are instered only on Real results, how should
  `bhask` deal with the possilibity of a negative `delta`?
- One possibilty is to raise an _exception_:
```python
from math import sqrt

def delta(a,b,c):
    return  (b * b) - (4 * a * c)

def bhask(a,b,c):
    d = delta(a,b,c)
    if d >= 0:
        sr = sqrt(d)
        r1 = (-b + sr) / 2 * a
        r2 = (-b - sr) / 2 * a
        return (r1, r2)
    else:
        raise Exception("No Real results.")
``` 
- This implementation gives us a more _precise_ answer:
```python
Tue Jul 30@17:18:02:sc$ python3 -i bhask.py
Traceback (most recent call last):
  File "bhask.py", line 16, in <module>
    bhask(1,2,3)
  File "bhask.py", line 14, in bhask
    raise Exception("No Real results.")
Exception: No Real results.
```
- A very **important** point here is that we only find all this out
  while actually _running_ our implementation. Can't we do better?
  That is, let the **compiler** find out that `delta` may become a
  negative number and complain if this is not properly handled?

## Third attempt: Idris. {.allowframebreaks}

- Let us play with `delta` first.

- Strongly-typed languages, such as Idris, force us to think about types
  right away as we need to define `delta`'s signature. If we make the
  same mistake we did in the first attempt and forget that `delta` may
  become negative, we may write,
```idris 

> delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Nat 
> delta a b c = (b * b) - (4 * a * c) 

```
the compiler would tell us:
```idris
Type checking ./intro.lidr
intro.lidr:100:26:
    |
100 | > delta a b c =  (b * b) - (4 * a * c)
    |                          ^
When checking right hand side of delta with expected type
        Nat

When checking argument smaller to function Prelude.Nat.-:
     Can't find a value of type
     LTE (mult (plus a (plus a (plus a (plus a 0)))) c)
     (mult b b)
```
- This is cryptic, in a first-glance, but tells us precisely **what** is
  wrong **and** at **compile** time.  The problem is **with
  subtraction**: the type checker was not able to solve the
  inequality, defined in Idris' libraries, $$ 4ac \le b^2 $$ in order
  to produce a **natural** number while computing `delta`, as natural
  numbers can not be negative!

## First fix. {.allowframebreaks}

- And we have not even started thinking about `bhask` yet! But let us
first make `delta` type right by changing its signature:
```idris
delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
delta a b c =  (b * b) - (4 * a * c)
```
- To see the effect of this change, load `delta-fix.lidr` with the command:
```idris
:l delta-fix.lidr
```
- Don't be so happy though! This is not what we want yet. 
```idris
Type checking ./delta-fix.lidr
delta-fix.lidr:5:18-38:
  |
5 | > delta a b c =  (b * b) - (4 * a * c)
  |                  ~~~~~~~~~~~~~~~~~~~~~
When checking right hand side of delta with expected type
        Int

Can't disambiguate since no name has a suitable type:
        Prelude.Interfaces.-, Prelude.Nat.-

Holes: Main.delta 
``` 
- Idris does not know which subtraction operation to use because we are
operating operating with natural numbers but we should return an
integer! A casting is in order!


## Second fix. {.allowframebreaks}

- Think about why we should cast the right-hand side expression in the following way:
```idris
delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
delta a b c =  (cast (b * b)) - (cast (4 * a * c))
```
and not the whole right-hand side of `delta` at once.
- To see the effect of this change, load `delta-fix2.lidr` with the command:
```idris
:l delta-fix2.lidr
```
- You should finally be able to see
```idris
Type checking ./delta-fix2.lidr
*delta-fix2>
```
and run `delta 1 2 3`, for instance, to see the following result.
```idris
*delta-fix2> delta 1 2 3
-8 : Int
```
- Your session should look like this at this point:
```idris
Mon Aug 05@14:24:16:the-need-for-types$ idris --nobanner tnft.lidr
Type checking ./tnft.lidr
tnft.lidr:107:25:
    |
107 | > delta a b c = (b * b) - (4 * a * c)
    |                         ^
When checking right hand side of delta with expected type
        Nat

When checking argument smaller to function Prelude.Nat.-:
     Can't find a value of type
           LTE (mult (plus a (plus a (plus a (plus a 0)))) c)
              (mult b b)

Holes: Main.delta
*tnft> :l delta-fix.lidr
Type checking ./delta-fix.lidr
delta-fix.lidr:5:18-38:
  |
5 | > delta a b c =  (b * b) - (4 * a * c)
  |                  ~~~~~~~~~~~~~~~~~~~~~
When checking right hand side of delta with expected type
        Int

Can't disambiguate since no name has a suitable type:
        Prelude.Interfaces.-, Prelude.Nat.-

Holes: Main.delta
*delta-fix> :l delta-fix2.lidr
*delta-fix2> delta 1 2 3
-8 : Int
```

## Bhaskara at last! {.allowframebreaks}

- Painful, no?   
**No!** 

- The compiler is our _friend_ and true friends do not
always bring us good news! 

- Think about it using this metaphor: do you
prefer a shallow friend, such as Python, that says yes to (almost)
everything we say (at compile time), but is not there for us when we
really need it (at run time), or a _true_ friend, such as Idris, that
tells us that things are not all right all the time, but is there for
us when we need it?
- Another way to put it is that "With great power comes great
responsibility!", as the philosopher Ben Parker used to say... Strong
typing, and in particular this form of strong typing, that relies on
_automated theorem proving_ requires some effort from our part in
order to precisely tell the compiler how things should be.

- Having said that, let us finish this example by writing `bhask` function.

## Bhaskara: first attempt {.allowframebreaks}

- Bhaskara's solution for second-degree polynomials gives no Real
solution (when $\delta < 0$), one (when $\delta = 0$), or two (when
$\delta > 0$). Since "The Winter is Coming" we should be prepared for two roots:
```idris
bhask : (a :  Nat) -> (b : Nat) -> (c : Nat) -> (Double, Double)
bhask a b c = ((-b + (sqrt (delta a b c))) / (2 * a), 
               (-b - (sqrt (delta a b c))) / (2 * a))
```
- Moreover, we should now work with the Idris `Double` type, because of the `sqrt` function. Run
```idris
*bhask-fun> :t sqrt
sqrt : Double -> Double
```
- Again, our naivete plays a trick on us:
```idris
Type checking ./bhask-fun.lidr
bhask-fun.lidr:2:19:
  |
2 | > bhask a b c = ((-b + (sqrt (delta a b c))) / (2 * a), 
                     (-b - (sqrt (delta a b c))) / (2 * a))
  |                   ^
When checking right hand side of bhask with expected type
        (Double, Double)

When checking an application of function Prelude.Interfaces.negate:
        Type mismatch between
                Nat (Type of b)
        and
                Double (Expected type)
``` 
Load file `bhask-fun.lidr` to see this effect.

- We should write `negate b` instead of `- b`, as `-` is a _binary_
operation only in Idris. Moreover, we should _not_ be able to negate a
natural number! Again, casting is necessary.

## Bhaskara: final attempt {.allowframebreaks}

- Let us fix all casting problem at once, the final definitions should be as follows:
```idris
delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
delta a b c =  (cast (b * b)) - (cast (4 * a * c))
bhask : (a :  Nat) -> (b : Nat) -> (c : Nat) -> (Double, Double)
bhask a b c = 
  (negate (cast b) + (sqrt (cast (delta a b c))) / cast (2 * a), 
   negate (cast b) - (sqrt (cast (delta a b c))) / cast (2 * a))
```
- We can now play with `bhask`, after executing `:l bhask-fun-fix.lidr` 
```idris
Type checking ./bhask-fun-fix.lidr
*bhask-fun-fix> bhask 1 10 4
(-5.41742430504416, -14.582575694955839) : (Double, Double)
*bhask-fun-fix> bhask 1 2 3
(NaN, NaN) : (Double, Double)
```
- Note that when $\delta < 0$ Idris gives a `NaN` value, which stands
for _Not a number_. In other words, `bhask` is **total** as opposed to
the **partial** approach in Python where we needed to raise an
exception to capture the situation where the roots are not Real numbers.
- Idris can help us identify when a function is total. We simply need to run:
```idris
*bhask-fun-fix> :total bhask
Main.bhask is Total
```

## Wrapping-up {.allowframebreaks}

- First and foremost motivate strong-typing in Idris.

- Introduce notation for functions in Idris. The signature of a function, such as `delta` includes a name, formal parameters and a return type, such as:  
`delta : (a : Nat) -> (b : Nat) -> (c : Nat) -> Int`.

- The formal parameters of a function are declared using
the so-called Currying form (after Haskell Curry): currying is the
technique of translating the evaluation of a function that takes
multiple arguments into evaluating a sequence of functions, each
with a single argument.  

- This allows to _partially apply_ a
function! For instance, we can call `delta 1 2`. This will produce
a function that expects a number and then behaves as `delta`.

- Take a look at the following session:  
  ```idris
  *bhask-fun-fix> delta  
  delta : Nat -> Nat -> Nat -> Int  
  *bhask-fun-fix> delta 1
  delta 1 : Nat -> Nat -> Int
  *bhask-fun-fix> delta 1 2
  delta 1 2 : Nat -> Int
  *bhask-fun-fix> delta 1 2 3
  -8 : Int
  *bhask-fun-fix> (delta 1) 2
  delta 1 2 : Nat -> Int
  *bhask-fun-fix> ((delta 1) 2) 3
  -8 : Int
  ```
- At the end of the day, `delta 1 2 3` is just _syntax sugar_ for
  `((delta 1) 2) 3`.  

- Total functions. From Idris' FAQ:
Idris can’t decide in general whether a program is terminating due to
the undecidability of the Halting Problem. It is possible, however, to
identify some programs which are definitely terminating. Idris does
this using “size change termination” which looks for recursive paths
from a function back to itself. On such a path, there must be at least
one argument which converges to a base case.
- Mutually recursive functions are supported. 
However, all functions on the path must be fully applied. In
particular, higher order applications are not supported
- Idris identifies arguments which converge to a base case by
looking for recursive calls to syntactically smaller arguments
of inputs. e.g. $k$ is syntactically smaller than $S (S k)$ because
$k$ is a subterm of $S (S k)$, but $(k, k)$ is not syntactically
smaller than $(S k, S k)$.

- Type casting. We have used `cast` many times in order to _inject_
  our values from one type into another.

- Some Read-Eval-Print-Loop (REPL) commands. We have seen how to load
     a file with `:l`, check its type with `:t`, and check weather a
     function is total or not with `:total`.
  
