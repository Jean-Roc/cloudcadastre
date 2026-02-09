# Documentation - Conversion des fichiers DFI (Documents de Filiation Informatisés)

Ce script DuckDB transforme les données brutes des documents de filiation cadastrale en un format structuré exploitable.

## Configuration initiale

Le script configure DuckDB avec 16 GB de mémoire et 125 GB d'espace temporaire, puis définit le chemin des données source.

## Étapes de traitement

**1. Import des données brutes**
Les fichiers CSV sont importés avec 141 colonnes (10 colonnes identifiées + 131 colonnes génériques) en gérant l'union de plusieurs fichiers source.

**2. Import du référentiel**
Les codes nature des documents de filiation sont chargés depuis un fichier Parquet de référence.

**3. Nettoyage des données**
Une vue intermédiaire standardise les codes département (gestion des DOM), convertit les types (nature en SMALLINT, dates au format DATE) et exclut les colonnes anonymisées.

**4. Séparation des cas**
Les enregistrements sont séparés en deux groupes : ceux sans parcelles (extractions du domaine non cadastré) et ceux avec parcelles.

**5. Dépivotage**
Les 131 colonnes de parcelles sont transformées en lignes pour faciliter l'agrégation.

**6. Agrégation**
Deux structures sont créées :
- Une liste simple des références parcellaires complètes
- Une structure hiérarchique (section → liste de numéros de parcelles)

**7. Reconstitution parents/enfants**
Les enregistrements de type 1 (parents) et type 2 (enfants) sont appariés selon leurs identifiants communs, créant des paires avec leurs parcelles respectives.

**8. Export final**
Le résultat est exporté en Parquet avec compression ZSTD, incluant les formats LIST, STRUCT et JSON des parcelles parents et enfants.