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

CREATE VIEW v_query_rewritable AS
SELECT qry_id
FROM t_query
EXCEPT
SELECT ag1.qry_id
FROM v_attack_graph ag1
INNER JOIN v_attack_graph ag2 ON ag1.qry_id = ag2.qry_id AND ag1.atm_id_from = ag2.atm_id_to AND ag1.atm_id_to = ag2.atm_id_from;

CREATE VIEW v_atom_cycle AS
SELECT ag1.qry_id, ag1.atm_id_from AS atm_id
FROM v_attack_graph ag1
INNER JOIN v_attack_graph ag2 ON ag1.qry_id = ag2.qry_id AND ag1.atm_id_from = ag2.atm_id_to AND ag1.atm_id_to = ag2.atm_id_from;

CREATE VIEW v_atom_stratum AS
WITH RECURSIVE BASE(qry_id, atm_id_from, atm_id_to, atm_stratum) AS (
  SELECT qa.qry_id, qa.atm_id, atm_id_to, CASE
      WHEN EXISTS (
        SELECT *
        FROM v_attack_graph ag2
        WHERE ag2.atm_id_from = ag.atm_id_to
          AND ag2.atm_id_to = ag.atm_id_from
          AND ag2.qry_id = ag.qry_id
      ) THEN NULL
      ELSE 1
    END
  FROM t_query_atom qa
  LEFT JOIN v_attack_graph ag ON ag.qry_id = qa.qry_id AND ag.atm_id_from = qa.atm_id
),
T(qry_id, atm_id_from, atm_id_to, atm_stratum) AS (
  SELECT * FROM BASE
  UNION
  SELECT ft.qry_id, tt.atm_id_from, tt.atm_id_to, ft.atm_stratum + 1
  FROM T ft
  INNER JOIN v_attack_graph tt ON ft.qry_id = tt.qry_id AND ft.atm_id_to = tt.atm_id_from
  WHERE tt.atm_id_from NOT IN (SELECT atm_id FROM v_atom_cycle WHERE qry_id = ft.qry_id)
)
SELECT qry_id, atm_id_from AS atm_id, MAX(atm_stratum) AS atm_stratum FROM T GROUP BY qry_id, atm_id_from;

