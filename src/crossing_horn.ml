type sound = Short | Long

type signal = {
  id : string;
  pattern : sound list;
  meaning : string;
  source : string;
}

let catalog =
  [ { id = "crossing"; pattern = [ Long; Long; Short; Long ];
      meaning = "Approaching a public grade crossing; prolong or repeat the last sound until the locomotive occupies the crossing";
      source = "GCOR 5.8.2(7); 49 CFR 222.21(a)" };
    { id = "proceed"; pattern = [ Long; Long ];
      meaning = "Release brakes, proceed"; source = "GCOR 5.8.2" };
    { id = "applied"; pattern = [ Short ];
      meaning = "When stopped: air brakes applied, pressure equalized"; source = "GCOR 5.8.2" };
    { id = "acknowledge"; pattern = [ Short; Short ];
      meaning = "Acknowledge any signal not otherwise provided for"; source = "GCOR 5.8.2" };
    { id = "back-up"; pattern = [ Short; Short; Short ];
      meaning = "When stopped: back up; acknowledge a hand signal to back up"; source = "GCOR 5.8.2" };
    { id = "request"; pattern = [ Short; Short; Short; Short ];
      meaning = "Request that a signal be given or repeated if not understood"; source = "GCOR 5.8.2" };
    { id = "emergency"; pattern = [ Short; Short; Short; Short; Short; Short; Short; Short ];
      meaning = "Succession of short sounds: emergency, or persons or livestock on the track"; source = "GCOR 5.8.2" } ]

let find id = List.find_opt (fun s -> s.id = id) catalog

let notation p =
  String.concat " " (List.map (function Long -> "-" | Short -> "o") p)

let parse s =
  let toks = List.filter (fun t -> t <> "") (String.split_on_char ' ' (String.trim s)) in
  let rec go acc = function
    | [] -> if acc = [] then Error "empty pattern" else Ok (List.rev acc)
    | ("-" | "L" | "l") :: r -> go (Long :: acc) r
    | ("o" | "O" | "S" | "s") :: r -> go (Short :: acc) r
    | t :: _ -> Error ("unknown token: " ^ t)
  in
  go [] toks

type timing = { short_ms : int; long_ms : int; gap_ms : int }

let default_timing = { short_ms = 1000; long_ms = 3000; gap_ms = 1000 }

let intervals ?(timing = default_timing) p =
  let dur = function Short -> timing.short_ms | Long -> timing.long_ms in
  let rec go acc = function
    | [] -> List.rev acc
    | [ x ] -> List.rev ((true, dur x) :: acc)
    | x :: r -> go ((false, timing.gap_ms) :: (true, dur x) :: acc) r
  in
  go [] p

let total_ms l = List.fold_left (fun a (_, d) -> a + d) 0 l

type onset = { earliest_ft : float; latest_ft : float; capped : bool }

let ft_per_s mph = mph *. 5280. /. 3600.
let quarter_mile_ft = 1320.

let onset_window ~mph =
  if mph <= 0. then invalid_arg "onset_window: speed must be positive";
  let v = ft_per_s mph in
  let d15 = 15. *. v and d20 = 20. *. v in
  if mph > 60. then
    { earliest_ft = quarter_mile_ft; latest_ft = quarter_mile_ft; capped = true }
  else { earliest_ft = d20; latest_ft = d15; capped = false }

let seconds_to_crossing ~mph ~distance_ft = distance_ft /. ft_per_s mph

let fra_min_dba = 96.
let fra_max_dba = 110.

let level_at ~ref_dba ~ref_ft ~distance_ft =
  ref_dba -. (20. *. log10 (distance_ft /. ref_ft))

let within_fra_band l = l >= fra_min_dba && l <= fra_max_dba

let distance_for_level ~ref_dba ~ref_ft ~target_dba =
  ref_ft *. (10. ** ((ref_dba -. target_dba) /. 20.))
