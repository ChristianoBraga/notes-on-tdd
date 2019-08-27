# Protocols

## A trivial database protocol

- The automaton below illustrates the communication between an
application and a database system. The intention is to express that in
order to query a database it is necessary first to stablish a
connection with it and then after all queries were done, the
connection is closed.

![Trivial database protocol](./protocols/db-protocol.png "Trivial database protocol")

## First attempt: a monoid of actions {.allowframebreaks}

- The code below is a naïve implementation of it. 

```idris

> module DBProtocol
>
> import Data.Vect
> 
> 
> data DBConnState = Conn | NotConn
> 
> namespace DBCmd1
> 
>     data DBCmd : Type -> Type where
>          Open : DBCmd ()
>          Close : DBCmd ()
>          Query : DBCmd () 

>          Pure : ty -> DBCmd ty
>          (>>=) : DBCmd a -> (a -> DBCmd b) -> DBCmd b

```

- Program `dbProg1` does exactly that.

```idris

>     dbProg1 : DBCmd ()
>     dbProg1 = do Open              
>                  Query
>                  Close

```

- But `dbProg2` also type checks just fine. Think about it for a
moment. _Why is this the case?_

```idris

>     dbProg2 : DBCmd ()
>     dbProg2 = do Close            
>                  Open              
>                  Query

```            

- Transitions are not _typed_! We can combine them in any way we want,
in the code. But this is not the "spirit" of the
specification. (Mathematically speaking, we do _not_ want a _free_
monoid of actions but rather an _ordered_ one!)

## Second attempt: a partial order {.allowframebreaks}

- We can do better and we will. We can type transitions by annotating, each operation in `DBCmd` type, with the _source_ and _target_ types. 

- This is captured in the type with signature 
```idris
data DBCmd : Type -> DBConnState -> DBConnState -> Type.
```

- On each transition, for instance in `Open`, with the following signature:
```idris
Open : DBCmd () NotConn Conn
```
where `DBCmd ()` is its (returning) type. 

- Types `NotConn` and `Conn` are the types of the source and target
  states that specify, respectively, the pre and postconditions of the
  `Open` action.

```idris

> namespace DBCmd2
>
>     data DBCmd : Type -> DBConnState -> 
>                          DBConnState -> Type where
>          Open : DBCmd () NotConn Conn
>          Close : DBCmd () Conn NotConn 
>          Query : DBCmd () Conn Conn
>
>          Pure : ty -> DBCmd ty state state
>          (>>=) : DBCmd a state1 state2 ->
>                  (a -> DBCmd b state2 state3) ->
>                  DBCmd b state1 state3
>
>     dbProg1 : DBCmd () NotConn NotConn
>     dbProg1 = do Open
>                  Query
>                  Close

```

- The sequence of actions `Open`, `Query` and `Close` types correctly,
as expected. 

```idris
                  
              
     dbProg2 : DBCmd () NotConn NotConn
     dbProg2 = do Query
                  Close
                  Open

```

- However, if a program tries to query a database to which
there is no open connection, the program simply does not type-check!

- We can check it simply using command
```shell
idris --check protocol.lidr 
```
as, in this example, there are not implementations for `Query`,
`Close` and `Open`.

```idris
Tue Aug 13@16:06:57:protocols$ 
idris --check protocol.lidr
protocol.lidr:89:20-24:
   |
89 | >     dbProg2 = do Query
   |                    ~~~~~
When checking right hand side of 
DBProtocol.DBCmd2.dbProg2 
  with expected type
        DBCmd () NotConn NotConn

When checking an application of constructor 
DBProtocol.DBCmd2.>>=:
        Type mismatch between
                DBCmd () Conn Conn (Type of Query)
        and
                DBCmd a NotConn state2 (Expected type)

        Specifically:
                Type mismatch between
                        Conn
                and
                        NotConn
```

## A simple app

```idris

> namespace DBApp
> 
>    data Database : (n : Nat) -> Type where
>         DB : Vect n (Nat, String) -> Database n
> 
>    insert : Ord elem => (x : elem) -> (xsSorted : Vect k elem) -> Vect (S k) elem
>    insert x [] = [x]
>    insert x (y :: xs) = case x < y of
>                              False => y :: insert x xs
>                              True => x :: y :: xs
>                              
>    update : {n : Nat} -> Nat -> String -> Vect n (Nat, String) -> Vect n (Nat, String)
>    update k s [] = []
>    update k s (x :: xs) = 
>         if fst x == k then (k, s) :: xs else x :: (update k s xs)
>                              
>    Report : Type
>    Report = List String
>
>    find : {n : Nat} -> Nat -> Vect n (Nat, String) -> Report
>    find k [] = [] 
>    find k (x :: xs) = 
>         if fst x == k then (snd x) :: (find k xs) else (find k xs)
>
>    data DBState : {n : Nat} -> Type where
>         DBSt : (DBConnState, Database n, Report) -> DBState 
>         
>    data QueryLang : Type where
>         Select : Nat -> QueryLang
>         Insert : Nat -> String -> QueryLang 
>         Update : Nat -> String -> QueryLang 
>         Delete : Nat -> QueryLang 
>
>    selectDB : {n : Nat} -> Nat -> Database n -> Report
>    selectDB k (DB d) = find k d
>
>    insertDB : {n : Nat} -> Nat -> String -> Database n -> Database (S n)
>    insertDB k s (DB d) = DB (insert (k, s) d)
>    
>    updateDB : {n : Nat} -> Nat -> String -> Database n -> Database n
>    updateDB k s (DB d) = DB (update k s d)
>
>    deleteDB : {n : Nat} -> Nat -> Database (S n) -> Maybe (Database n)
>    deleteDB k (DB d) = let i = (findIndex (((==) k) . fst)) d
>                        in 
>                           case i of
>                                Just l => Just (DB (deleteAt l d))
>                                otherwise => Nothing
>                                
>    -- data DBCmd : Type -> DBState -> DBState -> Type where
>    --     Open : DBCmd  () (NotConn, db, []) (Conn, db, [])
>    --     Close : DBCmd () (Conn, db, r) (NotConn, db, [])
>         --  QueryI : (q : (Insert k s)) -> 
>         --        DBCmd () (Conn, db, r) 
>         --                 (Conn, (insertDB k s db), 
>         --                        [])
>         -- Pure : ty -> DBCmd ty (c, d, r) (c', d', r')
>         -- (>>=) : DBCmd a (c, d, r) (c', d', r') ->
>         --        (a -> DBCmd b (c', d', r') (c'', d'', r'')) ->
>         --        DBCmd b (c, d, r) (c'', d'', r'')
>                                
>    parseInt : String -> Maybe Int
>    parseInt s with (strM s)
>             parseInt ""  | StrNil                    = Nothing
>             parseInt (strCons x xs) | (StrCons x xs) = parseIntAux (unpack xs) (ord x - 48) 
>             where
>                      parseIntAux : (List Char) -> Int -> Maybe Int
>                      parseIntAux [] acc        = Just acc
>                      parseIntAux (c :: cs) acc = 
>                         if (c >= '0' && c <= '9') 
>                         then parseIntAux cs ((acc * 10) + (ord c) - 48)
>                         else Nothing
>
>
>    eval : {n : Nat} -> List String -> Database n -> Maybe (Database (S n), Report)
>    eval xs db = case xs of
>                      ["Insert", k, s] => 
>                                 (case (parseInt k) of 
>                                       Just i => ((insertDB (cast i) s db), [])
>                                       Nothing => Nothing)
>                      otherwise => Nothing
    
    
   -- ((insertDB k s db), [])
                                
    -- queryS : {n : Nat} -> QueryLang -> Database n -> (Database n, Report)
    --  queryS (Select k) db = (db, (selectDB k db))

```

```idris
*protocols> deleteDB 1 (DB [(1,"A"),(2,"B")])
Just (DB [(2, "B")]) : Maybe (Database 1)
*protocols> deleteDB 2 (DB [(1,"A"),(2,"B")])
Just (DB [(1, "A")]) : Maybe (Database 1)
*protocols> deleteDB 0 (DB [(1,"A"),(2,"B")])
Nothing : Maybe (Database 1)
```
