# Protocols

## A trivial database protocol

The automaton below illustrates the communication between an
application and a database system. The intention is to express that in
order to query a database it is necessary first to stablish a
connection with it and then after all queries were done, the
connection is closed.

![Trivial database protocol](./db-protocol.png "Database protocol")

## First attempt: a monoid of actions

The code below is a naïve implementation of it. 

```idris

> module DBProtocol
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

Program `dbProg1` does exactly that.

```idris

>     dbProg1 : DBCmd ()
>     dbProg1 = do Open              
>                  Query
>                  Close

```

But `dbProg2` also type checks just fine. Think about it for a
moment. _Why is this the case?_

```idris

>     dbProg2 : DBCmd ()
>     dbProg2 = do Close            
>                  Open              
>                  Query

```            

Transitions are not _typed_! We can combine them in any way we want,
in the code. But this is not the "spirit" of the
specification. (Mathematically speaking, we do _not_ want a _free_
monoid of actions but rather an _ordered_ one!)

## Second attempt: a partial order

We can do better and we will. We can type transitions by annotating, each operation in `DBCmd` type, with the _source_ and _target_ types. This is captured in the type with signature 
```idris
data DBCmd : Type -> DBConnState -> DBConnState -> Type
```
and on each transition, for instance in `Open`, with the following signature:
```idris
Open : DBCmd () NotConn Conn
```
where `DBCmd ()` is its (returning) type. Types `NotConn` and `Conn` are the types of the source and target states that specify, respectively, the pre and postconditions of the `Open` action.

```idris

> namespace DBCmd2

>     data DBCmd : Type -> DBConnState -> DBConnState -> Type where
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

The sequence of actions `Open`, `Query` and `Close` types correctly,
as expected. 

```idris
                  
>              
>     dbProg2 : DBCmd () NotConn NotConn
>     dbProg2 = do Query
>                  Close
>                  Open

```

However, if a program tries to query a database to which
there is no open connection, the program simply does not type-check!
We can check it simply using command
```shell
idris --check protocol.lidr 
```
as, in this example, there are not implementations for `Query`,
`Close` and `Open`.

```idris
Tue Aug 13@16:06:57:protocols$ idris --check protocol.lidr
protocol.lidr:89:20-24:
   |
89 | >     dbProg2 = do Query
   |                    ~~~~~
When checking right hand side of DBProtocol.DBCmd2.dbProg2 with expected type
        DBCmd () NotConn NotConn

When checking an application of constructor DBProtocol.DBCmd2.>>=:
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


