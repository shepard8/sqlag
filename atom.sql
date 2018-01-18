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

CREATE TABLE t_atom (
  atm_id SERIAL NOT NULL PRIMARY KEY,
  atm_relation_name VARCHAR(30) NOT NULL
);

CREATE TABLE t_atom_symbol (
  atm_id INT NOT NULL REFERENCES t_atom,
  sbl_id INT NOT NULL REFERENCES t_symbol,
  ats_position INT NOT NULL,
  ats_key BOOLEAN NOT NULL,
  PRIMARY KEY(atm_id, ats_position)
);

CREATE VIEW v_atom_key AS (
  SELECT atm_id, sbl_id, ats_position
  FROM t_atom_symbol
  WHERE ats_key
);

CREATE VIEW v_atom_nkey AS (
  SELECT atm_id, sbl_id, ats_position
  FROM t_atom_symbol
  WHERE NOT ats_key
);

CREATE VIEW v_atom_relation_name_string AS (
  SELECT atm_id, CASE
      WHEN atm_relation_name ~ '^[a-zA-Z_-]+$' THEN atm_relation_name
      ELSE '"' || replace(atm_relation_name, '"', '""') || '"'
    END AS atm_relation_name_string
  FROM t_atom
);

CREATE VIEW v_atom_key_string AS (
  SELECT atm_id, string_agg(sbl_string, ', ' ORDER BY ats_position) AS atm_key_string
  FROM v_atom_key
  NATURAL JOIN v_symbol_string
  GROUP BY atm_id
);

CREATE VIEW v_atom_nkey_string AS (
  SELECT atm_id, string_agg(sbl_string, ', ' ORDER BY ats_position) AS atm_nkey_string
  FROM v_atom_nkey
  NATURAL JOIN v_symbol_string
  GROUP BY atm_id
);

CREATE VIEW v_atom_string AS (
  SELECT atm_id, atm_relation_name_string || '(' || atm_key_string || '; ' || atm_nkey_string || ')' AS atm_string
  FROM t_atom
  NATURAL JOIN v_atom_relation_name_string
  NATURAL JOIN v_atom_key_string
  NATURAL JOIN v_atom_nkey_string
);

