-- jointure des libellés depuis le dictionnaire extrait de la documentation
-- extraction du code et/ou du libellé quand c'est nécessaire
DROP TABLE "parcelles_pm_dico";

CREATE TABLE "parcelles_pm_dico" AS
WITH source AS (
	SELECT
		pmcl."millesime",
		pmcl."code_direction",
		pmcl."departement",
		pmcl."code_commune",
		pmcl."nom_commune",
		pmcl."code_insee",
		pmcl."section",
		pmcl."num_parcelle",
		pmcl."prefixe",
		pmcl."num_majic",
		pmcl."num_siren",
		LEFT("code_droit_libelle", 1) AS "code_droit",
		TRIM(RIGHT("code_droit_libelle",
			LENGTH(pmcl."code_droit_libelle") - 3
			)) AS "code_droit_libelle",
		LEFT(pmcl."groupe_personne", 1) AS "groupe_personne_code",
		CASE 
			WHEN RIGHT(LEFT(pmcl."groupe_personne", 2), 1) = 'A' THEN 'A'
			ELSE NULL
			END "groupe_personne_code_exoneration",
		gp."libelle" AS "groupe_personne_libelle",
		pmcl."denomination",
		pmcl."forme_juridique",
		cfj."libelle" AS "forme_juridique_libelle",
		pmcl."forme_juridique_abregee",
		pmcl."num_de_voirie",
		pmcl."indice_de_repetition",
		pmcl."code_voie_majic",
		pmcl."code_voie_rivoli",
		pmcl."nature_voie",
		pmcl."nom_voie",
		pmcl."contenance_parcelle_centiare",
		pmcl."subdivision_fiscale",
		pmcl."contenance_subdivision_centiare",
			TRIM(LEFT("nature_culture_libelle", 2)) AS "nature_culture_code",
		TRIM(
			RIGHT("nature_culture_libelle",
			LENGTH(pmcl."nature_culture_libelle") - 4
			)) AS "nature_culture_libelle"
	FROM parcelles_pm_cleaned AS pmcl
	LEFT JOIN dictionnaire AS cfj ON cfj.code = pmcl.forme_juridique AND cfj.categorie = 'forme_juridique'
	LEFT JOIN dictionnaire AS gp ON gp.code = LEFT(pmcl."groupe_personne", 1) AND gp.categorie = 'groupe_pm'
	)
	
SELECT DISTINCT * 
FROM source
ORDER BY "code_insee", "section", "num_parcelle", "prefixe";