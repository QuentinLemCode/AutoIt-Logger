Librairie Logger
------------------

# Introduction

Cette librairie AutoIt3 permet d'écrire des logs sur un fichier.

Pour l'utiliser dans vos projets, ajoutez cette ligne en haut de votre fichier :

    #include "logger.au3"

Le fichier "Zip.au3" doit être dans le même dossier que la librairie pour que celle-ci fonctionne.

Tout est déjà prêt, il ne reste plus qu'à appeler les fonctions

    LogDebug("texte")
    LogInfo("texte")
    LogWarning("texte")
    LogCritical("texte")

# Fonctionnalités

Listes des fonctionnalités disponibles :

* Plusieurs niveaux de logs (Debug, Info, Warning, Critical)
* Filtrage des logs selon le niveau (Exemple : ne garder que le niveau Critical et Warning en production afin d'alléger les logs)
* Rotations des logs paramètrables (Conserve 30 jours de logs par défaut)
* Compression des logs après x jours (7 jours par défaut)
* Fichiers datés

Les niveaux de logs sont hiérarchiques :

1. NoLog
2. Critical
3. Warning
4. Info
5. Debug
6. All

Par exemple, en choisissant le niveau de log Warning, seul les log de niveau Warning et Critical seront effectivement enregistrés.

Les noms de fichiers sont par défaut sous la forme "log_jj-mm-aaaa.txt"

# Configuration

Fonctions de configurations :

### Changement du niveau de log :

    SetLogLevel($iLogLevel)

Les différents niveaux de logs sont :
* $g_iLogLevelAll
* $g_iLogLevelDebug
* $g_iLogLevelInfo
* $g_iLogLevelWarning
* $g_iLogLevelCritical
* $g_iLogLevelNoLog

Par défaut : $g_iLogLevelAll

------------------

### Changement du repertoire de log :

    SetLogDir($sLogDir)

Permet de configurer le chemin vers le repertoire de log.

Par défaut : *Répertoire du script executé*

**Doit être sous la forme "C:\logs\\"** (ne pas oublier l'antislash à la fin)

------------------

### Changement du délai de rotation des logs

    SetLogRotate($iLogRotate)

Permet de configurer le nombre de jours durant lesquels les logs seront sauvegardés.

Par défaut : 30 jours

0 : Désactiver la rotation

----------------

### Changement du délai de rotation de la compression des logs

    SetLogCompressRotate($iLogCompressRotate)

Permet de configurer après combien de jours il faut compresser les logs

Par défaut : 7 jours

0 : Désactiver la compression des logs

-----------------

###  Changement du préfixe du fichier de log

    SetFilePrefix($sFilePrefix)

Permet de configurer le préfixe du nom de fichier qui sera sauvegardé.

Par défaut : "log"

**Attention : en cas de changement, la rotation ne s'effectuera plus sur les fichiers avec l'ancien préfixe.**

------------------

### Changement de l'extension du fichier de log

    SetFileExtension($sFileExtension)

Permet de configurer l'extension du fichier de log.

Par défaut : "txt"

**Attention : en cas de changement, la rotation ne s'effectuera plus sur les fichiers avec l'ancien préfixe.**



# Utilisation

    LogDebug($sLogValue)
    LogInfo($sLogValue)
    LogWarning($sLogValue)
    LogCritical($sLogValue)

Ces fonctions permettent de logger directement le texte passé en paramètres.

Pour des raisons pratiques, une fonction vous permet de personnaliser le niveau de log :

    LogOther($sLogLevel, $sLogValue, $bForce = False)

La variable $sLogLevel prend une chaîne de caractères qui correspondra au niveau de log écrit dans le fichier.
La variable $sLogValue contient le texte à logguer.

Exemple : l'appel de la fonction 
    
    LogOther("TEST","Fichier présent")

Enregistrera dans le fichier de log une ligne sous cette forme :

    [hh:mm:ss] TEST : fichier présent

Cette fonction n'enregistrera effectivement que si le niveau de log est situé à *$g_iLogLevelAll*, pour outrepasser cette limite et logger quel que soit le niveau configuré, passer le paramètre *$bForce* à *True* 


# Tests unitaires

Quelques tests sont disponibles dans le dossier test pour attester du bon fonctionnement du script.

Pour executer les tests, compiler le script "test-day.au3" afin de générer le fichier "test-day.exe", puis executer le script "unit-test.au3".

Un message d'erreur s'affichera si un test ne s'est pas effectué correctement.

## Bugs ?

Les erreurs émanant du logger seront enregistrés dans les fichiers de log avec le niveau "LOGGER".

En cas de bugs, n'hésitez pas à ouvrir un ticket ;)

