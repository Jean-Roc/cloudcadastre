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