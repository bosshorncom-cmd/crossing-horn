open Crossing_horn

let usage () =
  print_string
    "crossing-horn list\n\
     crossing-horn intervals <id|\"- - o -\"> [--csv]\n\
     crossing-horn onset <mph>\n\
     crossing-horn level <dBA-at-100ft> <distance-ft>\n";
  exit 2

let pattern_of arg =
  match find arg with
  | Some s -> s.pattern
  | None -> (
      match parse arg with
      | Ok p -> p
      | Error e -> prerr_endline e; exit 1)

let () =
  match Array.to_list Sys.argv |> List.tl with
  | [ "list" ] ->
      List.iter
        (fun s -> Printf.printf "%-12s %-18s %s [%s]\n" s.id (notation s.pattern) s.meaning s.source)
        catalog
  | "intervals" :: arg :: rest ->
      let iv = intervals (pattern_of arg) in
      let csv = List.mem "--csv" rest in
      if csv then print_endline "state,ms";
      List.iter
        (fun (on, ms) ->
          if csv then Printf.printf "%s,%d\n" (if on then "on" else "off") ms
          else Printf.printf "%-4s %5d ms\n" (if on then "ON" else "off") ms)
        iv;
      if not csv then Printf.printf "total %d ms\n" (total_ms iv)
  | [ "onset"; mph ] ->
      let mph = float_of_string mph in
      let w = onset_window ~mph in
      if w.capped then
        Printf.printf "%.0f mph: begin at %.0f ft (quarter-mile cap, %.1f s warning)\n" mph
          w.latest_ft (seconds_to_crossing ~mph ~distance_ft:w.latest_ft)
      else
        Printf.printf "%.0f mph: begin between %.0f ft and %.0f ft before the crossing (20 s to 15 s)\n"
          mph w.earliest_ft w.latest_ft
  | [ "level"; db; d ] ->
      let l = level_at ~ref_dba:(float_of_string db) ~ref_ft:100. ~distance_ft:(float_of_string d) in
      Printf.printf "%.1f dB(A) free-field estimate at %s ft (reference %s dB(A) at 100 ft%s)\n" l d db
        (if within_fra_band (float_of_string db) then ", inside 96-110 band" else ", OUTSIDE 96-110 band")
  | _ -> usage ()
