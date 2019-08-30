import Data.SortedMap

namespace Database

    data ConnState = NotConn | Conn

    Report : Type
    Report = List String

    Database : Type
    Database =  SortedMap Int String

    DBState : Type 
    DBState = (String, ConnState, Database, Report)

    data QueryLang = INSERT Int String 
                   | SELECT Int
                   | DELETE Int
    
    data Input = OPEN String
               | CLOSE 
               | QUERY QueryLang

    mkInsert : List String -> Maybe QueryLang
    mkInsert xs = case tail' xs of
                       Just y => case y of
                                      s1 :: [s2]  => Just (INSERT (cast s1) s2)
                                      otherwise => Nothing
                       otherwise => Nothing
                       
    mkSelect : List String -> Maybe QueryLang
    mkSelect xs = case tail' xs of
                       Just y => case y of
                                      [s] => Just (SELECT (cast s))
                                      otherwise => Nothing
                       otherwise => Nothing

    mkDelete : List String -> Maybe QueryLang
    mkDelete xs = case tail' xs of
                       Just y => case y of
                                      [s] => Just (DELETE (cast s))
                                      otherwise => Nothing
                       otherwise => Nothing

    parseQuery : List String -> Maybe Input
    parseQuery xs = case head' xs of
                       Just "INSERT" => case mkInsert(xs) of
                                             Just q => Just (QUERY q)
                                             Nothing => Nothing
                       Just "SELECT" => case mkSelect(xs) of
                                             Just q => Just (QUERY q)
                                             Nothing => Nothing
                       Just "DELETE" => case mkDelete(xs) of
                                             Just q => Just (QUERY q)
                                             Nothing => Nothing
                       otherwise => Nothing

    mkQuery : String -> Maybe (Input)
    mkQuery "" = Nothing
    mkQuery  s = 
               let h = head' (words s) in
               case h of
                     Just "query" => 
                           let xs = tail' (words s) 
                           in case xs of 
                                   Just y => parseQuery(y)
                                   otherwise => Nothing
                     otherwise => Nothing

    strToInput : String -> Maybe Input
    strToInput s = 
               if ((head' (words s)) == (Just "open"))
               then 
                 let db = tail' (words s)
                 in 
                     case db of
                       Just d => 
                         case d of 
                           [s'] => Just (OPEN s')
                           otherwise => Nothing
                       otherwise => Nothing
               else 
                    if s == "close"
                    then Just CLOSE
                    else mkQuery(s)

    eval : QueryLang -> Database -> (Database, Report)
    eval (INSERT i s) db = ((insert i s db), [])
    eval (SELECT i) db = 
         case lookup i db of
           Just s => (db , [s])
           otherwise => (db, [])
    eval (DELETE i) db = ((delete i db), [])
        
    data DBCmd : Type -> DBState -> DBState -> Type where
      OPENDB : (d : String) -> DBCmd () (s, NotConn, db, []) (d, Conn, (fromList [(0,"0")]), [])
      CLOSEDB : DBCmd () (s, Conn, db, r) (s, NotConn, db, [])      
      QUERYDB : (q : QueryLang) -> 
                DBCmd () (s, Conn, db, r) 
                         (s, Conn, fst (eval q db), snd (eval q db))      
      Display : String -> DBCmd () st st
      GetInput : DBCmd (Maybe Input) st st
      Pure : ty -> DBCmd ty state state
      (>>=) : DBCmd a state1 state2 -> (a -> DBCmd b state2 state3) ->
              DBCmd b state1 state3

    data DBIO : DBState -> Type where
         Do : DBCmd a state1 state2 ->
              (a -> Inf (DBIO state2)) -> DBIO state1
              
    showDB : Database -> IO ()
    showDB db = if null db 
                then 
                  putStrLn ""
                else
                  putStrLn (show (zip (keys db) (values db)))              

    runMachine : DBCmd ty inState outState -> IO ty
    runMachine {inState = (s, NotConn, db, [])} 
               {outState = (s', Conn, (fromList [(0, "0")]), [])} (OPENDB s') = 
      do 
        putStrLn ("DB " ++ s' ++ " open")
        showDB (fromList [(0, "0")])
        
    runMachine {inState = (s, Conn, db, r)} 
               {outState = (s, NotConn, db, [])} CLOSEDB = putStrLn ("DB " ++ s ++ " closed")
    runMachine {inState = (s, Conn, db, r)} 
               {outState = (s, Conn, (fst (eval q db)), (snd (eval q db)))} (QUERYDB q) = 
               do putStrLn("DB contents") 
                  showDB   (fst (eval q db))
                  putStrLn("Query result")
                  putStrLn (unwords (snd (eval q db)))               
    runMachine (Pure x) = pure x
    runMachine (cmd >>= prog) = do x <- runMachine cmd
                                   runMachine (prog x)
    runMachine (Display str) = putStrLn str
    runMachine {inState = (s, c, db, r)} GetInput
      = do putStr ("DB: " ++ s ++ "> ")
           x <- getLine
           pure (strToInput x)
             
    data Fuel = Dry | More (Lazy Fuel)

    partial
    forever : Fuel
    forever = More forever

    run : Fuel -> DBIO state -> IO ()
    run (More fuel) (Do c f) 
      = do res <- runMachine c
           run fuel (f res)
    run Dry p = pure ()

    namespace DBDo
      (>>=) : DBCmd a state1 state2 ->
              (a -> Inf (DBIO state2)) -> DBIO state1
      (>>=) = Do

    dbLoop : DBIO st
    dbLoop {st = (n, NotConn, d, [])} =
         do Just x <- GetInput | Nothing => do Display "Invalid input"
                                               dbLoop
            case x of
                OPEN x => 
                  do OPENDB x {db = d}
                     dbLoop
                otherwise => 
                  do Display "You should open the database first."
                     dbLoop

    dbLoop {st = (n, Conn, d, r)} =
         do Just x <- GetInput | Nothing => do Display "Invalid input"
                                               dbLoop
            case x of
                CLOSE => 
                  do CLOSEDB {s = n} {db = d}
                     dbLoop
                (QUERY q) => 
                  do QUERYDB q {s = n} {db = d}
                     dbLoop
                otherwise => do Display "Either close or query the database."
                                dbLoop

main : IO ()
main = run forever (dbLoop {st = ("", NotConn, fromList [(0,"0")], [])})


