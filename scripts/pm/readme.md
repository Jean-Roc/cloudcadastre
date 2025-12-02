# Fichiers des locaux et des parcelles des personnes morales

## Dexcription

Reprise des données DGFIP sur les parcelles et locaux des personnes morales, unifiés dans un seul fichier pour l’entièreté de la France dans un format exploitable sans téléchargement préalable (parquet) avec une normalisation des colonnes pour faciliter l’utilisation.

## Pré-requis

Les données sont à télécharger sur [data.gouvfr](https://www.data.gouv.fr/datasets/fichiers-des-locaux-et-des-parcelles-des-personnes-morales/discussions), voici la liste (les noms et le nombre d'archives peuvent varier)

* fichier des locaux (situation XXXX).zip
* fichier des parcelles (situation XXXX) - dpts 01 à 56.zip
* fichier des parcelles (situation XXXX) - dpts 57 à 976.zip

Les possibles changements dans la mise à disposition réduisent la possibilité d'une connexion directe, le recours aux extensions httpfs et zips ont un impact sur les temps de traitements dépassant le temps de téléchargement.

## Modifications par rapport aux fichiers DGFIP

* uniformise les structures de données entre les millésimes 2019-2023 et 2024-2025
* ajout d'un code insee pour faciliter les filtres et jointures
* noms de champs explicites et homogènes entre les parcelles et locaux
* division en colonnes distinctes des champs concaténants plusieurs informations (code, libellé, code exoneration)
* ajout des libellés uniquement présents dans la documentation
* suppression des espaces blancs en début et fin de ligne
* suppression de résidus de manipulation de chaînes ('mon_texte' ou '' mon_texte '' au lieu de mon_texte
* suppression de résidus de saisies
  * la passe de nettoyage sur les dénominations est faite sur les erreurs les plus fréquentes, je vous encourage à utiliser des fonctions de recherche textuelle (FTS, soundex, tokenization, etc.) et à éviter les ILIKE et CONTAINS
  
## Description des produits

Le fichier *parcelles_personnes_morales_latest.parquet* contient les données basées sur le dernier millésime publié par la DGFIP pour les *parcelles*, idem pour celui sur les locaux.

Les fichiers se terminant par une année (*_2019*.parquet) sont des millésimes antérieurs, tous ont la même structure.

## Ordre d'execution

1. importation_sources.sql, charge dans une base duckdb les 3 types de données (parcelles, locaux et dictionnaire), la variable **data_path** doit pointer vers le répertoire contenant les CSV
2. pour les parcelles
  a. parcelles_nettoyage_source.sql, nettoye les valeurs et renomme les champs
  b. parcelles_ajout_informations.sql, ajoute les codes et libellés contenus dans la documentation PDF, sépare les codes et libellés concaténés
  c. parcelles_export.sql, enregistre au format parquet avec une compression zstd
3. pour les locaux
  a. locaux_nettoyage_source.sql, nettoye les valeurs et renomme les champs
  b. locaux_ajout_informations.sql, ajoute les codes et libellés contenus dans la documentation PDF, sépare les codes et libellés concaténés
  c. locaux_export.sql, enregistre au format parquet avec une compression zstd

## Suppléments

* parcelles_detection_multipm.sql, permet d'identifier les parcelles liées à plusieurs morales
* parcelles_export_commune.sql
  * permet l'export des parcelles d'une liste de communes
  * ajoute les géométries issues du cadastre/PCI Vecteur d'Etatlab
  * ajoute deux groupes, les *personnes privées* et les *multiples personnes morales*

## A faire

Remplacer les préfixes '000' par des NULL
Faire un produit avec une gestion structurée des subdivisions.