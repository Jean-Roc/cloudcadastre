-- jointure des libellés depuis le dictionnaire extrait de la documentation
-- extraction du code et/ou du libellé quand c'est nécessaire
CREATE TABLE "parcelles_pm_dico" AS
WITH source AS (
	SELECT
		"millesime",
		"code_direction",
		"departement",
		"code_commune",
		"nom_commune",
		"code_insee",
		"section",
		"numero_parcelle",
		"prefixe",
		"numero_majic",
		"numero_siren",
		LEFT("code_droit_libelle", 1) AS "code_droit",
		TRIM(RIGHT("code_droit_libelle",
			LENGTH("code_droit_libelle") - 3
			)) AS "code_droit_libelle",
		LEFT("groupe_personne", 1) AS "groupe_personne_code",
		CASE 
			WHEN RIGHT(LEFT("groupe_personne", 2), 1) = 'A' THEN 'A'
			ELSE NULL
			END "groupe_personne_code_exoneration",
		gp."libelle" AS "groupe_personne_libelle",
		"denomination",
		"forme_juridique",
		cfj."libelle" AS "forme_juridique_libelle",
		"forme_juridique_abregee",
		"numero_voirie",
		"indice_repetition",
		"code_voie_majic",
		"code_voie_rivoli",
		"nature_voie",
		"nom_voie",
		"contenance_parcelle_centiare",
		"subdivision_fiscale",
		"contenance_subdivision_centiare",
		TRIM(LEFT("nature_culture_libelle", 2)) AS "nature_culture_code",
		TRIM(
			RIGHT("nature_culture_libelle",
			LENGTH(pmcl."nature_culture_libelle") - 4
			)) AS "nature_culture_libelle"
	FROM parcelles_pm_cleaned AS pmcl
	LEFT JOIN dictionnaire AS cfj ON 
		cfj.code = pmcl.forme_juridique AND 
		cfj.categorie = 'forme_juridique'
	LEFT JOIN dictionnaire AS gp ON 
		gp.code = LEFT(pmcl."groupe_personne", 1) AND 
		gp.categorie = 'groupe_pm'
	)

SELECT * 
FROM source
ORDER BY "code_insee", "section", "numero_parcelle", "prefixe";