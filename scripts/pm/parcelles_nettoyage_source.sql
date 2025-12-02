/*
à partir du millésime 2024
nettoye les attributs
convertit le type si nécessaire
*/

CREATE TABLE parcelles_pm_cleaned AS
SELECT
	"millesime",
	"code_direction",
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
	TRIM("code_droit_par") AS "code_droit_libelle",
	TRIM("groupe_personne_par") AS "groupe_personne",
	TRIM(
		REGEXP_REPLACE(
		REGEXP_REPLACE(
		REGEXP_REPLACE("denomination_par", '^''(.*)''$', '\1'),
		'^''(.*)''$', '\1'),
		'^"(.*)"$', '\1'),
		'*-, ') AS "denomination",
	TRIM("forme_juridique_par") AS "forme_juridique",
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
	TRIM(nature_culture) AS "nature_culture_libelle"
FROM parcelles_source;