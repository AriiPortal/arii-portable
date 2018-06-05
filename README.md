Une version portable Windows permet d'utiliser Arii sur n'importe quelle plateforme Windows.
Une procédure détaillées est présentée sur cette page : http://wiki.sos-paris.com/index.php/Arii_sur_windows_en_15_minutes

La structure de la suivante:
```
 ARII
   Tools
     7z
     composer
     curl
     git
     graphviz
     jre
   xampp
     apache
     mysql
   jobscheduler
     arii
     agent1
     agent2
   symfony
   tmp
   dump
```

# Installation

## Copie de fichier

La version portable consiste à copier les fichiers fournis par SOS-Paris.

## Commandes Arii

On part du principe qu'Arii portable est dans \ARII.
```
cd \ARII
```
puis lancer la commande arii
```
arii

=========================
   _____        .__/\.__
  /  _  \_______!__)/!__!
 /  /_\  \_  __ \  ! !  !
/    !    \  ! \/  ! !  !
\____!__  /__!  !__! !__!
        \/
=========================
Configuration
-------------
IP:  localhost
WEB: 80
OSJ: 44444
Environnement
-------------
ROOT:  C:\ARII\
TOOLS: C:\ARII\tools
XAMPP: C:\ARII\xampp
--------------------------------------------------
Options:
	check            Liste les version des comopsants
	install          Installation de symfony
	config           Configuration de Symfony Arii Edition (Schema, Utilisateurs)
	update           Mise a jour de Symfony
	start            Demarrage Base de donnees + Serveur web
	start_supervisor Demarrage du superviseur
	start_scheduler  Demarrage du serveur en mode cluster
	start_agent      Demarrage des agents en mode workload
	stop             Arret Base de donnees + Serveur web
	stop_supervisor  Arret du superviseur
	stop_scheduler   Arret du serveur en mode cluster
	stop_agent       Arret des agents en mode workload
	purge            Nettoyage des logs et des caches 
```

 ## Vérification
 
 La commande check liste les versions de chaque composant.
```
arii check 

--------------------------------------------------
CURL
----
curl 7.55.1 (i386-pc-win32) libcurl/7.55.1 OpenSSL/1.1.0f zlib/1.2.11 WinIDN libssh2/1.8.0 nghttp2/1.25.0
Release-Date: 2017-08-14
Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp scp sftp smtp smtps telnet tftp
Features: AsynchDNS IDN IPv6 Largefile SSPI Kerberos SPNEGO NTLM SSL libz TLS-SRP HTTP2 HTTPS-proxy
OK!
--------------------------------------------------
GIT
---
git version 2.14.1.windows.1
OK!
--------------------------------------------------
Apache
------
Server version: Apache/2.4.26 (Win32)
Apache Lounge VC11 Server built:   Jun 18 2017 13:03:53
OK!
--------------------------------------------------
PHP
---
PHP 5.6.31 (cli) (built: Jul  5 2017 22:25:43)
Copyright (c) 1997-2016 The PHP Group
Zend Engine v2.6.0, Copyright (c) 1998-2016 Zend Technologies
OK!
--------------------------------------------------
Perl
---- 

This is perl 5, version 16, subversion 3 (v5.16.3) built for MSWin32-x86-multi-thread

Copyright 1987-2012, Larry Wall 

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit. 

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

OK!
--------------------------------------------------
MySQL
-----
mysql  Ver 15.1 Distrib 10.1.25-MariaDB, for Win32 (AMD64)
OK!
--------------------------------------------------
JAVA
----
java version "1.7.0_21"
Java(TM) SE Runtime Environment (build 1.7.0_21-b11)
Java HotSpot(TM) 64-Bit Server VM (build 23.21-b01, mixed mode)
OK!
--------------------------------------------------
DOT
---
dot - graphviz version 2.38.0 (20140413.2041)
OK!
--------------------------------------------------
```

# Utilisation

## Démarrage

Pour démarrer la partie LAMP:
```
arii start
```

## Connexion

## Arrêt

# Maintenance

Quelques commandes pour les situations particulières.

## Purge

La purge supprime tous les fichiers temporaires, elle est nécessaire si:
* l'espace disque manque
* on souhaite déplacer l'arborescence
* on veut créer une nouvelle archive
Il est conseillé de faire un arii stop pour éviter que de nouveaux logs se créent pendant la purge.
```
arii purge

-PURGE--------------------------------------------
C:\arii\xampp\apache\logs
C:\arii\symfony\app\logs
C:\arii\symfony\app\cache\dev
C:\arii\symfony\app\cache\prod
C:\arii\tmp
C:\arii\jobscheduler\arii\logs
C:\arii\jobscheduler\agent1\logs
C:\arii\jobscheduler\agent2\logs
```

## Mise à jour

La mise à jour est exécutée par '''arii update''':

```
arii update 

--------------------------------------------------
-UPDATE-------------------------------------------
Already up-to-date.
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 1 install, 0 updates, 0 removals
- Installing dhtmlx/connector-php (2.2.0): Loading from cache
Generating autoload files
> Incenteev\ParameterHandler\ScriptHandler::buildParameters
Updating the "app/config/parameters.yml" file
> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::buildBootstrap
> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::clearCache 

// Clearing the cache for the dev environment with debug true

[OK] Cache for the "dev" environment (debug=true) was successfully cleared.  

> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::installAssets

Trying to install assets as relative symbolic links.

--------- -------------------------- ------------------
	 Bundle                     Method / Error
--------- -------------------------- ------------------
WARNING   FrameworkBundle            absolute symlink
WARNING   AriiCoreBundle             absolute symlink
WARNING   AriiGraphvizBundle         absolute symlink
WARNING   AriiATSBundle              absolute symlink
WARNING   AriiReportBundle           absolute symlink
WARNING   SensioDistributionBundle   absolute symlink
--------- -------------------------- ------------------

[OK] All assets were successfully installed.

> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::installRequirementsFile
> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::removeSymfonyStandardFiles
> Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::prepareDeploymentTarget

-UPDATE-DB----------------------------------------
Updating database schema...
Database schema updated successfully! "1" queries were executed
```

## Déplacement

Si le répertoire initial est renommé ou si le contenu est déplacé, il est nécessaire de refaire les liens web de symfony avec les bundles. 

La perte d'image sur le portail est caractéristi de ce type de situation. 

Il suffit simplement de lancer un arii assets.

```
arii assets

--------------------------------------------------
-ASSETS-------------------------------------------

Installing assets as hard copies.

---- -------------------------- ----------------
	Bundle                     Method / Error
---- -------------------------- ----------------
OK   FrameworkBundle            copy
OK   AriiCoreBundle             copy
OK   AriiGraphvizBundle         copy
OK   AriiATSBundle              copy
OK   AriiReportBundle           copy
OK   SensioDistributionBundle   copy
---- -------------------------- ----------------

! [NOTE] Some assets were installed via copy. If you make changes to these assets you have to run this command again.

[OK] All assets were successfully installed.
```
Le rafraîchissement du navigateur suffira à retrouver les images.

## Dump

Il est utile de sauvegarder régulièrement ses bases de données en cas de corruption par la commande '''arii dump'''.

Attention! le serveur mysql doit être démarré, si ce n'est pas le cas, il faut le lancer par un '''arii start'''.
```
arii dump

--------------------------------------------------
-DUMP---------------------------------------------
ARII: C:\arii2\dump\arii.sql
SCHEDULER: C:\arii2\dump\scheduler.sql
```

## ZIP

Pour déplacer la clé, il peut être utile de la zipper, '''arii zip''' exécute les actions suivantes:
* Arrêt des serveurs Apache et Mysql
* Arrêt du superviseur
* Purge des fichiers
* Zip du répertoire Arii
```
arii zip

-STOP---------------------------------------------
mysqladmin: connect to server at 'localhost' failed
error: 'Can't connect to MySQL server on 'localhost' (10061 "Unknown error")'
Check that mysqld is running on localhost and that the port is 3306.
You can check this by doing 'telnet localhost 3306'
pv: No matching processes found
-STOP-SUPERVISOR----------------------------------
Supervisor ARII
Error WINSOCK-10061  Socket is not connected - Connection refused [connect] [127.0.0.1:4444]
Shutting down JobScheduler
-PURGE--------------------------------------------
C:\arii2\xampp\apache\logs
C:\arii2\symfony\app\logs
C:\arii2\symfony\app\cache\dev
C:\arii2\symfony\app\cache\prod
C:\arii2\tmp
C:\arii2\jobscheduler\arii\logs
C:\arii2\jobscheduler\agent1\logs
C:\arii2\jobscheduler\agent2\logs
-ZIP---------------------------------------------

7-Zip [32] 16.04 : Copyright (c) 1999-2016 Igor Pavlov : 2016-10-04

Scanning the drive:
274 folders, 48429 files, 1768869962 bytes (1687 MiB)

Creating archive: ARII.zip

Items to compress: 48703


Files read from disk: 48429
Archive size: 826934676 bytes (789 MiB)
Everything is Ok
```
