#!/bin/bash

glpiupdaterconffile="/etc/glpiupdater.conf"
if [[ ! -f $glpiupdaterconffile ]]; then
	whiptail --title "Fichier de configuration" --msgbox "Fichier de configuration absent. Initialisation de la configuration..." 10 60
	touch $glpiupdaterconffile
	mysqluser=$(whiptail --title "Utilisateur" --inputbox "Utilisateur pour la connexion à MySQL :" 10 60 root 3>&1 1>&2 2>&3)
	mysqlpasswd=$(whiptail --title "Mot de passe" --passwordbox "Mot de passe :" 10 60 3>&1 1>&2 2>&3)
	backupdir=$(whiptail --title "Répertoire Backup" --inputbox "Répertoire de sauvegarde :" 10 60 /var/archives/backups 3>&1 1>&2 2>&3)
	glpidirectory=$(whiptail --title "Répertoire GLPI" --inputbox "Répertoire de GLPI :" 10 60 /var/www/html/glpi 3>&1 1>&2 2>&3)
	glpidb=$(whiptail --title "Base de données" --inputbox "Base de données de GLPI :" 10 60 glpidb 3>&1 1>&2 2>&3)
	echo "$mysqluser:$mysqlpasswd:$backupdir:$glpidirectory:$glpidb" > $glpiupdaterconffile
	whiptail --title "Fichier de configuration" --msgbox "Vous pourrez à tout moment modifier la configuration dans le fichier /etc/glpiupdater.conf" 10 60
else
	mysqluser=$(cat $glpiupdaterconffile | cut -d\: -f1)
	mysqlpasswd=$(cat $glpiupdaterconffile | cut -d\: -f2)
	backupdirectory=$(cat $glpiupdaterconffile | cut -d\: -f3)
	glpidir=$(cat $glpiupdaterconffile | cut -d\: -f4)
	glpidatabase=$(cat $glpiupdaterconffile | cut -d\: -f5)
fi

## COLORATION SYNTHAXIQUE ##
RED='\e[0;31m'
GREEN='\033[0;32m'
BLUEDARK='\033[0;34m'
BLUE='\e[0;36m'
YELLOW='\e[0;33m'
BWHITE='\e[1;37m'
NC='\033[0m'
datejour=$(date +%Y%m%d)
dateheure=$(date +%H%M)
glpiurl="https://github.com/glpi-project/glpi/releases/download/$version/glpi-$version.tgz"
glpibackupfile="$backupdirectory/$datejour-glpi.backup.tar.gz"
glpidbbackupfile="$backupdirectory/$datejour-glpi.sql.gzip"
glpibackupsize="$(ls -lh $glpibackupfile | grep "root" | cut -d\  -f5)"
glpidbbackupsize="$(ls -lh $glpidbbackupfile | grep "root" | cut -d\  -f5)"

function pause() {
	echo -e "		${BLUEDARK} ->Appuyez sur une touche pour continuer<-"
	read
}

clear

echo "-------------------"
echo "Script : backup-glpi.sh"
echo "Auteur : Martin Bouillaud"
echo "Date création : 27/07/2017"
echo "Date modification : 28/07/2017"
echo "Alias : backup-glpi"
echo "-------------------"
echo ""
echo -e "${BLUE}########### UPDATE GLPI ############${NC}"
echo -e "${BLUE}----    $(date "+%d-%m-%Y %H:%M:%S")     ----${NC}"
echo -e "${BLUE}------------------------------------${NC}"
echo -e "${YELLOW}## Vérifications des versions ##${NC}"
latestversion=$(curl -s https://github.com/glpi-project/glpi/releases/latest | cut -d\/ -f8 | cut -d\" -f 1)
currentversion=$(cat /root/glpiversion.txt)
echo -e "${BWHITE}Vérification de la version installé ...${NC}"
echo -e "	-> Current version : ${BWHITE}$currentversion${NC}"
echo -e "${BWHITE}Vérification de la dernière version disponible ...${NC}"
echo -e "	-> Dernière version disponible : ${BWHITE}$latestversion ${NC}"
verisonactuelle=$(echo $currentversion | sed s/'\.'/''/g)
nouvelleversion=$(echo $latestversion | sed s/'\.'/''/g)
if [[ $nouvelleversion -gt $verisonactuelle ]]; then
	echo -e "${YELLOW}## Sauvegarde du répertoire ##${NC}"
	echo -e "${BWHITE}Backup de $glpidir vers $glpibackupfile${NC}"

	if [[ -f $glpibackupfile ]]; then
		echo -e " -> Une ancienne sauvegarde existe, suppression en cours..."
		echo -e "${GREEN}	-> Suppression OK !${NC}"
	fi

	echo -e " -> Compression du dossier GLPI en cours..."
	tar cf $glpibackupfile $glpidir >/dev/null 2>&1

	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Backup OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpibackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant la backup !${NC}"
	fi
	echo ""
	echo -e "${YELLOW}## Sauvegarde de la base de données ##${NC}"
	echo -e "${BWHITE}Dump de la base glpidb vers $glpidbbackupfile${NC}"

	if [[ -f $glpidbbackupfile ]]; then
		echo -e " -> Une ancienne sauvegarde existe, suppression en cours..."
		echo -e "${GREEN}	-> Suppression OK !${NC}"
	fi

	echo -e " -> Dump de la base en cours..."
	mysqldump -u$mysqluser -p$mysqlpasswd $glpidatabase | gzip > $glpidbbackupfile
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Dump OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpidbbackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant le dump !${NC}"
	fi
	echo ""

	echo -e "${YELLOW}## Récupération de la dernière version de GLPI ##${NC}"
	latestversion=$(curl -s https://github.com/glpi-project/glpi/releases/latest | cut -d\/ -f8 | cut -d\" -f 1)
	version=$(whiptail --title "Version GLPI" --inputbox "Dernière version disponible :" 10 60 $latestversion 3>&1 1>&2 2>&3)
	glpiurl="https://github.com/glpi-project/glpi/releases/download/$version/glpi-$version.tgz"
	echo -e "${BWHITE}Téléchargement du package vers /tmp${NC}"
	echo -e " -> Téléchargement en cours..."
	wget -q $glpiurl -O "/tmp/glpi.tgz"
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Téléchargement OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpidbbackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant le téléchargement !${NC}"
	fi
	echo ""

	echo -e "${YELLOW}## Installation de la nouvelle version ##${NC}"
	echo -e " -> Extraction des fichiers en cours..."
	tar xzf /tmp/glpi.tgz -C $glpidir --strip-component=1
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Extraction OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpidbbackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant l'extraction !${NC}"
	fi
	echo -e " -> Modification des droits sur les fichiers..."
	find $glpidir -type f -exec chmod 644 {} +
	find $glpidir -type d -exec chmod 755 {} +
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Droits en écriture OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpidbbackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant l'attribution des droits !${NC}"
	fi
	chown www-data:www-data $glpidir -R
	if [[ $? -eq 0 ]]; then
		echo -e "${GREEN}	-> Droits pour www-data OK !${NC}"
		# echo -e "${GREEN}	-> Taille de la backup : $glpidbbackupsize ${NC}"
	else
		echo -e "${RED}	-> Erreur pendant l'attribution des droits !${NC}"
	fi
	echo ""

	echo -e "${YELLOW}## Mise à jour du schéma de la base de données ##${NC}"
	echo -e " -> Veuillez vous connecter à l'interface GLPI pour finaliser la mise à jour"

	pause

	echo -e "${YELLOW}## Résumé ##${NC}"
	echo -e " -> Mise à jour terminée !"
	echo -e " -> Backup BDD et fichiers disponible sous /var/archives/backups"
	echo "$version" > "/root/glpiversion.txt"
	echo -e " -> Mise à jour du fichier de version : OK"
else
	echo ""
	echo -e "${BLUE}------------------------------------${NC}"
	echo -e "${BLUE}####    $(date "+%d-%m-%Y %H:%M:%S")      ###${NC}"
	echo -e "${BLUE}######    NO UPDATE  NEEDED    #####${NC}"
	echo -e "${BLUE}####################################${NC}"
fi
