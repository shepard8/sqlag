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

CREATE TABLE t_query (
  qry_id SERIAL NOT NULL PRIMARY KEY
);

CREATE TABLE t_query_atom (
  qry_id INT NOT NULL REFERENCES t_query,
  atm_id INT NOT NULL REFERENCES t_atom
);

CREATE TABLE t_query_free (
  qry_id INT NOT NULL REFERENCES t_query,
  sbl_id INT NOT NULL REFERENCES t_symbol,
  qfr_position INT NOT NULL,
  PRIMARY KEY(qry_id, qfr_position)
);

CREATE VIEW v_query_frees_string AS
SELECT qry_id, string_agg(sbl_string, ', ' ORDER BY qfr_position) AS qry_frees_string
FROM t_query
LEFT JOIN t_query_free USING (qry_id)
LEFT JOIN v_symbol_string USING (sbl_id)
GROUP BY qry_id;

CREATE VIEW v_query_atoms_string AS
SELECT qry_id, string_agg(atm_string, ' /\ ') AS qry_atoms_string
FROM t_query
LEFT JOIN t_query_atom USING (qry_id)
LEFT JOIN v_atom_string USING (atm_id)
GROUP BY qry_id;

CREATE VIEW v_query_string AS
SELECT qry_id, CASE
    WHEN qry_frees_string IS NULL THEN qry_atoms_string
    ELSE '{ ' || qry_frees_string || ' | ' || coalesce(qry_atoms_string, 'true') || ' }'
  END AS qry_string
FROM t_query
NATURAL JOIN v_query_frees_string
NATURAL JOIN v_query_atoms_string;

