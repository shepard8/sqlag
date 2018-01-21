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
\i rewritability.sql
\i rewriting.sql

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

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS qcycle \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('R') RETURNING atm_id AS r \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('S') RETURNING atm_id AS s \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('T') RETURNING atm_id AS t \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('U') RETURNING atm_id AS u \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('V') RETURNING atm_id AS v \gset
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcycle, :r);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcycle, :s);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcycle, :t);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcycle, :u);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcycle, :v);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, f_constant('a'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, f_variable('v'), 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, f_variable('v'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, f_variable('x1'), 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t, f_variable('x1'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t, f_variable('y1'), 2, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t, f_variable('z'), 3, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:u, f_variable('x2'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:u, f_variable('y2'), 2, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:u, f_variable('z'), 3, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:v, f_constant('a'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:v, f_variable('x2'), 2, false);

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS qjoin \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('S') RETURNING atm_id AS s \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('R') RETURNING atm_id AS r \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('T') RETURNING atm_id AS t \gset
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qjoin, :r);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qjoin, :s);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qjoin, :t);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t, f_variable('x'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:t, f_variable('y'), 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, f_variable('x'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:s, f_variable('z'), 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, f_variable('y'), 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, f_variable('z'), 2, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, f_constant('a'), 3, false);

INSERT INTO t_query DEFAULT VALUES RETURNING qry_id AS qcyclic \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('R') RETURNING atm_id AS r \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('U') RETURNING atm_id AS u \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('V') RETURNING atm_id AS v \gset
INSERT INTO t_atom (atm_relation_name) VALUES ('W') RETURNING atm_id AS w \gset
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcyclic, :r);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcyclic, :u);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcyclic, :v);
INSERT INTO t_query_atom (qry_id, atm_id) VALUES (:qcyclic, :w);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, :a, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:r, :x, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:u, :x, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:u, :y, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:v, :y, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:v, :z, 2, false);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:w, :z, 1, true);
INSERT INTO t_atom_symbol (atm_id, sbl_id, ats_position, ats_key) VALUES (:w, :x, 2, false);

SELECT * FROM v_query_string;
SELECT * FROM v_atom_varlists;
SELECT * FROM v_keyclosure natural join t_atom order by qry_id, atm_id;
SELECT * FROM v_attacks;
SELECT * FROM v_attack_graph;
SELECT * FROM v_query_rewritable;
SELECT * FROM v_atom_stratum ORDER BY qry_id, atm_id;
SELECT * FROM v_atom_rew_order;

ROLLBACK;

