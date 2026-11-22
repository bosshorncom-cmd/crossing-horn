(lang dune 3.0)
(name crossing-horn)
(version 0.1.0)
(generate_opam_files true)
(source (github bosshorncom-cmd/crossing-horn))
(homepage "https://hornguns.com/")
(license MIT)
(authors "Train Horns Lab <info@hornguns.com>")
(maintainers "Train Horns Lab <info@hornguns.com>")

(package
 (name crossing-horn)
 (synopsis "Grade-crossing horn timing and audibility arithmetic for North American railroads")
 (description
  "crossing-horn computes when a locomotive horn has to start sounding before a public grade crossing under 49 CFR 222.21, expands GCOR whistle-signal patterns into millisecond intervals, and estimates the sound level of a train horn at a distance with the free-field inverse-square law, checking it against the 96-110 dB(A) band of 49 CFR 229.129. A small CLI prints the same numbers as text or CSV.")
 (depends
  (ocaml (>= 4.08))))
