open Crossing_horn

let close a b = Float.abs (a -. b) < 0.01

let () =
  (match find "crossing" with
   | Some s -> assert (notation s.pattern = "- - o -")
   | None -> assert false);
  assert (parse "- - o -" = Ok [ Long; Long; Short; Long ]);
  assert (Result.is_error (parse "x"));
  let iv = intervals [ Long; Long; Short; Long ] in
  assert (List.length iv = 7);
  assert (total_ms iv = 3000 + 3000 + 1000 + 3000 + 3000);
  let w = onset_window ~mph:30. in
  assert (close w.latest_ft 660. && close w.earliest_ft 880. && not w.capped);
  let w = onset_window ~mph:79. in
  assert (w.capped && close w.latest_ft 1320.);
  assert (close (level_at ~ref_dba:110. ~ref_ft:100. ~distance_ft:200.) 103.98);
  assert (within_fra_band 96. && not (within_fra_band 111.));
  assert (close (distance_for_level ~ref_dba:110. ~ref_ft:100. ~target_dba:90.) 1000.);
  print_endline "ok"
