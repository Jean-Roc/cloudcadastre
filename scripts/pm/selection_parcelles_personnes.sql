-- selectionner le principal proprio
DESCRIBE "parcelles_pm_dico";

-- détermination du max contenance_subdivision_centiare
WITH
source_max_subdiv AS (
	SELECT
		millesime, code_direction, departement, code_commune, nom_commune, code_insee, section, num_parcelle, prefixe, 
		MAX(contenance_subdivision_centiare)
	FROM "parcelles_pm_dico"
	WHERE code_droit ='P'
	GROUP BY ALL
	), /*17591233 rows*/
	
LIMIT 10;

-- Is multiproprio ?
DROP TABLE parcelles_multimembers;

CREATE TABLE parcelles_multimembers AS
WITH 
source AS (
SELECT DISTINCT "code_insee", "section", "num_parcelle", "prefixe", "num_majic", "num_siren", "code_droit", "groupe_personne_code", "groupe_personne_libelle", "denomination"
FROM "parcelles_pm_dico")

SELECT
	code_insee, section, num_parcelle, 
	prefixe, 
	count(*) AS participants
FROM "source"
GROUP BY ALL
HAVING count(*) > 1;


-- parcelle avec personne unique
SELECT count(*)
FROM "parcelles_pm_dico" AS ppm
LEFT JOIN parcelles_multimembers pmu ON
	ppm."code_insee" = pmu."code_insee" AND
	ppm."section" = pmu."section" AND
	ppm."num_parcelle" = pmu."num_parcelle" AND
	ppm."prefixe" = pmu."prefixe" 
WHERE pmu."code_insee" IS NOT NULL AND ppm."code_insee" = '59350';

-- 20965127 NULL, sans multi personnes
-- 109466 NOT NULL, avec plusieurs personnes morales
-- à LHL 21394 vs 1737



SUMMARIZE source_parcelle;
DESCRIBE source_parcelle;

SELECT COUNT(*) FROM source_parcelle;

SELECT DISTINCT prefixe FROM source_parcelle WHERE "commune" = '59350';

SELECT 
	"commune", "section", "numero",
	CASE WHEN prefixe = '000' THEN NULL ELSE "prefixe" END AS prefixe
FROM source_parcelle 
WHERE "commune" = '59350';