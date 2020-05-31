#!/bin/bash
#Script contenant la fonction modification, piece maitresse du synchroniseur de fichier 
#1 Nom du fichier 2 Path de l'arbre exploré 3 Path de l'autre arbre 
function modification
{
	file1=`find $2 -type f -name $1`
	fichier1=`ls -l $file1 | grep $1 | sed 's/$file1//'` 
	file2=`find $3 -type f -name $1` #on cherche un fichier avec le nom identique dans l'autre repertoire
	fichier2=`ls -l $file2 | grep $1  | sed 's/$file2//'` 
	file_in_log=`grep $1 ~/.journal | sed 's/$1//'`
	choix='0'
	echo "file1 : $file1"
	echo "file2 : $file2"
	echo "fichier1 : $fichier1"
	echo "fichier2 : $fichier2"
	echo "file in log : $file_in_log"

	if [[ "$fichier2" = '' ]]; then                        #le fichier n'existe pas dans le second arbre
	 	if [[ "$fichier1" = "$file_in_log" ]]; then			#le fichier est déja dans les logs, et de manière identique, c'est donc qu'il a été supprimer dans l'autre arbre, il faut donc le supprimer
	 		rm -f $1
	 		sed -i -e "/$file_in_log/d" ~/.journal #efface les anciens log du fichier
	 		echo 'here 1'
	 	else
	 		nouveau_doss=`find ~ -type f -name $1 | sed 's/'$2'/'$3'/g' | sed 's/\/'$1'//g'`
	 		mkdir $nouveau_doss #si le dossier existe déja sous le même nom, il ne sera pas créer par mkdir
	 		nouveau_fichier=`find ~ -type f -name $1 | sed 's/'$2'/'$3'/g'`
			cp -p $file1 $nouveau_fichier
			sed -i -e "/$file_in_log/d" ~/.journal
			fichier1 >> ~/.journal
			echo 'here 2'
	 	fi
	elif [[ "$file_in_log" = "$fichier1" ]]; then 		#le fichier de l'arbre explore correspond aux logs du fichier dans l'arbre parcouru

		cp -p $file2 $file1
		sed -i -e "/$file_in_log/d" ~/.journal				 #efface les anciens log du fichier
		fichier2 >> ~/.journal   #MAJ du journal avec les données de B 
		echo 'here 3'
	elif [[ "$file_in_log" = "$fichier2" ]]; then		#le fichier de l'arbre explore correspond aux logs du fichier dans l'abre non-parcouru
		cp -p $file1 $file2
		sed -i -e "/$file_in_log/d" ~/.journal				 #efface les anciens log du fichier
		fichier1 >> ~/.journal
		echo 'here 4'
	elif [[ "$fichier1" = "$fichier2" ]]; then				 #Les 2 fichiers sont indentiques, mais ils ne sont pas présent dans le journal
		fichier1 >> ~/.journal
		echo 'here 5'
	else  												#il  a conflit
	 	echo "Il y a conflit entre 2 fichiers tous les 2 modifiés : 1)$file1 2)$file2    Choississez celui que vous voulez conserver :"
	 	while [ "$choix" != "1" ]  && [ "$choix" != "2" ]; 
	 	do
	 		read choix
	 		if [ "$choix" = '1' ];then
				cp -p $file1 $file2
				echo 'here 6'
			elif [[ $choix = '2' ]]
			then
				cp -p $file2 $file1
				echo 'here 7'
			fi
	 	done
	fi
}
modification "fichier3" "DossA" "DossB"
