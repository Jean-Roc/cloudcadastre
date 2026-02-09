/*
lancement en local d'une instance duckdb
D:\Users\jrmorreale\Documents\Applications\duckdb.exe D:\Users\jrmorreale\Documents\SIG\DGFIP\filiation\donnees\dfi.duckdb
*/

SET memory_limit = '16GB';
SET max_temp_directory_size = '125GB';
SET VARIABLE data_path = 'D:\\Users\\jrmorreale\\Documents\\SIG\\DGFIP\\filiation\donnees\\';

.timer on

/* 
importation des fichiers CSV extraits des archives zip ou 7z 
les colonnes sont écrites en dur pour éviter le bug duckdb #19724
*/
CREATE OR REPLACE TABLE "import" AS
SELECT *
FROM read_csv(
	getvariable('data_path') || 'source\\*.csv',
	auto_detect=true, 
	header = false, 
	delim = ';', 
	null_padding=true, 
	union_by_name=true,
	parallel=true, 
	strict_mode=false, 
	names = ['code_departement', 'code_commune', 'prefixe_section', 'identifiant', 'nature', 'date_validation', 'nom_geometre', 'numero_geometre', 'numero_lot_analyse', 'type_ligne', 'column011', 'column012', 'column013', 'column014', 'column015', 'column016', 'column017', 'column018', 'column019', 'column020', 'column021', 'column022', 'column023', 'column024', 'column025', 'column026', 'column027', 'column028', 'column029', 'column030', 'column031', 'column032', 'column033', 'column034', 'column035', 'column036', 'column037', 'column038', 'column039', 'column040', 'column041', 'column042', 'column043', 'column044', 'column045', 'column046', 'column047', 'column048', 'column049', 'column050', 'column051', 'column052', 'column053', 'column054', 'column055', 'column056', 'column057', 'column058', 'column059', 'column060', 'column061', 'column062', 'column063', 'column064', 'column065', 'column066', 'column067', 'column068', 'column069', 'column070', 'column071', 'column072', 'column073', 'column074', 'column075', 'column076', 'column077', 'column078', 'column079', 'column080', 'column081', 'column082', 'column083', 'column084', 'column085', 'column086', 'column087', 'column088', 'column089', 'column090', 'column091', 'column092', 'column093', 'column094', 'column095', 'column096', 'column097', 'column098', 'column099', 'column100', 'column101', 'column102', 'column103', 'column104', 'column105', 'column106', 'column107', 'column108', 'column109', 'column110', 'column111', 'column112', 'column113', 'column114', 'column115', 'column116', 'column117', 'column118', 'column119', 'column120', 'column121', 'column122', 'column123', 'column124', 'column125', 'column126', 'column127', 'column128', 'column129', 'column130', 'column131', 'column132', 'column133', 'column134', 'column135', 'column136', 'column137', 'column138', 'column139', 'column140', 'column141']
	);

/* importation des codes natures extraits de la documentation */
CREATE OR REPLACE TABLE "codes_natures" AS
SELECT *
FROM read_parquet(getvariable('data_path') || 'source\\dfi_codes_nature.parquet');

/* 
vue intermédiaire pour 
- transformer les types des colonnes sources vers des types plus adaptés
- écarter les colonnes anonymisées inutilisables
*/

CREATE VIEW "import_nettoyage" AS
SELECT 
	*
	EXCLUDE ("nom_geometre", "numero_geometre", "date_validation", "nature", "code_departement"),
	CASE	
		WHEN "code_departement" IN ('971', '972', '973', '976') THEN "code_departement"
		ELSE LEFT("code_departement", 2)
		END AS "code_departement", 
	"nature"::SMALLINT AS "nature",
	make_date(
		left("date_validation"::text, 4)::int,
		substring("date_validation"::text, 5, 2)::int,
		right("date_validation"::text, 2)::int
		) AS "date_validation" 
FROM "import";

/* 
distingue les parents et enfants sans parcelles quand 
- il y a une extraction du domaine non cadastré
- un passage dans le domaine public non cadastré
"column011" est la 1ère colonne pouvant contenir une référence parcellaire
*/

CREATE OR REPLACE TABLE "parcelles_null" AS
SELECT 
	"code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne", NULL AS "parcelles"
FROM "import_nettoyage"
WHERE "column011" IS NULL;

/* distingue les parents et enfants avec des parcelles des deux côtés */
CREATE OR REPLACE TABLE "parcelles_not_null" AS
SELECT *
FROM "import_nettoyage"
WHERE "column011" IS NOT NULL;

/* unpivot pour passer de N colonnes à 11 fixes */
CREATE TABLE "parcelles_unpivot" AS
UNPIVOT parcelles_not_null
	ON COLUMNS(* EXCLUDE ("code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne")
	)
INTO
    NAME col_num
    VALUE parcelles;
	
/* 
agrégation des parcelles avec une liste simple et un STRUC d'un même type_ligne et numero_lot_analyse
pas besoin d'un order by dans la clause list() car les numéros sont ordonnés dans la source
*/

/* agrége les chaînes varchar des parcelles dans une liste */
CREATE OR REPLACE TABLE "agregation_parcelles_listes" AS
SELECT 
	* EXCLUDE ("parcelles", "col_num"),
	list(TRIM("parcelles")) AS parcelles_list,
FROM "parcelles_unpivot"
GROUP BY "code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne";

CREATE OR REPLACE TABLE "agregation_parcelles_struct" AS
WITH 
/* récupère les données dépivotées */
source AS (
	SELECT *
	FROM "parcelles_unpivot"	
	),	
/* sépare les segments sections et numéros de parcelles des chaînes varchar */
substring_to_section_parcelle AS (
	SELECT 
		* EXCLUDE ("parcelles", "col_num"),
		TRIM(LEFT("parcelles", 2)) AS "section", 
		RIGHT("parcelles", 4)::smallint AS "parcelle_isolée"
	FROM "source"
	),
/* regroupe dans une LIST les parcelles ayant la même section */
group_by_section AS (
	SELECT 
		* EXCLUDE ("parcelle_isolée"),
		list("parcelle_isolée") AS parcelles_list,
	FROM substring_to_section_parcelle
	GROUP BY "code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne", "section"
	)
/* regroupe dans un STRUCT pour un même lot les sections et parcelles associées*/
SELECT 
	* EXCLUDE ("section", "parcelles_list"),
	LIST(struct_pack(section := "section", parcelles := "parcelles_list")) AS parcelles_struct
FROM group_by_section
GROUP BY "code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne";

CREATE OR REPLACE VIEW "agregation_union" AS
SELECT sl."code_departement", sl."code_commune", sl."prefixe_section", sl."identifiant", sl."nature", sl."date_validation", sl."numero_lot_analyse", sl."type_ligne", sl.parcelles_list, gps.parcelles_struct 
FROM agregation_parcelles_listes AS sl
JOIN agregation_parcelles_struct AS gps USING ("code_departement", "code_commune", "prefixe_section", "identifiant", "nature", "date_validation", "numero_lot_analyse", "type_ligne");

/* jointure des deux produits dépivotés et réaggrégés */
CREATE OR REPLACE TABLE "parents_enfants" AS
WITH
/* rassemble les paires parents/enfants aggrégés et les parcelles */
source AS (
	SELECT 
		* EXCLUDE(parcelles), 
		NULL AS "parcelles_list", NULL AS "parcelles_struct"
	FROM parcelles_null
	UNION ALL
	SELECT *
	FROM agregation_union
	),
parents AS (
	SELECT * EXCLUDE("type_ligne")
	FROM source
	WHERE "type_ligne" = 1
	),
enfants AS (
	SELECT * EXCLUDE("type_ligne")
	FROM source
	WHERE "type_ligne" = 2
	),
appariement AS (
	SELECT 
		pa."code_departement", pa."code_commune", pa."prefixe_section", pa."identifiant", 
		pa."nature", pa."date_validation", pa."numero_lot_analyse",
		pa."parcelles_list" AS parcelles_parents_list,
		pa."parcelles_struct" AS parcelles_parents_struct,
		ef."parcelles_list" AS parcelles_enfants_list,
		ef."parcelles_struct" AS parcelles_enfants_struct
	FROM parents AS pa
	FULL JOIN enfants AS ef 
		USING ("code_departement", "code_commune", "prefixe_section", "identifiant",  "date_validation", "numero_lot_analyse")
	)

SELECT 
	"code_departement", "code_commune", "prefixe_section", 
	"identifiant", "nature" AS "nature_code", cn."nom_nature_dfi" AS "nature_nom",
	"date_validation", "numero_lot_analyse",
	"parcelles_parents_list", "parcelles_parents_struct", "parcelles_enfants_list", "parcelles_enfants_struct"
FROM appariement AS ap
JOIN "codes_natures" AS cn ON cn."code_nature_dfi" = ap."nature"
ORDER BY "code_departement", "code_commune", "date_validation", "identifiant", "numero_lot_analyse";

/* export final */
COPY (
	SELECT
		"code_departement",
		"code_commune",
		"prefixe_section",
		"identifiant",
		"nature_code",
		"nature_nom",
		"date_validation",
		"numero_lot_analyse",
		"parcelles_parents_list",
		"parcelles_parents_struct",
		"parcelles_parents_struct"::JSON AS "parcelles_parents_json",
		"parcelles_enfants_list",
		"parcelles_enfants_struct",
		"parcelles_enfants_struct"::JSON AS "parcelles_enfants_json"
	FROM "parents_enfants"
	ORDER BY "code_departement", "code_commune", "date_validation")
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\filiation\donnees\parcelles_documents_filiation_informatises_json.parquet' (FORMAT parquet, COMPRESSION zstd);
