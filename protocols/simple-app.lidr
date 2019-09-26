# A simple app 

## Introduction {.allowframebreaks}

* In this section we build on top of the implementation of the
`Database` protocol we have just created.

* Before, we were interested, essentially, on specifying a datatype
  that captures the _behavior_ (or automaton) of the protocol,
  guaranteeing that a computation (or transition) takes place only
  when its contract (pre and postconditions) hold.  
  - In other words, we specify when _computations_ are _well-formed_.
  
* Now we wish to write a _running_ application on top of it. It has a
  command-line interface and uses a table or map (`SortedMap`, in
  Idris) to represent a database.

## Putting it all together {.allowframebreaks}

* Our app requires a few extensions with respect to what we have done
  so far:
  1. A way to transform string input into "commands" (a well-formed
    instance of a datatype.)
  1. A way to represent the database.
  1. A way to evaluate commands in the presence of a database.
  1. An updated protocol datatype that takes into account queries and
    reports.
  1. An interactive user-interface.
  
* You should note that we are essentially putting everything we
  studied together.
  
## A way to transform string input into "commands" {.allowframebreaks}

* Our app will simply open a database, close a database and query
  it. So let us first define a datatype that captures these three 
  commands, and call it `Input`.

  ```idris
  data Input = OPEN String
             | CLOSE 
             | QUERY QueryLang
  ```

* A query should not be defined as a string, as always, we should type
  it! Of course, we will not define SQL here but focus on three
  commands:  
	  - `INSERT` adds an entry to the database composed by an `Integer`
        and a `String`.  
	  - `SELECT` retrieves the String bound to the given integer.  
	  - `DELETE` removes from the database the entry whose key is the
	  given integer.  

*  The `QueryLang` datatype implements it.

  ```idris
  data QueryLang = INSERT Int String 
                 | SELECT Int
                 | DELETE Int
  ```

* We now define the transformation function from Strings to
the `Input` datatype.  

  ```idris
  strToInput : String -> Maybe Input
  ```
  An example application of this function is:  
`strInput "query INSERT 1 A"` $\leadsto$ `QUERY INSERT 1 "A"`.


* Essentially, it should handle three classes of
strings, one for each form of input. Note also that both `OPEN` and
`QUERY` have _parameters_. 

* Think about this function and try to figure it out by yourself!

* You may check my proposed solution later in the slides.

* I suggest two auxiliary functions: `mkQuery` and `parseQuery`.
	- Function `mkQuery : String -> Maybe (Input)` decomposes the
      input string and calls `parseQuery` to build the `Input` instance.
	- Function `parseQuery : List String -> Maybe Input` receives a list of
      strings, such as `["query", "INSERT 1 A"]`, and produces an
      instance of the `Input` datatype, such as `QUERY INSERT 1 "A"`.

## A way to represent the database {.allowframebreaks}

* We chose to represent the database as a map (`SortedMap`), available in
      the Idris distribution. 
  ```idris
  Database : Type
  Database =  SortedMap Int String
  ```

* The type `Database` is imply a synonym to a map from integers to
  strings.
  - Of course we could relate richer structures with the map and even
    create a more realistic representation of a database.
  - This simple map should suffice given our pedagogical needs at this time.
	  
* To use it we need to:
  - Import it in our program with:
	`import Data.SortedMap`
  - and invoke Idris using the command line:
    `idris -p contrib simple-app.lidr`

* This will inform the run-time that we are importing the `SortedMap` and
  where to find it (in package `contrib`).

## A way to evaluate commands in the presence of a database{.allowframebreaks}
  
* We define function by structural induction (the constructors
  `INSERT`, `SELECT` and `DELETE`) of the
  datatype `QueryLang` and relate each constructor with an operation
  of datatype `SortedMap`.
  - Of course, a more realistic implementation wouldn't define a
    simple bijection (one-to-one), but, again, enough for our
    pedagogical needs.

* This about it! You may _cheat_ and look the proposal solution if you
  will. But think hard first! 
  ```idris
  eval : QueryLang -> Database -> (Database, Report)
  eval (INSERT i s) db = ?i
  eval (SELECT i) db = ?s
  eval (DELETE i) db = ?d
  ```
  
* Use the command 
  `:browse Data.SortedMap` to learn about `SortedMap`'s interface.

* The notation `(Database, Report)` simply defines a _pair_ of
  `Database` and `Report` where the latter is simply a list of strings.

## An updated protocol datatype {.allowframebreaks}

* As before, we have transitions to open, close and query the
  database.
  
* However, we now have a more refined notion of _state_ of the
  database app (`DBState`) comprised by the name of open database, its
  connection status,
  the database itself and the report of the last query.
  
* We must update the type of the datatype and of its transitions. 

* As always, think about it and cheat if you feel like it...

* A sorted map may be initialized with the `fromList` command. (Search
for it in Idris' REPL.) 
  
```idris
     
     data DBCmd : Type -> DBState -> DBState -> Type 
     where
       OPENDB : (d : String) -> 
        DBCmd () (s, NotConn, db, []) 
                 (..., ..., ..., ...)
       CLOSEDB : 
        DBCmd () (s, Conn, db, r) 
                 (..., ..., ..., ...)     
       QUERYDB : (q : QueryLang) -> 
        DBCmd () (s, Conn, db, r) 
         (s, Conn, fst (...), snd (...))      
       Display : String -> DBCmd () st st
       GetInput : DBCmd (Maybe Input) st st
       Pure : ty -> DBCmd ty state state
       (>>=) : DBCmd a state1 state2 -> 
               (a -> DBCmd b state2 state3) ->
               DBCmd b state1 state3

```

## An interactive user-interface {.allowframebreaks}

* Streams are the way to go to write app with infinite data.

* This is exactly what happens when we write interactive applications.

* The datatype `DBIO` defines an stream of instances of
`DBState`. Note the use of the `Inf` constructor, while defining a
trace of `DBState` with the `Do` constructor...
```idris
    data DBIO : DBState -> Type where
         Do : DBCmd a state1 state2 ->
              (a -> Inf (DBIO state2)) -> DBIO state1
```

* ... which is precisely what we need to implement the lifting of
  `(>>=)` to sequences of `DBCmd`.
  
* Now we need to define a function that will interact with the user
  and enact the appropriate actions given a well-formed
	  input. Function `dbLoop` does precisely that. Again, it is defined by
  cases on the possible states.
  
* Understand the following implementation and think about the missing
  cases captured by the ellipsis. 
```idris
     dbLoop : DBIO st
     dbLoop {st = (n, NotConn, d, [])} =
      do Just x <- GetInput 
                | Nothing => 
                   do Display "Invalid input"
                      dbLoop
         case x of
          ...
          otherwise => 
           do Display 
               "You should open the database first."
              dbLoop
 
     dbLoop {st = (n, Conn, d, r)} =
      do Just x <- GetInput 
                | Nothing => 
                   do Display "Invalid input"
                      dbLoop
         case x of
          CLOSE => 
           do CLOSEDB {s = n} {db = d}
              dbLoop
          ...
		  otherwise => 
           do Display 
               "Either close or query the database."
              dbLoop
```
	  
* Function `dbLoop` executes sequences of commands. We need to be able
  to "connect" it with the IO system of Idris' run time. 
  
* From the user's perspective, `dbLoop` must be ran "forever". And that
  is precisely what `main` does.

```idris
main : IO ()
main = 
 run forever 
      (dbLoop 
	    {st = ("", NotConn, fromList [(0,"0")], [])})
 ```

* Function `run` makes the connection I mentioned above, relating
`DBIO` instances with `IO` instances. 
```idris
    run : Fuel -> DBIO state -> IO ()
    run (More fuel) (Do c f) 
      = do res <- runMachine c
           run fuel (f res)
    run Dry p = pure ()
```

* Datatype `DBIO` is a sequence of DB commands. Function `run` only
  "iterates" over the infinite sequence of commands, processing it
  step-by-step by means of function `runMachine`. 
  
* And it does it using the _lazy_ datatype `Fuel` (that we studied
  before), that allows `run` to execute DB commands one step at the
  time, with a `DBIO` (infinite) sequence.
  
* Let us take a look at the `runMachine` function. It is defined by
  cases on `DBCmd` datatype. We will only study one of its cases. The
  remaining ones are for you think about.
```idris
     runMachine : DBCmd ty inState outState -> IO ty
     runMachine 
      {inState = (s, NotConn, db, [])} 
      {outState = (s', Conn, (fromList [(0, "0")]), [])} 
      (OPENDB s') = 
      do 
       putStrLn ("DB " ++ s' ++ " open")
       showDB (fromList [(0, "0")])
```

* Function `runMachine` relates a DB command and IO actions. In the
  case of command `OPENDB s`, where `s` is a string, denoting the name
  of the database, `runMachine` prints that the database, whose name
  was given, is open and lists the contents of an initialized
  database.
  
# Simple app full listing 

## Datatypes {.allowframebreaks}

```idris

> import Data.SortedMap
> 
> namespace Database
> 
>     data ConnState = NotConn | Conn
> 
>     Report : Type
>     Report = List String
> 
>     Database : Type
>     Database =  SortedMap Int String
> 
>     DBState : Type 
>     DBState = (String, ConnState, Database, Report)
> 
>     data QueryLang = INSERT Int String 
>                    | SELECT Int
>                    | DELETE Int
>     
>     data Input = OPEN String
>                | CLOSE 
>                | QUERY QueryLang

```

## Function `mkInsert` {.allowframebreaks}

```idris
 
>     mkInsert : List String -> Maybe QueryLang
>     mkInsert xs = 
>      case tail' xs of
>       Just y => 
>        case y of
>          s1 :: [s2]  => Just (INSERT (cast s1) s2)
>          otherwise => Nothing
>       otherwise => Nothing

```

## Function `mkSelect` {.allowframebreaks}

```idris
                        
>     mkSelect : List String -> Maybe QueryLang
>     mkSelect xs = 
>      case tail' xs of
>       Just y => 
>        case y of
>         [s] => Just (SELECT (cast s))
>         otherwise => Nothing
>       otherwise => Nothing

```

## Function `mkDelete` {.allowframebreaks}

```idris
     
>     mkDelete : List String -> Maybe QueryLang
>     mkDelete xs = 
>      case tail' xs of
>       Just y => case y of
>          [s] => Just (DELETE (cast s))
>          otherwise => Nothing
>       otherwise => Nothing

```

## Function `parseQuery` {.allowframebreaks}

```idris
 
>     parseQuery : List String -> Maybe Input
>     parseQuery xs = 
>      case head' xs of
>       Just "INSERT" => 
>        case mkInsert(xs) of
>         Just q => Just (QUERY q)
>         Nothing => Nothing
>       Just "SELECT" => 
>        case mkSelect(xs) of
>         Just q => Just (QUERY q)
>         Nothing => Nothing
>       Just "DELETE" => 
>        case mkDelete(xs) of
>         Just q => Just (QUERY q)
>         Nothing => Nothing
>       otherwise => Nothing

```
       
## Function `mkQuery` {.allowframebreaks}

```idris

>     mkQuery : String -> Maybe (Input)
>     mkQuery "" = Nothing
>     mkQuery  s = 
>      let h = head' (words s) 
>      in
>       case h of
>        Just "query" => 
>         let xs = tail' (words s) 
>         in case xs of 
>             Just y => parseQuery(y)
>             otherwise => Nothing
>        otherwise => Nothing

```

## Function `strToInput` {.allowframebreaks}

```idris

>     strToInput : String -> Maybe Input
>     strToInput s = 
>                if ((head' (words s)) == (Just "open"))
>                then 
>                  let db = tail' (words s)
>                  in 
>                      case db of
>                        Just d => 
>                          case d of 
>                            [s'] => Just (OPEN s')
>                            otherwise => Nothing
>                        otherwise => Nothing
>                else 
>                     if s == "close"
>                     then Just CLOSE
>                     else mkQuery(s)

```
                     
## Function `eval` {.allowframebreaks}

```idris

>     eval : QueryLang -> Database -> (Database, Report)
>     eval (INSERT i s) db = ((insert i s db), [])
>     eval (SELECT i) db =
>          case lookup i db of
>               Just s => (db , [s])
>               otherwise => (db, [])
>     eval (DELETE i) db = ((delete i db), [])

```
     
## Datatype `DBCmd` {.allowframebreaks}

```idris
     
>     data DBCmd : Type -> DBState -> DBState -> Type 
>     where
>       OPENDB : (d : String) -> 
>        DBCmd () (s, NotConn, db, []) 
>                 (d, Conn, (fromList [(0,"0")]), [])
>       CLOSEDB : 
>        DBCmd () (s, Conn, db, r) 
>                 ("", NotConn, db, [])      
>       QUERYDB : (q : QueryLang) -> 
>        DBCmd () (s, Conn, db, r) 
>         (s, Conn, fst (eval q db), snd (eval q db))      
>       Display : String -> DBCmd () st st
>       GetInput : DBCmd (Maybe Input) st st
>       Pure : ty -> DBCmd ty state state
>       (>>=) : DBCmd a state1 state2 -> 
>               (a -> DBCmd b state2 state3) ->
>               DBCmd b state1 state3

```               
               
## Datatype `DBIO` {.allowframebreaks}

```idris
              
>     data DBIO : DBState -> Type where
>          Do : DBCmd a state1 state2 ->
>               (a -> Inf (DBIO state2)) -> DBIO state1

```

## Function `showDB` {.allowframebreaks}

```idris
               
>     showDB : Database -> IO ()
>     showDB db = 
>      if null db 
>      then putStrLn ""
>      else
>       putStrLn (show (zip (keys db) (values db)))              
                  
```                  

## Function `runMachine` {.allowframebreaks}

```idris

>     runMachine : DBCmd ty inState outState -> IO ty
>     runMachine 
>      {inState = (s, NotConn, db, [])} 
>      {outState = (s', Conn, (fromList [(0, "0")]), [])} 
>      (OPENDB s') = 
>      do 
>       putStrLn ("DB " ++ s' ++ " open")
>       showDB (fromList [(0, "0")])

```

\newpage

```idris 

>     runMachine 
>      {inState = (s, Conn, db, r)} 
>      {outState = ("", NotConn, db, [])} 
>      CLOSEDB = putStrLn ("DB " ++ s ++ " closed")

```

\newpage

```idris

>     runMachine 
>      {inState = (s, Conn, db, r)} 
>      {outState = (s, Conn, 
>        (fst (eval q db)), 
>        (snd (eval q db)))} 
>      (QUERYDB q) = 
>       do putStrLn("DB contents") 
>          showDB   (fst (eval q db))
>          putStrLn("Query result")
>          putStrLn (unwords (snd (eval q db)))               

```

\newpage

```idris
          
>     runMachine (Pure x) = pure x
>     runMachine (cmd >>= prog) = do x <- runMachine cmd
>                                    runMachine (prog x)
>     runMachine (Display str) = putStrLn str
>     runMachine {inState = (s, c, db, r)} GetInput
>       = do putStr ("DB: " ++ s ++ "> ")
>            x <- getLine
>            pure (strToInput x)
            
```

## `Fuel`, `forever` and `run` {.allowframebreaks}

```idris
              
>     data Fuel = Dry | More (Lazy Fuel)
> 
>     partial
>     forever : Fuel
>     forever = More forever
> 
>     run : Fuel -> DBIO state -> IO ()
>     run (More fuel) (Do c f) 
>       = do res <- runMachine c
>            run fuel (f res)
>     run Dry p = pure ()

```

## Function `>>=` lifted to streams of `DBCmd` {.allowframebreaks}

```idris

>     namespace DBDo
>       (>>=) : DBCmd a state1 state2 ->
>               (a -> Inf (DBIO state2)) -> DBIO state1
>       (>>=) = Do
       
```

## Function `dbLoop` {.allowframebreaks}

```idris       
 
>     dbLoop : DBIO st
>     dbLoop {st = (n, NotConn, d, [])} =
>      do Just x <- GetInput 
>                | Nothing => 
>                   do Display "Invalid input"
>                      dbLoop
>         case x of
>          OPEN x => 
>           do OPENDB x {db = d}
>              dbLoop
>          otherwise => 
>           do Display 
>               "You should open the database first."
>              dbLoop
> 
>     dbLoop {st = (n, Conn, d, r)} =
>      do Just x <- GetInput 
>                | Nothing => 
>                   do Display "Invalid input"
>                      dbLoop
>         case x of
>          CLOSE => 
>           do CLOSEDB {s = n} {db = d}
>              dbLoop
>          (QUERY q) => 
>           do QUERYDB q {s = n} {db = d}
>              dbLoop
>          otherwise => 
>           do Display 
>               "Either close or query the database."
>              dbLoop

```

## Function `main` {.allowframebreaks}
 
```idris

> main : IO ()
> main = 
>  run forever 
>       (dbLoop {st = ("", NotConn, 
>                      fromList [(0,"0")], [])})
 
 ```
