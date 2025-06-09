INTERFACE ze_i_message
  PUBLIC .


  INTERFACES if_message .
  INTERFACES if_t100_dyn_msg .
  INTERFACES if_t100_message .

  types:
    t_char01 type c length 1.

  types:
    begin of enum t_severity structure severity base type t_char01, "sychar01,
         none value is initial,
         error       value 'E',
         warning     value 'W',
         information value 'I',
         success     value 'S',
       end of enum t_severity structure severity.

  data M_SEVERITY type T_SEVERITY.

ENDINTERFACE.
