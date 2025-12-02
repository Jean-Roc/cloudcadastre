/* export du produit parcelle PM*/

COPY (SELECT * FROM parcelles_pm_dico)
TO 'D:\Users\jrmorreale\Documents\SIG\DGFIP\PM\data\parcelles_personnes_morales_latest.parquet'
(FORMAT parquet, COMPRESSION zstd);