# Introduction

## Contact information

**Christiano Braga**  
_Associate Professor_

Instituto de Computação  
Universidade Federal Fluminense  
[cbraga@ic.uff.br](mailto:cbraga@ic.uff.br)  
[http://www.ic.uff.br/~cbraga](http://www.ic.uff.br/~cbraga)  
[Lattes Curriculum Vitae](http://lattes.cnpq.br/0535266455387139)  

## Context {.allowframebreaks}

* Current distributed applications ecosystem: IOT, Cloud, Web...  

* A common problem in distributed information systems: _SQL code injection_.  
	* Examples: Sony in 2011 and Yahoo! in 2012.  
	* Losses of millions of dollars  

## The problem, by example
```php
txtUserId = getRequestString("UserId");
txtSQL = "SELECT * FROM Users WHERE UserId = " 
		+ txtUserId;
```  
  If `txtUserId` is equal to `105 OR 1=1`, which is always true, a
  malicious user may access _all_ user information from a database.  

## Solutions {.allowframebreaks}

* SQL parameters: additional values are passed to the query.  
* Escaping functions: they transform the input string into a "safe"
    one before sending it to the DBMS.  
  
* The problem with the solutions is that communication relies on
  _strings_. 
  
* What if we could **type** this information?

## Protocols {.allowframebreaks}

* Web programming invariably requires following certain **protocols**.
  * For example, to connect to make a query:
	  1. Create a connection.
	  1. Make sure the connection was established.
	  1. Prepare an SQL statement.
	  1. Make sure that variables are bound.
	  1. Execute the query.
	  1. Process the result of the query.
	  1. Close connection.

* Of course, a function could implement such a
  sequence, but how could one make sure that such a sequence is
  _always_ followed?
  
* In other words, what if we could _type_ protocol behavior and make
  sure our Web programs _cope_ with such types? 
  
* Moreover, what if we could define special _notation_ to create
  instances of such types? 

* Protocols are one example but note that _business processes_ may be treated the same way.

## Service-oriented web development model {.allowframebreaks}

> Services are _blackboxes_, are _stateless_, are _composable_, among other nice characteristics.

* Services are first-class citizens in Cloud PaaS, and other platforms. 

* These characteristics allow for a _clean_ and _simple_
  interpretation of services as _functions_.
  
* _**What about capturing a company's way of developing PaaS as DSL?**_

* _**What about capturing a company's clients processes as DSL?**_

## An example DSL {.allowframbreaks}

(From [Fowler&Brady13](#Fowler&Brady13).)

* Think of each step of a Web application as a business process.

* The notion of a Web application is typed, and so are its steps.

* For example, a Web application has forms and its forms have handlers. 

* A particular Web application is _safe_ (or well-typed) if its forms are 
  well-typed. A form is well-typed if its handlers are also well-typed.

## An example DSL ii {.allowframbreaks .shrink}

* The database protocol can be captured as a type.  
![Database protocol](./intro/db-protocol.png "Database protocol")

## An example DSL iii {.allowframbreaks}

* For example, the step `SQLiteConnected` step has type
```haskell
data SQLiteConnected : Type where
     SQLConnection : ConnectionPtr -> SQLiteConnected
```

* The DSL has constructions for defining typed form handlers such as 
```haskell
handleRequest : CGIProg
     [SESSION (SessionRes SessionUninitialised),
      SQLITE ()] ()
```
that will only handle a request on properly established sessions.

## Programming languages support for DSL development

* Essentially, there are two approaches for DSL-based development:  
	1. Transformational approach:  
	  DSL program $\xrightarrow{\text{parsing}}$ Protocol
	  data type instance  
	  $\xrightarrow{\text{transformation}}$ Web (micro)service framework.

	2. Embedded DSL approach:  
	  The programming languages has support the definition of notation and
	  typing.  
	  
* Programming languages that support approach #i are [Racket](http://racket-lang.org) and [Maude](http://maude.cs.uiuc.edu).
* Programming languages that support approach #ii are [Idris](http://www.idris-lang.org), [Lean](https://leanprover.github.io/) and [Haskell](http://haskell.org).

## Our research approach

* To program services with domain-specific languages, implemented on top of
  strongly typed functional languages.  
  
* To develop and apply program analysis techniques to DSL-based
  approaches to Web development. 
  
* More specifically, to develop Web programming support in Idris.
	 
## Summing up

* We have chosen an important technical problem in web development
  (SQL injection), that may cause loss of millions of dollars, to
  illustrate DSL with functional programming usefulness.
  
* The issues raised here may be moved to a higher level of abstraction
  to represent buiness processes and their refinement into code.
  
* There is off the shelf technology to support this approach.

## This short-course

* In this short-course we will address some of the basic concepts of
  the type-driven approach that gives support to the development
  scenario outlined in this section.

## Suggested reading

<a name="Brady17"> Edwin Brady</a>. 2017. Type-driven development. Manning.

<a name="Fowler&Brady13"> Simon Fowler and Edwin Brady</a>. 2013. Dependent Types for Safe and
Secure Web Programming. In Proceedings of the 25th symposium on
Implementation and Application of Functional Languages (IFL '13). ACM,
New York, NY, USA, Pages 49, 12 pages. DOI:
[https://doi.org/10.1145/2620678.2620683](https://doi.org/10.1145/2620678.2620683)
