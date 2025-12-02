SET VARIABLE data_path_previous = 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\parcelles\\';

/* uniformise les structures de données des millésimes 2019-2023 */

CREATE VIEW "parcelles_2019_2023" AS
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2019.parquet')
	UNION ALL BY NAME
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2020.parquet')
	UNION ALL BY NAME
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2021.parquet')
	UNION ALL BY NAME
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2022.parquet')
	UNION ALL BY NAME
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2023.parquet');

CREATE TABLE "parcelles_2019_2023_norme" AS
SELECT
	CAST("millesime" AS INTEGER) as "millesime",
	CAST(code_direction_champ_geographique AS INTEGER) AS "code_direction",
	TRIM(departement_champ_geographique) "departement",
	TRIM(code_commune_champ_geographique) AS "code_commune",
	TRIM(nom_commune_champ_geographique) AS "nom_commune",
	"departement" || "code_commune" AS "code_insee",
	TRIM(section_references_cadastrales) AS "section",
	CAST(n_plan_references_cadastrales AS INTEGER) AS "numero_parcelle",
	CASE 
		WHEN TRIM("prefixe_references_cadastrales") = '' THEN NULL
		ELSE TRIM("prefixe_references_cadastrales")
		END AS "prefixe",	
	TRIM(n_majic_proprietaires_parcelle) AS "numero_majic",
	TRIM(n_siren_proprietaires_parcelle) AS "numero_siren",
	TRIM(code_droit_proprietaires_parcelle) AS "code_droit",
	cdj."libelle" AS "code_droit_libelle",
	TRIM(groupe_personne_proprietaires_parcelle) AS "groupe_personne_code",
	gp."libelle" AS "groupe_personne_libelle",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(REGEXP_REPLACE(
		"denomination_proprietaires_parcelle", 
		'^''(.*)''$', '\1')	, '^''(.*)''$', '\1')
		, '^"(.*)"$', '\1'), 
		'*-, ') AS "denomination",
	TRIM(forme_juridique_proprietaires_parcelle) AS "forme_juridique",
	cfj."libelle" AS "forme_juridique_libelle",
	TRIM(forme_juridique_abregee_proprietaires_parcelle) AS "forme_juridique_abregee",
	TRIM(n_de_voirie_adresse_parcelle) AS "numero_voirie",
	CASE
		WHEN TRIM("indice_de_repetition_adresse_parcelle") IN ('', ',', '*', '-', '.') THEN NULL
		ELSE TRIM("indice_de_repetition_adresse_parcelle") 
		END AS "indice_repetition",
	TRIM(code_voie_majic_adresse_parcelle) AS "code_voie_majic",
	TRIM(code_voie_rivoli_adresse_parcelle) AS "code_voie_rivoli",
	TRIM(nature_voie_adresse_parcelle) AS "nature_voie",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		"nom_voie_adresse_parcelle", '^''(.*)''$', '\1'), 
		'^''(.*)''$', '\1')) AS "nom_voie",
	CAST(contenance_caracteristiques_parcelle AS INTEGER) AS "contenance_parcelle_centiare",
	TRIM(suf_evaluation_suf) AS "subdivision_fiscale",
	TRIM(nature_culture_evaluation_suf) AS "nature_culture_code",
	nat."libelle" AS "nature_culture_libelle",
	CAST(contenance_evaluation_suf AS INTEGER) AS "contenance_subdivision_centiare"	
FROM parcelles_2019_2023
LEFT JOIN dictionnaire AS cdj ON 
		cdj."code" = TRIM("forme_juridique_proprietaires_parcelle") AND 
		cdj."categorie" = 'codes_droit'
LEFT JOIN dictionnaire AS gp ON 
		gp."code" = TRIM("groupe_personne_proprietaires_parcelle") AND 
		gp."categorie" = 'groupe_pm'
LEFT JOIN dictionnaire AS cfj ON 
		cfj."code" = TRIM("forme_juridique_proprietaires_parcelle") AND 
		cfj."categorie" = 'forme_juridique'
LEFT JOIN dictionnaire AS nat ON 
		nat."code" = TRIM("nature_culture_evaluation_suf")  AND 
		nat."categorie" = 'nature_culture';

COPY (SELECT * FROM parcelles_2019_2023_norme ORDER BY millesime, code_insee, section, numero_parcelle)
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\parcelles_personnes_morales_2019_2023.parquet'
(FORMAT parquet, COMPRESSION zstd);

/* uniformise le millésime 2024 avec celui de 2025 */

CREATE VIEW "parcelles_2024" AS
SELECT * FROM read_parquet(getvariable('data_path_previous') || 'parcelles_2024.parquet');

DROP TABLE PM."parcelles_2024_norme";
CREATE TABLE "parcelles_2024_norme" AS
SELECT
	CAST("millesime" AS INTEGER) AS "millesime",
	CAST("code_direction" AS INTEGER) AS "code_direction",
	TRIM("departement") "departement",
	TRIM("code_commune") AS "code_commune",
	TRIM("nom_de_la_commune") AS "nom_commune",
	"departement" || "code_commune" AS "code_insee",
	TRIM("section") AS section,
	CAST("n_plan" AS INTEGER) AS "numero_parcelle",
	CASE 
		WHEN TRIM("prefixe") = '' THEN NULL
		ELSE TRIM("prefixe")
		END AS "prefixe",
	TRIM("n_majic_par") AS "numero_majic",
	TRIM("n_siren_par") AS "numero_siren",
	LEFT(TRIM("code_droit_par"), 1) AS "code_droit",
	TRIM(RIGHT(TRIM("code_droit_par"),
		LENGTH(TRIM("code_droit_par")) - 3
		)) AS "code_droit_libelle",
	LEFT("groupe_personne_par", 1) AS "groupe_personne_code",
	CASE 
		WHEN RIGHT(LEFT(TRIM("groupe_personne_par"), 2), 1) = 'A' THEN 'A'
		ELSE NULL
		END "groupe_personne_code_exoneration",
	gp."libelle" AS "groupe_personne_libelle",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		REGEXP_REPLACE("denomination_par", '^''(.*)''$', '\1'),
		'^''(.*)''$', '\1'),
		'^"(.*)"$', '\1'),
		'*-, ') AS "denomination",
	TRIM("forme_juridique_par") AS "forme_juridique",
	cfj."libelle" AS "forme_juridique_libelle",
	TRIM("forme_juridique_abregee_par") AS "forme_juridique_abregee",
	TRIM("n_voirie") AS "numero_voirie",
	CASE
		WHEN TRIM("indice_de_repetition") IN ('', ',', '*', '-', '.') THEN NULL
		ELSE TRIM("indice_de_repetition") 
		END AS "indice_repetition",
	CAST("code_voie_majic" AS INTEGER) AS "code_voie_majic",
	TRIM("code_voie_rivoli") AS "code_voie_rivoli",
	TRIM("nature_voie") AS "nature_voie",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		"nom_voie", '^''(.*)''$', '\1'), 
		'^''(.*)''$', '\1')) AS "nom_voie",
	contenance AS "contenance_parcelle_centiare",
	TRIM("suf") AS "subdivision_fiscale",
	contenance_1 AS "contenance_subdivision_centiare",
	TRIM(LEFT(TRIM(nature_culture), 2)) AS "nature_culture_code",
	TRIM(
		RIGHT("nature_culture",
		LENGTH(TRIM("nature_culture")) - 4
		)) AS "nature_culture_libelle"
FROM "parcelles_2024"
LEFT JOIN dictionnaire AS cfj ON 
	cfj.code = TRIM("forme_juridique_par") AND 
	cfj.categorie = 'forme_juridique'
LEFT JOIN dictionnaire AS gp ON 
	gp.code = LEFT("groupe_personne_par", 1) AND 
	gp.categorie = 'groupe_pm';

/*	exporte l'ensemble dans une partition HIVE par millésime 
	ça facilite les répimportations en limitant le cache nécessaire */
	
COPY (
SELECT * FROM parcelles_2019_2023_norme
UNION ALL BY NAME
SELECT * FROM parcelles_2024_norme)
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\parcelles_personnes_morales_complet'
(FORMAT parquet, COMPRESSION zstd, PARTITION_BY ("millesime"));