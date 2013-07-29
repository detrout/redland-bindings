/* optional input strings - can be NULL, need special conversions */
%typemap(in) const char *inStrOrNull {
  $1 = ($input == Qnil) ? NULL : STR2CSTR($input);
}
/* returning char* or NULL, need special conversions */
%typemap(out) char *{
 $result = ($1 == NULL) ? Qnil : rb_str_new2($1);
}

