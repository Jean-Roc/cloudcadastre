SET VARIABLE data_path_previous_locaux = 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\locaux\\';

/* uniformise les structures de données des millésimes 2019-2023 */

CREATE VIEW "locaux_2019_2023" AS
SELECT * FROM read_parquet([
	getvariable('data_path_previous_locaux') || 'locaux_2019.parquet',
	getvariable('data_path_previous_locaux') || 'locaux_2020.parquet',
	getvariable('data_path_previous_locaux') || 'locaux_2021.parquet',
	getvariable('data_path_previous_locaux') || 'locaux_2022.parquet',
	getvariable('data_path_previous_locaux') || 'locaux_2023.parquet']
);

CREATE TABLE "locaux_2019_2023_norme" AS 
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
	TRIM(n_majic_proprietaires_du_local) AS "numero_majic",
	TRIM(n_siren_proprietaires_du_local) AS "numero_siren",
	TRIM(code_droit_proprietaires_du_local) AS "code_droit",
	cdj."libelle" AS "code_droit_libelle",
	TRIM(groupe_personne_proprietaires_du_local) AS "groupe_personne_code",
	gp."libelle" AS "groupe_personne_libelle",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(REGEXP_REPLACE(
		"denomination_proprietaires_du_local", 
		'^''(.*)''$', '\1')	, '^''(.*)''$', '\1')
		, '^"(.*)"$', '\1'), 
		'*-, ') AS "denomination",
	TRIM(forme_juridique_proprietaires_du_local) AS "forme_juridique",
	cfj."libelle" AS "forme_juridique_libelle",
	TRIM(forme_juridique_abregee_proprietaires_du_local) AS "forme_juridique_abregee",
	TRIM("batiment_identification_du_local") AS "batiment",
	TRIM("entree_identification_du_local") AS "entree",
	CAST("niveau_identification_du_local" AS INTEGER) AS "niveau",
	CAST("porte_identification_du_local" AS INTEGER) AS "porte",
	TRIM("n_voirie_adresse_du_local") AS "numero_voirie",
	CASE
		WHEN TRIM("indice_de_repetition_adresse_du_local") IN ('', ',', '*', '-', '.') THEN NULL
		ELSE TRIM("indice_de_repetition_adresse_du_local") 
		END AS "indice_repetition",
	TRIM(code_voie_majic_adresse_du_local) AS "code_voie_majic",
	TRIM(code_voie_rivoli_adresse_du_local) AS "code_voie_rivoli",
	TRIM(nature_voie_adresse_du_local) AS "nature_voie",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		"nom_voie_adresse_du_local", '^''(.*)''$', '\1'), 
		'^''(.*)''$', '\1')) AS "nom_voie"
FROM locaux_2019_2023
LEFT JOIN dictionnaire AS cdj ON 
		cdj."code" = TRIM("forme_juridique_proprietaires_du_local") AND 
		cdj."categorie" = 'codes_droit'
LEFT JOIN dictionnaire AS gp ON 
		gp."code" = TRIM("groupe_personne_proprietaires_du_local") AND 
		gp."categorie" = 'groupe_pm'
LEFT JOIN dictionnaire AS cfj ON 
		cfj."code" = TRIM("forme_juridique_proprietaires_du_local") AND 
		cfj."categorie" = 'forme_juridique';

/* uniformise le millésime 2024 avec celui de 2025 */

CREATE VIEW "locaux_2024" AS
SELECT * FROM read_parquet(getvariable('data_path_previous_locaux') || 'locaux_2024.parquet');

CREATE TABLE "locaux_2024_norme" AS
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
	TRIM("n_majic") AS "numero_majic",
	TRIM("n_siren") AS "numero_siren",
	LEFT(TRIM("code_droit"), 1) AS "code_droit",
	TRIM(RIGHT(TRIM("code_droit"),
		LENGTH(TRIM("code_droit")) - 3
		)) AS "code_droit_libelle",
	LEFT("groupe_personne", 1) AS "groupe_personne_code",
	CASE 
		WHEN RIGHT(LEFT(TRIM("groupe_personne"), 2), 1) = 'A' THEN 'A'
		ELSE NULL
		END "groupe_personne_code_exoneration",
	gp."libelle" AS "groupe_personne_libelle",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		REGEXP_REPLACE("denomination", '^''(.*)''$', '\1'),
		'^''(.*)''$', '\1'),
		'^"(.*)"$', '\1'),
		'*-, ') AS "denomination",
	TRIM("forme_juridique") AS "forme_juridique",
	cfj."libelle" AS "forme_juridique_libelle",
	TRIM("forme_juridique_abregee") AS "forme_juridique_abregee",
	TRIM("batiment") AS "batiment",
	TRIM("entree") AS "entree",
	CAST("niveau" AS INTEGER) AS "niveau",
	CAST("porte" AS INTEGER) AS "porte",
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
		'^''(.*)''$', '\1')) AS "nom_voie"
FROM "locaux_2024"
LEFT JOIN dictionnaire AS cfj ON 
	cfj.code = TRIM("forme_juridique") AND 
	cfj.categorie = 'forme_juridique'
LEFT JOIN dictionnaire AS gp ON 
	gp.code = LEFT("groupe_personne", 1) AND 
	gp.categorie = 'groupe_pm';

/*	exporte l'ensemble dans une partition HIVE par millésime 
	ça facilite les répimportations en limitant le cache nécessaire */
	
COPY (
	SELECT * FROM "locaux_2019_2023_norme"
	UNION ALL BY NAME
	SELECT * FROM "locaux_2024_norme"
	)
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\locaux_personnes_morales_complet'
(FORMAT parquet, COMPRESSION zstd, PARTITION_BY ("millesime"));

COPY (SELECT * FROM locaux_pm_dico) TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\locaux_personnes_morales_complet'
(FORMAT parquet, COMPRESSION zstd, PARTITION_BY ("millesime"), APPEND);