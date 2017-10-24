echo off
if "%ALLREADY_INIT%"=="1" goto ALLREADY_INIT
echo =========================
echo    _____        .__/\.__ 
echo   /  _  \_______!__)/!__!
echo  /  /_\  \_  __ \  ! !  !
echo /    !    \  ! \/  ! !  !
echo \____!__  /__!  !__! !__!
echo         \/               
echo =========================
title ARI'I, portail DevOps

echo Configuration
echo -------------
set IP=%COMPUTERNAME%
echo   IP:  %IP%
set WEBPORT=80
echo   WEB: %WEBPORT%
set OSJPORT=44444
echo   OSJ: %OSJPORT%

echo Environnement
echo -------------
set ROOT=%~dp0
echo   ROOT:      %ROOT%
set TOOLS=%ROOT%tools
echo   TOOLS:     %TOOLS%
set XAMPP=%ROOT%xampp
echo   XAMPP:     %XAMPP%
set JAVA_HOME=%TOOLS%\jre
echo   JAVA_HOME: %JAVA_HOME%
set JRE_HOME=%TOOLS%\jre\bin
set SYMFONY=%ROOT%symfony
echo   SYMFONY:   %SYMFONY%
set OSJDIR=%ROOT%jobscheduler
echo   OSJDIR:    %OSJDIR%
set TMPDIR=%ROOT%tmp
echo   TMPDIR:    %TMPDIR%
set DUMPDIR=%ROOT%dump
echo   DUMPDIR:   %DUMPDIR%

set PHPDIR=%XAMPP%\php
set PHPBIN=%PHPDIR%\php.exe
SET PHP_PEAR_INSTALL_DIR=%PHPDIR%\pear
rem Alias
SET PHP_PEAR_BIN_DIR=%PHPDIR%
SET PHP_PEAR_PHP_BIN=%PHPBIN%
SET XAMPPPHPDIR=%PHPDIR%

rem Pour la partie configuration apache\bin
set _ROOT=%ROOT:\=/%
set _XAMPP=%XAMPP:\=/%
set _SYMFONY=%SYMFONY:\=/%

rem Lib Perl
set PERL=%XAMPP%\perl
set PERL5LIB=%PERL%\lib:%PERL%\vendor\lib:%PERL%\site\lib
set PPM_DAT=%PERL%\vendor\lib\ppm.xml

rem Probleme de certificat
set CAINFO = "%TOOLS%\curl\cacert.pem"

echo --------------------------------------------------
set PATH=%JAVA_HOME%\bin;%JAVA_HOME%\bin\client;%WINDIR%\system32;%PERL%\bin;%TOOLS%\7z;%TOOLS%\git\cmd;%TOOLS%\curl;%TOOLS%\graphviz\bin;%XAMPP%\php;%XAMPP%\apache\bin;%XAMPP%\mysql\bin

:ALLREADY_INIT
if "%1"=="" goto help
goto %1

:help
echo Options:
echo   check            Liste les version des comopsants
echo   install          Installation de symfony 
echo   config           Configuration de Symfony Arii Edition (Schema, Utilisateurs)
echo   update           Mise a jour de Symfony
echo   start            Demarrage Base de donnees + Serveur web
echo   start_supervisor Demarrage du superviseur
echo   start_scheduler  Demarrage du serveur en mode cluster
echo   start_agent      Demarrage des agents en mode workload
echo   stop             Arret du serveur LAMP
echo   stop_supervisor  Arret du superviseur
echo   stop_scheduler   Arret du serveur en mode cluster
echo   stop_agent       Arret des agents en mode workload
echo   purge            Nettoyage des logs et des caches
echo   assets           Refais les liens avec les images
goto end 

:check
echo CURL
echo ----
curl --version
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo GIT
echo ---
git --version
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo Apache
echo ------
httpd -v
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo PHP
echo ---
php --version
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo Perl
echo ----
perl -v
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo MySQL
echo -----
mysql -V
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo JAVA
echo ----
java -version
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
echo DOT
echo ---
dot -V
if %ERRORLEVEL%==0 echo OK!
echo --------------------------------------------------
goto end

:install
echo -CLONE--------------------------------------------
git clone https://github.com/AriiPortal/symfony-arii-edition symfony
if %ERRORLEVEL% == 0 goto install_symfony
goto end

:install_symfony
echo -INSTALL------------------------------------------
pushd %SYMFONY%
php %TOOLS%\composer\composer.phar install
if %ERRORLEVEL% == 0 goto create_users
popd
goto end

:create_users
echo -CREATE-USERS-------------------------------------
php app/console arii:user:create admin admin@localhost admin admin admin
php app/console arii:user:create operator operator@localhost operator operator operator
popd
goto end

:update
echo -UPDATE-------------------------------------------
pushd %SYMFONY%
git pull
php %TOOLS%\composer\composer.phar update
if %ERRORLEVEL% == 0 goto update_db
popd
goto end

:update_db
echo -UPDATE-DB----------------------------------------
php app/console doctrine:schema:update --force
popd
goto end

:config
echo -CONFIG-------------------------------------------
pushd %SYMFONY%
php app/console doctrine:schema:create
if %ERRORLEVEL% == 0 goto assets
popd
goto end

:assets
echo -ASSETS-------------------------------------------
pushd %SYMFONY%
php app/console assets:install
popd
goto end

:purge
echo -PURGE--------------------------------------------
echo %XAMPP%\apache\logs
del /q /f %XAMPP%\apache\logs\*.*
echo %SYMFONY%\app\logs
del /q /f %SYMFONY%\app\logs\*.*
echo %SYMFONY%\app\cache\dev
if exist %SYMFONY%\app\cache\dev  rd /s /q %SYMFONY%\app\cache\dev
echo %SYMFONY%\app\cache\prod
if exist %SYMFONY%\app\cache\prod rd /s /q %SYMFONY%\app\cache\prod
echo %TMPDIR%
del /s /q /f %TMPDIR%\*.*
echo %OSJDIR%\arii\logs
del /q /f %OSJDIR%\arii\logs\*.*
echo %OSJDIR%\agent1\logs
del /q /f %OSJDIR%\agent1\logs\*.*
echo %OSJDIR%\agent2\logs
del /q /f %OSJDIR%\agent2\logs\*.*
goto end

:start
echo -START--------------------------------------------
start "MariaDB" %XAMPP%\mysql\bin\mysqld.exe --standalone --console
start "APACHE" %XAMPP%\apache\bin\httpd.exe
goto end

:start_supervisor
echo -START-SUPERVISOR---------------------------------
start "SUPERVISOR" %OSJDIR%\arii\bin\jobscheduler debug
goto end

:start_scheduler
echo -START-SCHEDULER----------------------------------
start "PRIMARY" %OSJDIR%\primary\bin\jobscheduler debug
start "BACKUP"  %OSJDIR%\backup\bin\jobscheduler debug
goto end

:start_agent
echo -START-AGENT--------------------------------------
start "AGENT1" %OSJDIR%\agent1\bin\jobscheduler debug
start "AGENT2" %OSJDIR%\agent2\bin\jobscheduler debug
goto end

:stop
echo -STOP---------------------------------------------
mysqladmin -u root shutdown
pv -f -k httpd.exe -q
if exist %XAMPP%\apache\logs\httpd.pid del %XAMPP%\apache\logs\httpd.pid
goto end 

:stop_supervisor
echo -STOP-SUPERVISOR----------------------------------
echo Supervisor ARII
call %OSJDIR%\arii\bin\jobscheduler stop
goto end 

:stop_scheduler
echo -STOP-SCHEDULER-----------------------------------
echo Primary
call %OSJDIR%\primary\bin\jobscheduler stop
echo Backup
call %OSJDIR%\backup\bin\jobscheduler stop
goto end

:stop_agent
echo -STOP-AGENT---------------------------------------
echo Agent 1/2
call %OSJDIR%\agent1\bin\jobscheduler stop
echo Agent 2/2
call %OSJDIR%\agent2\bin\jobscheduler stop
goto end

:status
echo -STATUS-------------------------------------------
mysqladmin.exe -u root status
goto end

:dump
echo -DUMP---------------------------------------------
if not exist %DUMPDIR% mkdir %DUMPDIR%
mysqldump -u root --databases arii > %DUMPDIR%\arii.sql
if %ERRORLEVEL% == 0 echo   ARII: %DUMPDIR%\arii.sql
mysqldump -u root --databases scheduler > %DUMPDIR%\scheduler.sql
if %ERRORLEVEL% == 0 echo   SCHEDULER: %DUMPDIR%\scheduler.sql
goto end

:zip
set ALLREADY_INIT=1
call arii stop
call arii stop_supervisor
call arii purge
echo -ZIP---------------------------------------------
set ALLREADY_INIT=0
cd ..
7z a -tzip ARII.zip %ROOT%*.* -r -mx9
goto end

:download
echo -DOWNLOAD----------------------------------------
php -r "copy('https://git-scm.com/download/win/PortableGit-2.14.1-32-bit.7z.exe', 'PortableGit-2.14.1-32-bit.7z.exe');"



:end