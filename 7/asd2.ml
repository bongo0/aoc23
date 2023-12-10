(* eval $(opam env)  *)
(* ocamlc asd1.ml && ./a.out *)
(* comments wow *)

let fname = "input";;

type hand = {
  str : string;
  bid : int;
  knd : int;
  rnk : int;
};;

(*
ordering:
A > K > Q  > T > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2 > J
6: Five of a kind
5: Four of a kind
4: Full house
3: Three of a kind
2: Two pair
1: One pair
0: High card

Hashtbl.iter (fun x y -> Printf.printf "%c %d\n" x y ) ht;;
let n = Hashtbl.find ht 'A' in Hashtbl.add ht 'A' (n+1);;
*)

let cards = ['A';'K';'Q';'T';'9';'8';'7';'6';'5';'4';'3';'2';'J';];;

(* hash map from cards -> value *)
let card_val = Hashtbl.create 13;;
List.iteri (fun i e -> Hashtbl.add card_val e (14-i) ) cards;;
(* Hashtbl.iter (fun x y -> Printf.printf "%c %d\n" x y ) card_val;; *)

(*count number of occurences of int i in list*)
let count_ints i = List.fold_left (fun count element -> if (element <> i) then count else (count+1) ) 0;;

let counts_to_type = function
    | c when (List.mem 5 c = true) -> 6
    | c when (List.mem 4 c = true) -> 5
    | c when (List.mem 3 c = true 
           && List.mem 2 c = true) -> 4
    | c when (List.mem 3 c = true) -> 3
    | c when (count_ints 2 c = 2)  -> 2
    | c when (count_ints 2 c = 1)  -> 1
    |                            _ -> 0;;

let hand_kind str : int = 
  let ht = Hashtbl.create 13 in
  List.iter (fun c -> Hashtbl.add ht c 0) cards;
  (* hand to hashtable of counts of different types of cards *)
  (* count how many of each kind of card in hand *)
  List.iter (fun c -> (let n = Hashtbl.find ht c in Hashtbl.replace ht c (n+1))) 
            (List.of_seq (String.to_seq str) );

  let jokers = Hashtbl.find ht 'J' in
  let largest = Hashtbl.fold (fun k v acc ->
                                 if k='J' then acc 
                            else if v > (snd acc) then (k,v)
                            else acc
                              ) ht ('A',0) in
  (* Printf.printf "largest %c %d %s\n" (fst largest) (snd largest) str; *)
  if jokers > 0 then 
    (
      Hashtbl.replace ht (fst largest) (jokers + Hashtbl.find ht (fst largest));
      Hashtbl.replace ht 'J' 0;
    );
   (* Hashtbl.iter (fun x y -> Printf.printf "%c %d\n" x y ) ht; *)

  (* figure out hand kind *)
  (*get list of sorted counts*)
  let counts = Hashtbl.to_seq_values ht |> List.of_seq |> List.sort (fun a b -> b - a) in
    (* List.iter (fun x -> Printf.printf "%d \n" x) counts; *)
    counts_to_type counts
  ;;

let to_hand input : hand =
                                               (* filter out empty strings *)
  let a = input |> String.split_on_char ' ' |> List.filter (fun s -> s <> "") in
    {
      str = List.nth a 0;
      bid = int_of_string (List.nth a 1);
      knd = hand_kind (List.nth a 0);
      rnk = 0;
    }
  ;;

(* read input file *)
let read_data name : hand list =
  let ic = open_in name in
    let try_to_read () =
      try Some (input_line ic) with End_of_file -> None in
        let rec loop data = match try_to_read () with
          | Some s -> loop ( (to_hand s) :: data);
          | None -> close_in ic; List.rev data in
          loop [];;

let data = read_data fname;;

(* List.map (fun x -> print_endline (x.str^" : "^string_of_int x.bid^" : "^ string_of_int x.knd ) ) data;;
 *)

(*  let fold_until func predicate = 
  let rec loop acc = function
      | x :: xs when predicate x -> acc
      | x :: xs -> fold_until func predicate (acc + 1) xs *)

(* probably should use find_opt ... *)
let card_bigger c1 c2 = (Hashtbl.find card_val c1) > (Hashtbl.find card_val c2);;

(*
Sort a list in increasing order according to a comparison function.
The comparison function must 
      return 0 if its arguments compare as equal,
      a positive integer if the first is greater,
      and a negative integer if the first is smaller 
*)
let hand_compare h1 h2 : int = 
       if (h1.knd > h2.knd) then +1
  else if (h1.knd < h2.knd) then -1
  else 
      (* let i =  *)
        let rec loop acc = 
          if acc > 4 then 0
          else if card_bigger (h1.str.[acc]) (h2.str.[acc]) then +1
          else if card_bigger (h2.str.[acc]) (h1.str.[acc]) then -1
          else loop (acc+1) in
        loop 0;;
;;

print_endline ("input file name: " ^ " `" ^ fname ^ "` ");;

(* let test_hand =  "AAKKQ";;
let i = hand_kind test_hand;;
Printf.printf "hand: %s -> %d \n" test_hand i *)

(* let h1 = List.nth data 1;;
let h2 = List.nth data 0;;
let n = hand_compare h1 h2;;
Printf.printf "%s %s -> %d \n" h1.str h2.str n;; *)

let sorted_data = List.sort hand_compare data;;

let result = let rec sum dat acc i = match dat with
  | h::dat -> sum dat (acc+h.bid*i) (i+1)
  | [] -> acc in sum sorted_data 0 1;;



List.map (fun x -> print_endline (x.str^" : "^string_of_int x.bid^" : "^ string_of_int x.knd ) ) sorted_data;;
Printf.printf "result = %d \n" result