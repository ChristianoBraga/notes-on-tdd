# Domain-specific commands lab.

In this lab we will restrict interactive program's to perform only
specific actions as opposed to the stream example.

## `Command` type {.allowframebreaks}

- Type `Command` defines an interactive interface that `ConsoleIO`, a
type that describes interactive programs that support only reading
from and writing to the console, programs can use.

- You can think of it as defining the capabilities or permissions of
interactive programs, eliminating any unnecessary actions.

```idris

> data Command : Type -> Type where
>     PutStr : String -> Command ()
>     GetLine : Command String

> data ConsoleIO : Type -> Type where
>     Quit : a -> ConsoleIO a
>     Do : Command a -> (a -> Inf (ConsoleIO b)) ->
>      	   ConsoleIO b
> (>>=) : Command a -> (a -> Inf (ConsoleIO b)) ->
> 	  ConsoleIO b
> (>>=) = Do

```

## DSL {.allowframebreaks}

- A domain-specific language (DSL) is a language that’s specialized
for a particular class of problems. DSLs typically aim to provide
only the operations that are needed when working in a specific problem
domain in a notation that’s accessible to experts in that domain,
while eliminating any redundant operations.

- In a sense, ConsoleIO defines a DSL for writing interactive console
pro- grams, in that it restricts the programmer to only the
interactive actions that are needed and eliminates unnecessary actions
such as file processing or net- work communication.

## The lab activities

- Your mission, should you choose to accept it, is to understand and execute program `ArithCmd.idr` from Chapter 11 of the TDD book, also available at this short-course repo.
