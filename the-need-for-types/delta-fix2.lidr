This is a fix for the `delta` function in the Bhaskara example.


> delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
> delta a b c =  (cast (b * b)) - (cast (4 * a * c))

