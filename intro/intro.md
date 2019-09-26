## 

![Type-driven Cybersecurity](./intro/logo.png "Type-driven
Cybersecurity"){.center}\

## Contact information

**Christiano Braga**  
_Associate Professor_

Instituto de Computação  
Universidade Federal Fluminense  
[cbraga@ic.uff.br](mailto:cbraga@ic.uff.br)  
[http://www.ic.uff.br/~cbraga](http://www.ic.uff.br/~cbraga)  
[Lattes Curriculum Vitae](http://lattes.cnpq.br/0535266455387139)  

## Objective

* The objective of this workshop is to brainstorm about R&D
  opportunities between TCS and the Theoretical Computer Science 
  Research Group at UFF, in particular exploring the type-driven
  development (TDD) approach.
  
* Our hypothesis is that the TDD approach can be **effectively**
  applied to either or both Cybersecurity and Business 4.0 enterprises
  at TCS with **clear ROI** as safety and security, for instance,
  would be increased in TCS solutions, based on public TCS documents.
   - [TCS research website](https://www.tcs.com/tcs-research)
   - [Winning in a Business 4.0 World](https://www.business4.tcs.com/content/dam/tcs_b4/pdf/winning-in-a-business-4-0-world.pdf)

## Type-driven development in a nutshell

* Domain-specific languages
  - Focus on what is relevant to the client.
* Program transformation
  - Relates client terminology to the available solutions.
* Structural and behavioral type-safety
  - Allows for both _data_ soundness and _process_ soundness.
* Transparent use of rigorous program verification techniques.
  - Seamless integration of _mathematically rigorous_ techniques into
  the development process. 

## Cybersecurity 

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

## Solutions 

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

![Database protocol](./protocols/db-protocol.png "Database protocol")

* A program that tries to make a query before opening a connection is
  **ill-typed**.
  - This is checked at compile time not run time!
  - Your client does not become aware of your errors!

<!-- ## An example DSL iii {.allowframbreaks} -->

<!-- * For example, the step `SQLiteConnected` step has type -->
<!-- ```haskell -->
<!-- data SQLiteConnected : Type where -->
<!--      SQLConnection : ConnectionPtr -> SQLiteConnected -->
<!-- ``` -->

<!-- * The DSL has constructions for defining typed form handlers such as  -->
<!-- ```haskell -->
<!-- handleRequest : CGIProg -->
<!--      [SESSION (SessionRes SessionUninitialised), -->
<!--       SQLITE ()] () -->
<!-- ``` -->
<!-- that will only handle a request on properly established sessions. -->

<!-- ## Programming languages support for DSL development -->

<!-- * Essentially, there are two approaches for DSL-based development:   -->
<!-- 	1. Transformational approach:   -->
<!-- 	  DSL program $\xrightarrow{\text{parsing}}$ Protocol -->
<!-- 	  data type instance   -->
<!-- 	  $\xrightarrow{\text{transformation}}$ Web (micro)service framework. -->

<!-- 	2. Embedded DSL approach:   -->
<!-- 	  The programming languages has support the definition of notation and -->
<!-- 	  typing.   -->
	  
<!-- * Programming languages that support approach #i are [Racket](http://racket-lang.org) and [Maude](http://maude.cs.uiuc.edu). -->
<!-- * Programming languages that support approach #ii are [Idris](http://www.idris-lang.org), [Lean](https://leanprover.github.io/) and [Haskell](http://haskell.org). -->

## Business 4.0

Critical business behaviors:

* Driving mass personalization  
  - Personalizing products and services to a market of one customer,
    often even of one transaction, and at scale. 
* Creating exponential value
  - Adopting business models that leverage value from transactions at
    multiple levels and address new markets. 
* Leveraging ecosystems  
  - Collaborating with partners inside and outside the supply chain to
    create new products and services.
* Embracing risk  
  – Moving beyond rigid planning and operational barriers with an
    agile strategic approach.
	
## Relating TDD and Buz4.0

* Mass personalization is domain-specific programming!

* Different business models may be captured as types and conformance
  to the business model becomes a programming practice!
  
* Type _composition_ is natural in type-driven development!

* Safety and risk walk hand-in-hand as program transformation allows us to
  cope with agile strategies in a type-safe setting!
  
## Our research approach

* To program with domain-specific languages, implemented on top of
  strongly typed functional languages.
  
* To develop and apply program analysis techniques to DSL-based
  approaches to software development. 
  
* More specifically, to develop and apply cybersecurity and business
  4.0 enabled-techniques in Idris.
	 
## This short-course

* In this short-course we will address some of the basic concepts of
  the type-driven approach that gives support to the development
  scenario outlined here.

## Suggested reading

<a name="Brady17"> Edwin Brady</a>. 2017. Type-driven development. Manning.

<a name="Fowler&Brady13"> Simon Fowler and Edwin Brady</a>. 2013. Dependent Types for Safe and
Secure Web Programming. In Proceedings of the 25th symposium on
Implementation and Application of Functional Languages (IFL '13). ACM,
New York, NY, USA, Pages 49, 12 pages. DOI:
[https://doi.org/10.1145/2620678.2620683](https://doi.org/10.1145/2620678.2620683)
