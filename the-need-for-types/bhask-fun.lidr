> delta : (a :  Nat) -> (b : Nat) -> (c : Nat) -> Int
> delta a b c =  (cast (b * b)) - (cast (4 * a * c))
> bhask : (a :  Nat) -> (b : Nat) -> (c : Nat) -> (Double, Double)
> bhask a b c = ((-b + (sqrt (delta a b c))) / (2 * a) , (-b - (sqrt (delta a b c))) / (2 * a))
