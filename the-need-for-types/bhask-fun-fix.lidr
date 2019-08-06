> delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
> delta a b c =  (cast (b * b)) - (cast (4 * a * c))
> bhask : (a :  Nat) -> (b : Nat) -> (c : Nat) -> (Double, Double)
> bhask a b c = (negate (cast b) + (sqrt (cast (delta a b c))) / cast (2 * a), negate (cast b) - (sqrt (cast (delta a b c))) / cast (2 * a))
