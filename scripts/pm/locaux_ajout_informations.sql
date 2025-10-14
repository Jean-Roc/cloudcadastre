CREATE TABLE "locaux_pm_dico" AS
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
		TRIM(
			RIGHT("code_droit_libelle",
			LENGTH("code_droit_libelle") - 3)
			) AS "code_droit_libelle",
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
		"batiment",
		"entree",
		"niveau",
		"porte",
		"numero_voirie",
		"indice_de_repetition",
		"code_voie_majic",
		"code_voie_rivoli",
		"nature_voie",
		"nom_voie"
	FROM locaux_pm_cleaned
	LEFT JOIN dictionnaire AS cfj ON 
			cfj.code = forme_juridique AND 
			cfj.categorie = 'forme_juridique'
	LEFT JOIN dictionnaire AS gp ON 
		gp.code = LEFT("groupe_personne", 1) AND 
		gp.categorie = 'groupe_pm'
	)

SELECT * 
FROM source
ORDER BY "code_insee", "section", "numero_parcelle", "prefixe", "batiment";