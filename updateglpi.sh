#!/bin/bash

#################################
## Auteur : Bouillaud Martin   ##
## Date : 08/08/2016    	   ##
## Titre : GLPI Update   	   ##
## Version : 1.0			   ##
#################################
glpi_server="localhost"
glpi_user="user"
glpi_password="password"
glpi_database="db_name"
current_date=$(date +%d-%m-%Y)
glpi_old="glpi_$current_date.old"
rep_server_web="/var/www"
rep_backup="/var/www/$current_date/"
rep_glpi_backup="glpi_$current_date.tar.gz"
rep_files_backup="glpi_files_$current_date.tar.gz"
rep_glpi="/var/www/glpi"
rep_files_glpi="$rep_glpi/files"
database_file="glpi_database_$current_date.sql"

## Création du répertoire temporaire à la date du jour
echo "###################################"
echo "# Script de backup/update de GLPI #"
echo "###################################"
echo "Création du répertoire de sauvegarde du $current_date"
if [ ! -d "$current_date" ]; then
	mkdir $rep_backup
	echo "## Répertoire de sauvegarde créé avec succès."
else
	echo "## Le répertoire de sauvegarde existe déjà."
fi

echo "------"

## Dump de la base SQL GLPIDB
echo "Dump de la base GLPIDB"
if [ ! -f "$rep_backup$database_file" ]; then
	mysqldump -h$glpi_server -u$glpi_user -p$glpi_password $glpi_database > $rep_backup$database_file
	echo "Dump de la base SQL glpidb créé avec succès."
else
	echo "## Le fichier dump SQL existe déjà !"
fi

echo "------"

## Archivage du dossier glpi
echo "Archivage du dossier GLPI"
if [ ! -f "$rep_backup$rep_glpi_backup" ]; then
	tar cjf $rep_backup$rep_glpi_backup $rep_glpi >> /dev/null 2>&1
	echo "## Archive créée avec succès."
else
	echo "## Archive déjà présente pour la même date !"
fi

echo "------"

## Archivage des pièces jointes glpi
echo "Archivage des pièces jointes GLPI"
if [ ! -f "$rep_backup$rep_files_backup" ]; then
	tar cjf $rep_backup$rep_files_backup $rep_files_glpi >> /dev/null 2>&1
	echo "## Archive des pièces jointes créée avec succès."
else
	echo "## Archive des pièces jointes déjà présente."
fi

echo "------"

mv $rep_glpi $rep_backup$glpi_old

echo "------"

## Téléchargement de l'archive de GLPI
echo "Quelle version souhaitez-vous télécharger ? (Ex: 0.90.5)"
read version
if [ ! -f $rep_server_web/glpi-$version.tar.gz ]; then
	echo "## Téléchargement de la version $version"
	wget https://github.com/glpi-project/glpi/releases/download/$version/glpi-$version.tar.gz -P $rep_server_web >> /dev/null 2>&1
fi

echo "------"

## Décompression de l'archive
echo "## Décompression de l'archive..."
tar xzf $rep_server_web/glpi-$version.tar.gz -C $rep_server_web/

echo "------"

## Récupération des pièces jointes
echo "## Récupération des pièces jointes"
cp $rep_backup$glpi_old/files $rep_glpi -R

echo "------"

## Archivage de la version téléchargée
echo "## Archivage de la version $version"
if [ ! -d $rep_server_web/Historique_des_versions ]; then
	mkdir $rep_server_web/Historique_des_versions/
fi
mv $rep_server_web/glpi-$version.tar.gz $rep_server_web/Historique_des_versions/

echo "-------"

## Attribution des droits à l'utilisateur www-data sur le dossier GLPI en récursif
chown www-data:www-data -R $rep_glpi
echo "## Droits modifié pour le répertoire GLPI"

echo "------"


