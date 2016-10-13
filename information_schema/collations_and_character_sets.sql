
# Get Database default collations & characters sets along with any table & column exceptions
# 1k limit for GROUP_CONCAT by default.
# If needed...# SET SESSION group_concat_max_len = 1000000;
SELECT  s.`SCHEMA_NAME`,
	s.`DEFAULT_CHARACTER_SET_NAME`,
	s.`DEFAULT_COLLATION_NAME`,
	GROUP_CONCAT(DISTINCT t.`TABLE_COLLATION`) AS table_collations,
	GROUP_CONCAT(DISTINCT c.`CHARACTER_SET_NAME`) AS column_character_sets,
	GROUP_CONCAT(DISTINCT c.`COLLATION_NAME`) AS column_collation_names
FROM information_schema.SCHEMATA s
LEFT JOIN information_schema.TABLES t
	ON s.`SCHEMA_NAME` = t.`TABLE_SCHEMA`
LEFT JOIN information_schema.COLUMNS c
	ON c.`TABLE_SCHEMA` = t.`TABLE_SCHEMA`
	AND c.`TABLE_NAME` = t.`TABLE_NAME`
GROUP BY s.`SCHEMA_NAME`;
