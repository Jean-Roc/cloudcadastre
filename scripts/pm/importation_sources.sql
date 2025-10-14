SET VARIABLE data_path = 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\\';
SET VARIABLE millesime = 2025;

/*
pas d'utilisation des extensions httpfs et zipfs
zips a besoin de lire la partie catalogue de l'archive pour chaque csv
la lecture à distance = performance pourrie
*/

-- importation des parcelles

CREATE TABLE parcelles_source AS
SELECT getvariable('millesime') AS "millesime", * 
FROM read_csv(
	getvariable('data_path') || 'fichier des parcelles (situation 2025) - dpts 01 à 56\*.csv', 
	normalize_names=true, 
	union_by_name=true,
	quote='$',
	strict_mode=true,
	types={'forme_juridique_par': 'VARCHAR','groupe_personne_par': 'VARCHAR'})
UNION ALL
SELECT getvariable('millesime') AS "millesime", * 
FROM read_csv(
	getvariable('data_path') || 'fichier des parcelles (situation 2025) - dpts 57 à 976\*.csv', 
	normalize_names=true, 
	union_by_name=true,
	quote='$',
	strict_mode=true,	
	types={'forme_juridique_par': 'VARCHAR','groupe_personne_par': 'VARCHAR'});
	
-- importation des locaux

CREATE TABLE locaux_source AS
SELECT getvariable('millesime') AS "millesime", * 
FROM read_csv(
	getvariable('data_path') || 'fichier des locaux (situation 2025)\*.csv', 
	normalize_names=true, 
	union_by_name=true);
	
-- importation des codes et libellés
CREATE TABLE dictionnaire AS
SELECT * FROM read_parquet(getvariable('data_path') || 'pm_liste_codes.parquet');