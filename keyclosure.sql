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

CREATE EXTENSION intarray;

CREATE VIEW v_atom_varlists AS
SELECT ta.atm_id, array_agg(tas.sbl_id) FILTER(WHERE ats_key) AS atm_keylist, array_agg(tas.sbl_id) FILTER(WHERE NOT ats_key) AS atm_nkeylist
FROM t_atom ta
LEFT JOIN t_atom_symbol tas ON ta.atm_id = tas.atm_id
LEFT JOIN t_symbol ts ON ts.sbl_id = tas.sbl_id AND NOT sbl_constant
GROUP BY ta.atm_id;

CREATE VIEW v_keyclosure AS
WITH RECURSIVE T AS (
  SELECT t_query_atom.qry_id, t_query_atom.atm_id, array_remove(array_agg(t_symbol.sbl_id), NULL) AS atm_keyclosure
  FROM t_query_atom
  LEFT JOIN t_atom_symbol ON (t_query_atom.atm_id = t_atom_symbol.atm_id AND ats_key)
  LEFT JOIN t_symbol ON (t_atom_symbol.sbl_id = t_symbol.sbl_id AND NOT sbl_constant)
  GROUP BY t_query_atom.qry_id, t_query_atom.atm_id
  UNION
  SELECT T.qry_id, T.atm_id, T.atm_keyclosure | v_atom_varlists.atm_nkeylist
  FROM T
  LEFT JOIN t_query_atom ON t_query_atom.qry_id = T.qry_id AND t_query_atom.atm_id <> T.atm_id
  LEFT JOIN v_atom_varlists ON v_atom_varlists.atm_id = t_query_atom.atm_id AND v_atom_varlists.atm_keylist <@ T.atm_keyclosure
)
SELECT qry_id, atm_id, array_agg(sbl_id) AS atm_keyclosure
FROM (SELECT DISTINCT qry_id, atm_id, unnest(atm_keyclosure) AS sbl_id FROM T) U
GROUP BY qry_id, atm_id;

