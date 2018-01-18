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

CREATE VIEW v_query_relation_name_count AS
SELECT qry_id, atm_relation_name, COUNT(*) AS atm_occurences
FROM t_query
NATURAL JOIN t_query_atom
NATURAL JOIN t_atom
GROUP BY qry_id, atm_relation_name;

CREATE VIEW v_selfjoinfree AS
SELECT qry_id
FROM t_query
LEFT JOIN v_query_relation_name_count USING (qry_id)
GROUP BY qry_id
HAVING COALESCE(MAX(atm_occurences), 1) = 1;

