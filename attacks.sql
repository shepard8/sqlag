-- sqlag - Computes attack graphs (relational database theory) in SQL.
-- Copyright (C) 2018 Fabian Pijcke
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

CREATE VIEW v_attacks AS
WITH RECURSIVE T(qry_id, atm_id, atm_keyclosure, atm_attvarslist, atm_attatomslist) AS (
  SELECT qry_id, atm_id, atm_keyclosure, atm_nkeylist - atm_keyclosure, '{}'::int[] + atm_id
  FROM v_atom_varlists
  NATURAL JOIN v_keyclosure
  UNION
  SELECT T.qry_id, T.atm_id, atm_keyclosure, T.atm_attvarslist | (SELECT array_agg(sbl_id) - T.atm_keyclosure FROM t_atom_symbol NATURAL JOIN t_symbol WHERE NOT sbl_constant AND atm_id = ANY(T.atm_attatomslist)), T.atm_attatomslist | av.atm_id
  FROM T
  LEFT JOIN t_query_atom ON T.qry_id = t_query_atom.qry_id
  LEFT JOIN v_atom_varlists av ON av.atm_id = t_query_atom.atm_id AND # (T.atm_attvarslist & ((av.atm_keylist | av.atm_nkeylist) - T.atm_keyclosure)) > 0
),
V AS (
  SELECT qry_id, atm_id, array_agg(sbl_id) AS atm_attvarslist
  FROM (SELECT DISTINCT qry_id, atm_id, unnest(atm_attvarslist) AS sbl_id FROM T) U
  GROUP BY qry_id, atm_id
),
A AS (
  SELECT qry_id, atm_id, array_agg(atm_id_attacked) AS atm_attatomslist
  FROM (SELECT DISTINCT qry_id, atm_id, unnest(atm_attatomslist - atm_id) AS atm_id_attacked FROM T) U
  GROUP BY qry_id, atm_id
)
SELECT qry_id, atm_id, atm_attvarslist, atm_attatomslist
FROM t_query_atom
NATURAL JOIN V
NATURAL JOIN A;

CREATE VIEW v_attack_graph AS
SELECT qry_id, atm_id AS atm_id_from, unnest(atm_attatomslist) AS atm_id_to
FROM v_attacks;

