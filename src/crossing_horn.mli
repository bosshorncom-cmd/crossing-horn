(** Grade-crossing horn timing and audibility arithmetic.

    All distances are in feet, speeds in miles per hour, times in
    milliseconds or seconds as named, and sound levels in dB(A). The
    figures follow the U.S. Federal Railroad Administration rules cited
    on each value; they are a study and planning aid, not operating
    instructions. *)

(** {1 Signal patterns} *)

type sound =
  | Short  (** a short sound, about one second *)
  | Long   (** a long sound, about three seconds *)

type signal = {
  id : string;            (** stable identifier, e.g. ["crossing"] *)
  pattern : sound list;   (** sounds in order *)
  meaning : string;       (** plain-language gloss *)
  source : string;        (** rule reference *)
}

val catalog : signal list
(** Common GCOR 5.8.2 whistle signals. The crossing signal is
    [Long; Long; Short; Long]. *)

val find : string -> signal option

val notation : sound list -> string
(** Rulebook notation: ["-"] for long, ["o"] for short, space separated. *)

val parse : string -> (sound list, string) result
(** Inverse of {!notation}. Accepts ["-"], ["L"], ["o"], ["S"]. *)

type timing = {
  short_ms : int;  (** default 1000 *)
  long_ms : int;   (** default 3000 *)
  gap_ms : int;    (** silence between sounds, default 1000 *)
}

val default_timing : timing

val intervals : ?timing:timing -> sound list -> (bool * int) list
(** [(on, duration_ms)] pairs, alternating sound and silence, with no
    trailing silence. Suitable for a relay or a test harness. *)

val total_ms : (bool * int) list -> int

(** {1 When to start sounding (49 CFR 222.21)} *)

type onset = {
  earliest_ft : float;  (** do not start farther out than this *)
  latest_ft : float;    (** start no closer than this *)
  capped : bool;        (** true when the quarter-mile cap applies (> 60 mph) *)
}

val onset_window : mph:float -> onset
(** Distance window, measured back from the crossing, in which the horn
    must begin: at least 15 s and at most 20 s before the lead locomotive
    enters the crossing. Above 60 mph the horn need not start more than
    one quarter mile (1320 ft) out, even if that is under 15 s.
    @raise Invalid_argument if [mph <= 0]. *)

val seconds_to_crossing : mph:float -> distance_ft:float -> float

(** {1 Sound level (49 CFR 229.129)} *)

val fra_min_dba : float  (** 96 dB(A) at 100 ft *)

val fra_max_dba : float  (** 110 dB(A) at 100 ft *)

val level_at : ref_dba:float -> ref_ft:float -> distance_ft:float -> float
(** Free-field inverse-square estimate: [L2 = L1 - 20 log10 (d2 / d1)].
    Ignores ground effect, air absorption and barriers, so real levels
    far from the track are usually lower. *)

val within_fra_band : float -> bool
(** Whether a level measured 100 ft ahead of the locomotive falls inside
    the 96-110 dB(A) band. *)

val distance_for_level : ref_dba:float -> ref_ft:float -> target_dba:float -> float
(** Distance at which the free-field estimate falls to [target_dba]. *)
