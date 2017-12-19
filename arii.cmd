echo off
echo =========================
echo    _____        .__/\.__ 
echo   /  _  \_______!__)/!__!
echo  /  /_\  \_  __ \  ! !  !
echo /    !    \  ! \/  ! !  !
echo \____!__  /__!  !__! !__!
echo         \/               
echo =========================
title ARII, portail DevOps

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
set DOWNLOADS=%ROOT%\downloads

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
echo   check               Liste les version des comopsants
echo   install             Installation de symfony 
echo   config              Configuration de Symfony Arii Edition (Schema, Utilisateurs)
echo   update              Mise a jour de Symfony
echo   start               Demarrage Base de donnees + Serveur web
echo   start_supervisor    Demarrage du superviseur
echo   start_scheduler     Demarrage du serveur en mode cluster
echo   start_agent         Demarrage des agents en mode workload
echo   stop                Arret du serveur LAMP
echo   stop_supervisor     Arret du superviseur
echo   stop_scheduler      Arret du serveur en mode cluster
echo   stop_agent          Arret des agents en mode workload
echo   purge               Nettoyage des logs et des caches
echo   assets              Refais les liens avec les images
echo   xml_install         Genere le fichier XML pour l'installation silencieuse
echo   install_supervisor  Installation du jobscheduler Supervisor
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
if %ERRORLEVEL% == 0 pushd %SYMFONY%
goto :install_symfony
goto end

:install_symfony
echo -INSTALL------------------------------------------
php %TOOLS%\composer\composer.phar install
if %ERRORLEVEL% == 0  goto :create_db
popd
goto end 

:create_db
echo -CREATE-DB----------------------------------------
php app/console doctrine:schema:create
if %ERRORLEVEL% == 0 goto :create_users
popd
goto end

:create_users
echo -CREATE-USERS-------------------------------------
php app/console arii:user:create admin admin@localhost admin admin admin
php app/console arii:user:create operator operator@localhost operator operator operator
if %ERRORLEVEL% == 0 goto :assets
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

:assets
echo -ASSETS-------------------------------------------
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
mysqldump -u root --databases arii > >> arii_install.xml %DUMPDIR%\arii.sql
if %ERRORLEVEL% == 0 echo   ARII: %DUMPDIR%\arii.sql
mysqldump -u root --databases scheduler > >> arii_install.xml %DUMPDIR%\scheduler.sql
if %ERRORLEVEL% == 0 echo   SCHEDULER: %DUMPDIR%\scheduler.sql
goto end

:zip
echo -ZIP---------------------------------------------
call :stop
call :stop_supervisor
call :purge
cd ..
7z a -tzip ARII.zip %ROOT%*.* -r -mx9
goto end

:download
echo -DOWNLOAD----------------------------------------
if not exist %DOWNLOADS% mkdir %DOWNLOADS%
pushd %DOWNLOADS%
#curl https://download.sos-berlin.com/JobScheduler.1.10/lts/jobscheduler_windows-x86.1.10.6.zip
curl https://sourceforge.net/projects/jobscheduler/files/JobScheduler.1.10/JobScheduler.1.10.6/jobscheduler_windows-x86.1.10.6.zip
7z x "%DOWNLOADS%\jobscheduler_windows-x86.1.10.6.zip" -o"%DOWNLOADS%\" -r
popd
goto end

:xml_install
pushd %DOWNLOADS%\jobscheduler.1.10.6
echo -SILENT INSTALL----------------------------------
echo ^<?xml version="1.0" encoding="UTF-8" standalone="no"?^> > arii_install.xml
echo ^<AutomatedInstallation langpack="eng"^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="home"^> >> arii_install.xml
echo         ^<userInput/^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="licences"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="licenceOptions" value="GPL"/^> >> arii_install.xml
echo             ^<entry key="licence" value=""/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.HTMLLicencePanel id="gpl_licence"/^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.HTMLLicencePanel id="commercial_licence"/^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.TargetPanel id="target"^> >> arii_install.xml
echo         ^<installpath^>%ROOT%\jobscheduler^</installpath^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.TargetPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserPathPanel id="userpath"^> >> arii_install.xml
echo         ^<UserPathPanelElement^>%ROOT%\jobscheduler^</UserPathPanelElement^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserPathPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.PacksPanel id="package"^> >> arii_install.xml
echo         ^<pack index="0" name="Job Scheduler" selected="true"/^> >> arii_install.xml
echo         ^<pack index="2" name="Database Support" selected="true"/^> >> arii_install.xml
echo         ^<pack index="5" name="Housekeeping Jobs" selected="true"/^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.PacksPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="network"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="schedulerHost" value="localhost"/^> >> arii_install.xml
echo             ^<entry key="schedulerPort" value="44444"/^> >> arii_install.xml
echo             ^<entry key="jettyHTTPPort" value="40444"/^> >> arii_install.xml
echo             ^<entry key="jettyHTTPSPort" value="48444"/^> >> arii_install.xml
echo             ^<entry key="schedulerId" value="arii"/^> >> arii_install.xml
echo             ^<entry key="schedulerAllowedHost" value="localhost"/^> >> arii_install.xml
echo             ^<entry key="launchScheduler" value="yes"/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="cluster"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="clusterOptions" value=""/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="smtp"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="mailServer" value=""/^> >> arii_install.xml
echo             ^<entry key="mailPort" value="25"/^> >> arii_install.xml
echo             ^<entry key="smtpAccount" value=""/^> >> arii_install.xml
echo             ^<entry key="smtpPass" value=""/^> >> arii_install.xml
echo             ^<entry key="mailFrom" value=""/^> >> arii_install.xml
echo             ^<entry key="mailTo" value=""/^> >> arii_install.xml
echo             ^<entry key="mailCc" value=""/^> >> arii_install.xml
echo             ^<entry key="mailBcc" value=""/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="email"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="mailOnError" value="yes"/^> >> arii_install.xml
echo             ^<entry key="mailOnWarning" value="yes"/^> >> arii_install.xml
echo             ^<entry key="mailOnSuccess" value="no"/^> >> arii_install.xml
echo             ^<entry key="jobEvents" value="off"/^> >> arii_install.xml 
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="database"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="databaseDbms" value="mysql"/^> >> arii_install.xml
echo             ^<entry key="databaseCreate" value="on"/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="dbconnection"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="databaseHost" value="%IP%"/^> >> arii_install.xml
echo             ^<entry key="databasePort" value="3306"/^> >> arii_install.xml
echo             ^<entry key="databaseSchema" value="arii"/^> >> arii_install.xml
echo             ^<entry key="databaseUser" value="root"/^> >> arii_install.xml
echo             ^<entry key="databasePassword" value=""/^> >> arii_install.xml                
echo             ^<entry key="connectorJTDS" value="yes"/^> >> arii_install.xml
echo             ^<entry key="connectorMaria" value="yes"/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="jdbc"^> >> arii_install.xml
echo         ^<userInput^> >> arii_install.xml
echo             ^<entry key="connector" value=""/^> >> arii_install.xml
echo             ^<entry key="connectorLicense" value=""/^> >> arii_install.xml
echo         ^</userInput^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.UserInputPanel id="end"^> >> arii_install.xml
echo         ^<userInput/^> >> arii_install.xml
echo     ^</com.izforge.izpack.panels.UserInputPanel^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.InstallPanel id="install"/^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.ProcessPanel id="process"/^> >> arii_install.xml
echo     ^<com.izforge.izpack.panels.FinishPanel id="finish"/^> >> arii_install.xml
echo ^</AutomatedInstallation^> >> arii_install.xml
popd
goto end

:supervisor_install
call :xml_install
pushd %DOWNLOADS%\jobscheduler.1.10.6
"%JRE_HOME%\java.exe" -jar "%~dp0jobscheduler_windows-x86.1.10.6.jar" arii_install.xml
popd
goto end

:end