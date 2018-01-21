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

CREATE VIEW v_atom_drc_exists AS
SELECT atm_id, atm_relation_name_string || '(' ||
  string_agg(sbl_string, ', ' ORDER BY ats_position)
  || ')' AS atm_drc_exists
FROM t_atom
NATURAL JOIN v_atom_relation_name_string
LEFT JOIN t_atom_symbol USING (atm_id)
LEFT JOIN v_symbol_string USING (sbl_id)
GROUP BY atm_id, atm_relation_name_string;

CREATE VIEW v_atom_drc_forall AS
SELECT qry_id, atm_id, atm_relation_name_string || '(' ||
  string_agg(COALESCE('sqlag_' || sbl_constraint_id, sbl_string), ', ' ORDER BY ats_position)
  || ')' AS atm_drc_forall
FROM t_query_atom
NATURAL JOIN v_atom_relation_name_string
LEFT JOIN t_atom_symbol USING (atm_id)
LEFT JOIN v_symbol_rew_constraint USING (qry_id, atm_id, ats_position)
LEFT JOIN v_symbol_string USING (sbl_id)
GROUP BY qry_id, atm_id, atm_relation_name_string;

CREATE VIEW v_atom_drc_constraints AS
SELECT qry_id, atm_id, string_agg('sqlag_' || sbl_constraint_id || ' = ' || sbl_string, ' /\ ') AS atm_constraints
FROM t_query_atom
NATURAL JOIN v_symbol_rew_constraint
NATURAL JOIN t_atom_symbol
NATURAL JOIN v_symbol_string
GROUP BY qry_id, atm_id;

CREATE VIEW v_atom_drc_exists_variables AS
WITH V(qry_id, atm_id, sbl_id) AS (
  SELECT qry_id, atm_id, sbl_id
  FROM v_query_rewritable
  NATURAL JOIN t_query_atom
  NATURAL JOIN t_atom_symbol
  NATURAL JOIN t_symbol
  WHERE NOT sbl_constant
  EXCEPT
  SELECT qry_id, atm_id, sbl_id
  FROM v_atom_rew_free
)
SELECT qry_id, atm_id, string_agg(sbl_string, ', ') AS atm_exists_variables
FROM V
NATURAL JOIN v_symbol_string
GROUP BY qry_id, atm_id;

CREATE VIEW v_atom_drc_forall_variables AS
SELECT qry_id, atm_id, string_agg(coalesce('sqlag_' || sbl_constraint_id, sbl_string), ', ') AS atm_forall_variables
FROM v_query_rewritable
NATURAL JOIN t_query_atom
NATURAL JOIN t_atom_symbol
NATURAL JOIN t_symbol
NATURAL JOIN v_symbol_string
LEFT JOIN v_symbol_rew_constraint USING (qry_id, atm_id, ats_position)
WHERE NOT sbl_constant
AND NOT ats_key
GROUP BY qry_id, atm_id;

CREATE VIEW v_query_drc AS
WITH F(qry_id, qry_free_string) AS (
  SELECT qry_id, string_agg(sbl_string, ', ')
  FROM t_query_free
  NATURAL JOIN v_symbol_string
  GROUP BY qry_id
)
SELECT qry_id, CASE WHEN qry_free_string IS NOT NULL THEN qry_free_string || ' | ' ELSE '' END ||
string_agg(
  CASE WHEN atm_exists_variables IS NOT NULL THEN 'EXISTS ' || atm_exists_variables || ' (' ELSE '' END ||
  atm_drc_exists ||
  CASE WHEN atm_forall_variables IS NOT NULL THEN ' /\ FORALL ' || atm_forall_variables || ' (' ELSE '' END ||
  atm_drc_forall ||
  ' -> (' ||
  CASE WHEN atm_constraints IS NOT NULL THEN atm_constraints ELSE 'TRUE' END || ' /\ ', ''
) || ' TRUE ' || string_agg (
  CASE WHEN atm_forall_variables IS NOT NULL THEN ')' ELSE '' END ||
  CASE WHEN atm_exists_variables IS NOT NULL THEN ')' ELSE '' END ||
  ')', ''
) AS qry_drc
FROM v_query_rewritable
LEFT JOIN F USING (qry_id)
LEFT JOIN v_atom_rew_order USING (qry_id)
LEFT JOIN v_atom_drc_exists_variables USING (qry_id, atm_id)
LEFT JOIN v_atom_drc_exists USING (atm_id)
LEFT JOIN v_atom_drc_forall_variables USING (qry_id, atm_id)
LEFT JOIN v_atom_drc_forall USING (qry_id, atm_id)
LEFT JOIN v_atom_drc_constraints USING (qry_id, atm_id)
GROUP BY qry_id, qry_free_string
;
