/* export du produit parcelle PM*/

COPY (SELECT * FROM locaux_pm_dico)
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\locaux_personnes_morales_latest.parquet'
(FORMAT parquet, COMPRESSION zstd);