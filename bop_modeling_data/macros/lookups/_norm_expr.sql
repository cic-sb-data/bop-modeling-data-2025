{# =======================================================================
  _lookups__norm_expr
  -----------------------------------------------------------------------
  Normalise a raw field so that it can be compared against the lookup
  table’s cleaned column.

  Steps
  -----
  1.  _lookups__apply_corrections  → maps bad → good strings
  2.  _lookups__apply_null_strategy → deals with NULL vs sentinel/keep/skip

  Parameters
  ----------
  col       : str   – fully-qualified column name (e.g. "src.lob_cd").
  corr      : dict  – mapping {bad_value: good_value}.  Pass {} if none.
  strategy  : 'sentinel' | 'keep' | 'skip'
  sentinel  : str   – placeholder used when strategy == 'sentinel'.

  Returns
  -------
  Jinja-rendered SQL expression, ready for equality join.
======================================================================= #}
{% macro _lookups__norm_expr(
        col,
        corr       = {},
        strategy   = 'sentinel',
        sentinel   = '__NULL__'
    ) -%}

    {{ _lookups__apply_null_strategy(
         _lookups__apply_corrections(col, corr),
         strategy,
         sentinel
    ) }}

{%- endmacro %}