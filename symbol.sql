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

CREATE TABLE t_symbol (
  sbl_id SERIAL NOT NULL PRIMARY KEY,
  sbl_constant BOOLEAN NOT NULL,
  sbl_name VARCHAR(255) NOT NULL,
  UNIQUE (sbl_name, sbl_constant),
  UNIQUE (sbl_id, sbl_constant)
);

CREATE VIEW v_symbol_string AS
SELECT sbl_id, CASE
    WHEN sbl_constant AND sbl_name ~ '^[a-hA-H][a-zA-Z0-9_-]*$' THEN sbl_name
    WHEN sbl_constant THEN '''' || replace(sbl_name, '''', '''''') || ''''
    WHEN sbl_name ~ '^[i-zI-Z][a-zA-Z0-9_-]*$' then sbl_name
    ELSE '"' || replace(sbl_name, '"', '""') || '"'
  END AS sbl_string
FROM t_symbol;

CREATE FUNCTION f_symbol(name VARCHAR(255), constant BOOLEAN) RETURNS INT AS $$
  INSERT INTO t_symbol (sbl_name, sbl_constant)
  VALUES (name, constant)
  -- So that sbl_id is returned on conflict
  ON CONFLICT (sbl_name, sbl_constant) DO UPDATE SET sbl_constant = constant
  RETURNING sbl_id
$$ LANGUAGE SQL;

CREATE FUNCTION f_constant(name VARCHAR(255)) RETURNS INT AS $$
  SELECT f_symbol(name, true)
$$ LANGUAGE SQL;

CREATE FUNCTION f_variable(name VARCHAR(255)) RETURNS INT AS $$
  SELECT f_symbol(name, false)
$$ LANGUAGE SQL;

