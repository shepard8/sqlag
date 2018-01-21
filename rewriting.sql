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

CREATE VIEW v_atom_rew_order AS
SELECT qry_id, atm_id, row_number() OVER (PARTITION BY qry_id ORDER BY atm_stratum, atm_id) AS atm_rew_order
FROM v_query_rewritable
NATURAL JOIN v_atom_stratum;

CREATE VIEW v_atom_rew_free AS
SELECT base.qry_id, base.atm_id, sbl_id
FROM v_atom_rew_order base
INNER JOIN v_atom_rew_order free ON free.atm_rew_order < base.atm_rew_order AND free.qry_id = base.qry_id
INNER JOIN t_atom_symbol s ON free.atm_id = s.atm_id
NATURAL JOIN t_symbol
WHERE NOT sbl_constant
UNION
SELECT qry_id, atm_id, sbl_id
FROM t_query_atom
NATURAL JOIN v_query_rewritable
NATURAL JOIN t_query_free
NATURAL JOIN t_symbol
WHERE NOT sbl_constant;

CREATE VIEW v_symbol_rew_constrained AS
SELECT qry_id, atm_id, ats_position
FROM v_atom_rew_order
NATURAL JOIN t_atom_symbol
NATURAL JOIN t_symbol
WHERE sbl_constant AND NOT ats_key
UNION
SELECT qry_id, atm_id, ats_position
FROM v_atom_rew_order
NATURAL JOIN t_atom_symbol
NATURAL JOIN v_atom_rew_free
WHERE NOT ats_key
UNION
SELECT qry_id, qa.atm_id, as1.ats_position
FROM v_query_rewritable
NATURAL JOIN t_query_atom qa
INNER JOIN t_atom_symbol as1 ON as1.atm_id = qa.atm_id AND NOT as1.ats_key
-- No need to check thas as1.sbl_id is not a constant, UNION will wipe out duplicates anyway.
INNER JOIN t_atom_symbol as2 ON as2.atm_id = qa.atm_id AND as1.sbl_id = as2.sbl_id AND (as2.ats_key OR as2.ats_position < as1.ats_position);

CREATE VIEW v_symbol_rew_constraint AS
SELECT qry_id, atm_id, ats_position, row_number() OVER (PARTITION BY qry_id ORDER BY atm_rew_order, ats_position) AS sbl_constraint_id
FROM v_atom_rew_order
NATURAL JOIN v_symbol_rew_constrained;
