SET VARIABLE codes_insee = '59350'

INSTALL httpfs;
LOAD httpfs;
INSTALL spatial;
LOAD spatial;

CREATE VIEW "extraction_commune" AS
WITH
/* récupération des géométries parcelles depuis data.gouv */
source_parcelle_geom AS (
	SELECT 
		"commune", "section", "numero",	"prefixe", 
		ST_Area(geometry)::int AS "surface_parcelle",
		ST_ReducePrecision(ST_MakeValid("geometry"), 0.1) AS "geometry"
	FROM read_parquet('https://cadastre.data.gouv.fr/data/etalab-cadastre/2025-04-01/geoparquet/france/cadastre.parquet')
	WHERE 
		"commune" IN getvariable('codes_insee')
		AND type_objet = 'parcelles';
	),
	
/*	réécriture du préfixe pour pouvoir faire une jointure
	entre le PCI '000' et le fichier PM NULL */
source_prefixe_fixed AS (
	SELECT
		ppm."code_insee", ppm."section", ppm."num_parcelle", 
		CASE 
			WHEN ppm."prefixe" IS NULL THEN '000' 
			ELSE ppm."prefixe" 
			END AS "prefixe",
		ppm."code_droit", 
		ppm."groupe_personne_code", 
		ppm."groupe_personne_libelle", 
		ppm."denomination"
	FROM "parcelles_pm_dico" AS ppm
	),
/*	ajoute les parcelles des personnes privées
	en tant que groupe moral */
source_personnes_privees AS (
SELECT DISTINCT
	ppm."code_insee" AS "tri", sp."commune" AS "code_insee", 
	sp."section", sp."numero" AS "num_parcelle", sp."prefixe",
	'PA' AS "code_droit", 'PA' AS "groupe_personne_code", 
	'personnes privées' AS "groupe_personne_libelle", 
	'personnes privées' AS "denomination",
	sp."surface_parcelle", sp.geometry
FROM source_parcelle_geom AS sp
LEFT JOIN "source_prefixe_fixed" AS ppm ON
	ppm."code_insee" = sp."commune" AND
	ppm."section" = sp."section" AND
	ppm."num_parcelle" = sp."numero" AND
	ppm."prefixe" = sp."prefixe"
)

/* sélection des parcelles PM avec une seule personne morale liée*/
SELECT
	ppm."code_insee", ppm."section", ppm."num_parcelle", ppm."prefixe",
	ppm."code_droit", ppm."groupe_personne_code", ppm."groupe_personne_libelle", ppm."denomination",
	sp."surface_parcelle", sp.geometry
FROM "source_prefixe_fixed" AS ppm
LEFT JOIN parcelles_multimembers pmu ON
	ppm."code_insee" = pmu."code_insee" AND
	ppm."section" = pmu."section" AND
	ppm."num_parcelle" = pmu."num_parcelle" AND
	ppm."prefixe" = pmu."prefixe"
JOIN source_parcelle_geom AS sp ON
	ppm."code_insee" = sp."commune" AND
	ppm."section" = sp."section" AND
	ppm."num_parcelle" = sp."numero" AND
	ppm."prefixe" = sp."prefixe"
WHERE 
	pmu."code_insee" IS NULL
	AND ppm."code_insee" IN getvariable('codes_insee')
	
UNION ALL

/*	sélection des parcelles PM avec plusieurs personnes morales liées
	todo : ajouter un champ STRUCT avec les informations de subdivisions */
SELECT DISTINCT
	ppm."code_insee", ppm."section", ppm."num_parcelle", 
	ppm."prefixe",
	'MU' AS "code_droit", 'MU' AS "groupe_personne_code", 'multiples personnes morales' AS "groupe_personne_libelle", 'multiples' AS "denomination",
	sp."surface_parcelle", sp.geometry
FROM "source_prefixe_fixed" AS ppm
LEFT JOIN parcelles_multimembers pmu ON
	ppm."code_insee" = pmu."code_insee" AND
	ppm."section" = pmu."section" AND
	ppm."num_parcelle" = pmu."num_parcelle" AND
	ppm."prefixe" = pmu."prefixe"
JOIN source_parcelle_geom AS sp ON
	ppm."code_insee" = sp."commune" AND
	ppm."section" = sp."section" AND
	ppm."num_parcelle" = sp."numero" AND
	ppm."prefixe" = sp."prefixe"
WHERE 
	pmu."code_insee" IS NOT NULL
	AND ppm."code_insee" IN getvariable('codes_insee')
	
UNION ALL

/* sélection des parcelles liées à des personnes privées */
SELECT DISTINCT
	"code_insee", "section", "num_parcelle", "prefixe",
	"code_droit", "groupe_personne_code", "groupe_personne_libelle", "denomination", "surface_parcelle" , "geometry"
FROM source_personnes privées
WHERE 
	"tri" IS NULL;
	
/* exportation de la sélection dans un fichier parquet */
COPY (SELECT * FROM "extraction_commune")
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\extraction_parcelles_morales_lhl.parquet'
(FORMAT parquet, COMPRESSION zstd);