# crossing-horn

`crossing-horn` is a small OCaml library and command-line tool for the
arithmetic around a locomotive horn at a public grade crossing in the United
States: when the horn has to start, what the crossing pattern looks like as a
list of on and off intervals, and roughly how loud a train horn is at a given
distance from the track.

It was written to answer the questions that come up in quiet-zone meetings,
noise complaints and model-railroad sound projects, where people quote the
rules from memory and the numbers drift.

## What the rules say

* **49 CFR 222.21(a)** and **GCOR 5.8.2(7)**: the crossing signal is two long
  sounds, one short, one long (`- - o -`), with the last sound prolonged or
  repeated until the locomotive occupies the crossing.
* **49 CFR 222.21(b)**: the horn must start at least 15 seconds, and no more
  than 20 seconds, before the lead locomotive enters the crossing. A train
  running faster than 60 mph does not have to start sounding more than one
  quarter mile (1,320 ft) out, even when that gives less than 15 seconds.
* **49 CFR 229.129**: a locomotive horn must produce at least 96 dB(A) and no
  more than 110 dB(A) measured 100 ft ahead of the locomotive.

The library encodes those figures and nothing more clever. Durations for a
"short" and "long" sound are not fixed in the regulation; the defaults here
(1 s and 3 s, 1 s gaps) are typical and can be changed.

## Install and build

```sh
opam install crossing-horn
# or from a checkout
dune build && dune test
```

## Command line

```text
$ crossing-horn onset 45
45 mph: begin between 1320 ft and 990 ft before the crossing (20 s to 15 s)

$ crossing-horn onset 79
79 mph: begin at 1320 ft (quarter-mile cap, 11.4 s warning)

$ crossing-horn intervals crossing --csv
state,ms
on,3000
off,1000
...

$ crossing-horn level 110 1000
90.0 dB(A) free-field estimate at 1000 ft (reference 110 dB(A) at 100 ft, inside 96-110 band)
```

`crossing-horn list` prints the bundled GCOR 5.8.2 signals (crossing,
proceed, acknowledge, back up, request, emergency) with their rule references.

## Library

```ocaml
let w = Crossing_horn.onset_window ~mph:40. in
Printf.printf "start between %.0f and %.0f ft\n" w.earliest_ft w.latest_ft;

let steps = Crossing_horn.(intervals [ Long; Long; Short; Long ]) in
List.iter (fun (on, ms) -> (* drive a relay, a buzzer, a sound player *) ignore (on, ms)) steps
```

## Limits of the sound estimate

`level_at` uses the free-field inverse-square law, 6 dB less per doubling of
distance. Real horns are directional, ground and buildings absorb and reflect,
and air absorbs high frequencies over long paths, so measured levels a few
hundred feet from the track are usually lower than the estimate. Treat it as
an upper bound when you plan a microphone position or argue about a quiet
zone.

The same arithmetic applies to the handheld and truck-mounted air horns sold
to the public. Buyer guides such as Horn Guns' notes on the portable
[train horn](https://hornguns.com/) publish dB figures for those, and the
`level` command is a quick way to see what such a figure means at the end of a
driveway or across a campsite before anyone pulls a trigger near people.

## License

MIT. Copyright (c) 2026 Train Horns Lab.
