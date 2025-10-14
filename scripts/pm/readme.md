# Fichiers des locaux et des parcelles des personnes morales

## Pré-requis

Les données sont à télécharger sur [data.gouvfr](https://www.data.gouv.fr/datasets/fichiers-des-locaux-et-des-parcelles-des-personnes-morales/discussions), voici la liste (les noms et le nombre d'archives peuvent varier)

* fichier des locaux (situation 2025).zip
* fichier des parcelles (situation 2025) - dpts 01 à 56.zip
* fichier des parcelles (situation 2025) - dpts 57 à 976.zip

Les possibles changements dans la mise à disposition réduisent la possibilité d'une connexion directe, le recours aux extensions httpfs et zips ont un impact sur les temps de traitements dépassant le temps de téléchargement.

## Ordre d'execution

1. importation_sources.sql, charge dans une base duckdb les 3 types de données (parcelles, locaux et dictionnaire)
2. parcelles_nettoyage_source.sql, nettoye les valeurs et renomme les champs
3. parcelles_ajout_informations.sql, ajoute les codes et libellés contenus dans la documentation PDF, sépare les codes et libellés concaténés
4. parcelles_export.sql, enregistre au format parquet avec une compression zstd

## Suppléments

* parcelles_detection_multipm.sql, permet d'identifier les parcelles liées à plusieurs morales
* parcelles_export_commune.sql
  * permet l'export des parcelles d'une liste de communes
  * ajoute les géométries issues du cadastre/PCI Vecteur d'Etatlab
  * ajoute deux groupes, les *personnes privées* et les *multiples personnes morales*
  
## A faire

Faire un produit avec une gestion structurée des subdivisions.