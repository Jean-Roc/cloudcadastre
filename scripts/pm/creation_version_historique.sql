/*
création d'une version contenant tous les millésimes
chaque élément a une borne d'apparition et une de disparation
p. ex. 
- un enregistrement existant dans tous les millésimes entre 2019 et 2025 n'existera qu'une fois avec des bornes min et max = à 2019 et 2025
- une enregistrement modifiée ou supprimée en 2024 n'existera une fois avec des bornes min max 2019 et 2023, la nouvelle version avec 2024-2025

D:\Users\jrmorreale\Documents\Applications\duckdb.exe D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\PM_merge.duckdb
*/

SET VARIABLE data_merge_path = 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\\';

CREATE TABLE "parcelles" AS
SELECT * 
FROM read_parquet(getvariable('data_merge_path') || 'parcelles_personnes_morales_complet', hive_partitioning = true);

ALTER TABLE "parcelles"
	ADD COLUMN sum_sha256 VARCHAR;

UPDATE "parcelles"
SET sum_sha256 = sha256(
	"code_insee" || "section" || "numero_parcelle"||COALESCE("prefixe", '0') ||
	"numero_majic"||COALESCE("numero_siren", '0') || "code_droit" ||
	COALESCE("groupe_personne_code", '0') || "forme_juridique" ||
	COALESCE("denomination", '0') ||
	"contenance_parcelle_centiare" || "contenance_subdivision_centiare" ||"nature_culture_code" || COALESCE("subdivision_fiscale", '0')
	);

SELECT *, MIN("millesime"), MAX("millesime")
FROM "parcelles"
GROUP BY sum_sha256;

SELECT COUNT(*)
FROM "parcelles";

SUMMARIZE SELECT sum_sha256 FROM "parcelles";

SELECT DISTINCT sum_sha256 FROM "parcelles";

SELECT sum_sha256, COUNT(*)
FROM "parcelles"
GROUP BY sum_sha256
HAVING COUNT(*) > 6;

SELECT *
FROM "parcelles"
WHERE sum_sha256 = '5e41def4484e2dbcf219472f72a4763b99f8e9aa5c6695b15e4c642a2617be91';

WITH 
sum_avec_denomination AS (
	SELECT sha256(
		"code_insee" || "section" || "numero_parcelle"||COALESCE("prefixe", '0') ||
		"numero_majic"||COALESCE("numero_siren", '0') || "code_droit" ||
		COALESCE("groupe_personne_code", '0') || "forme_juridique" ||
		COALESCE("denomination", '0') ||
		"contenance_parcelle_centiare" || "contenance_subdivision_centiare" ||"nature_culture_code" || COALESCE("subdivision_fiscale", '0')
		)
	FROM "parcelles"),
sha256_distinct AS (SELECT DISTINCT * FROM sum_avec_denomination);

WITH 
sum_avec_voirie AS (
	SELECT sha256(
		"code_insee" || "section" || "numero_parcelle"||COALESCE("prefixe", '0') ||
		"numero_majic"||COALESCE("numero_siren", '0') || "code_droit" ||
		COALESCE("groupe_personne_code", '0') || "forme_juridique" ||
		COALESCE("denomination", '0') ||
		"contenance_parcelle_centiare" || "contenance_subdivision_centiare" ||"nature_culture_code" || COALESCE("subdivision_fiscale", '0') ||
		"code_voie_majic"
		) AS sha256_concat
	FROM "parcelles"),
sha256_distinct AS (SELECT DISTINCT sha256_concat FROM sum_avec_voirie)
SELECT COUNT(*)
FROM sha256_distinct;

-- 139469357 139.47 million rows
-- 39549534 rows 39.55 million rows DISTINCT sum_sha256 avec denomination
-- 36870532 rows 36.87 million rows DISTINCT sum_sha256 sans denomination
-- 56769091 (56.77 million) rows DISTINCT sum_sha256 avec voirie
-- 35038434 approx_unique