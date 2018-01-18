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

BEGIN;

\i symbol.sql
\i atom.sql
\i query.sql
\i selfjoinfree.sql
\i keyclosure.sql
\i attacks.sql

SELECT f_constant('a') AS a \gset
SELECT f_constant('b') AS b \gset
SELECT f_constant('c') AS c \gset
SELECT f_variable('x') AS x \gset
SELECT f_variable('y') AS y \gset
SELECT f_variable('z') AS z \gset

INSERT INTO t_atom (atm_relation_name) VALUES ('R') RETURNING atm_id AS r \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('S') RETURNING atm_id AS s \gset
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, :x, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, :y, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, :z, 3, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, :y, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, :x, 2, false);

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS q \gset
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:q, :r);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:q, :s);
INSERT INTO t_query_free (qry_id, sbl_id, qfr_position) VALUES (:q, :z, 1);

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS q2 \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('R') RETURNING atm_id AS r2 \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('S') RETURNING atm_id AS s2 \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('T') RETURNING atm_id AS t2 \gset
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:q2, :r2);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:q2, :s2);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:q2, :t2);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r2, :x, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r2, :y, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s2, :a, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s2, :z, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t2, :z, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t2, f_variable('u'), 2, false);

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS qconstant \gset
INSERT INTO t_query_free (qry_id, sbl_id, qfr_position) VALUES (:qconstant, :a, 1);

SELECT * FROM v_query_string;
SELECT * FROM v_atom_varlists;
SELECT * FROM v_keyclosure;
SELECT * FROM v_attacks;

ROLLBACK;

