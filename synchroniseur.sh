#!/bin/bash

function parcourir {
	if [[ -d $1 ]]; then #si c'est un dossier, on rentre dans le dossier
		cd $1
		for i in * ; do #on parcourt tout les variables du dossier en appelant la fonction, c'est notre récursivité
			parcourir $i $2 $3 
		done
		cd ..
	else  #si c'est un fichier, on envoi a a la fonction modification
			modification $1 $2 $3
	fi
}


function modification
{
	file1=`find $2 -type f -name $1`
	fichier1=`ls -l $file1 | grep $1 | sed "s~$file1~$1~" | tr -d " "` 
	file2=`find $3 -type f -name $1` #on cherche un fichier avec le nom identique dans l'autre repertoire
	fichier2=`ls -l $file2 | grep $1  | sed "s~$file2~$1~" | tr -d " "` 
	file_in_log=`grep $1 ~/.journal` 
	choix='0'
	if [ "$fichier1" =  "$fichier2" ] && [ "$fichier1" = "$file_in_log" ]; then 
	elif [[ "$fichier2" = '' ]]; then                        #le fichier n'existe pas dans le second arbre
	 	if [[ "$fichier1" = "$file_in_log" ]]; then			#le fichier est déja dans les logs, et de manière identique, c'est donc qu'il a été supprimer dans l'autre arbre, il faut donc le supprimer
	 		rm -f $file1
	 		sed -i "s+$file_in_log++g" ~/.journal
	 	else
	 		nouveau_doss=`dirname $file1 | sed "s~$2~$3~"`
	 		mkdir -p $nouveau_doss #si le dossier existe déja sous le même nom, il ne sera pas créer par mkdir
	 		nouveau_fichier=`realpath $file1 | sed "s~$2~$3~"`                 
			cp -p $file1 $nouveau_fichier
			echo "$fichier1" >> ~/.journal
	 	fi
	elif [[ "$file_in_log" = "$fichier1" ]]; then 		#le fichier de l'arbre explore correspond aux logs du fichier dans l'arbre parcouru

		cp -p $file2 $file1
		sed -i "s+$file_in_log++g" ~/.journal
		echo "$fichier2" >> ~/.journal
	elif [[ "$file_in_log" = "$fichier2" ]]; then		#le fichier de l'arbre explore correspond aux logs du fichier dans l'abre non-parcouru
		cp -p $file1 $file2
		sed -i "s+$file_in_log++g" ~/.journal
		echo "$fichier1" >> ~/.journal
	elif [[ "$fichier1" = "$fichier2" ]]; then				 #Les 2 fichiers sont indentiques, mais ils ne sont pas présent dans le journal
		echo "$fichier1" >> ~/.journal
	else  												#il  a conflit
	 	echo "Il y a conflit entre 2 fichiers tous les 2 modifiés : 1)$file1 2)$file2"    
	 	echo `diff $file1 $file2`  
	 	echo "Choississez celui que vous voulez conserver :"
	 	while [ "$choix" != "1" ]  && [ "$choix" != "2" ]; 
	 	do
	 		read choix
	 		if [ "$choix" = '1' ];then
				cp -p $file1 $file2
				sed -i "s+$file_in_log++g" ~/.journal
				echo "$fichier1" >> ~/.journal
			elif [[ "$choix" = '2' ]]
			then
				cp -p $file2 $file1
				sed -i "s+$file_in_log++g" ~/.journal
				echo "$fichier2" >> ~/.journal
			fi
	 	done
	
	fi
}



echo "Entrer le nom du premier dossier a syncro"
read DossA
echo "Entrer le nom du deuxieme dossier a syncro"
read DossB
pathA=`find ~ -type d -name $DossA` #créer les path vers les fichiers
pathB=`find ~ -type d -name $DossB`

while [[ -z $pathA ]]; do
	echo "Le premier dossier n'as pas été trouvé, merci de saisir a nouveau votre dossier"
	read DossA
	pathA=`find ~ -type d -name $DossA`
done
echo " Premier dossier trouvé"

while [[ -z $pathB ]]; do
	echo "Le deuxieme dossier n'as pas été trouvé, merci de saisir a nouveau votre dossier"
	read DossB
	pathB=`find ~ -type d -name $DossB`
done
echo " Deuxieme dossier trouvé"

if [[ ! -e ~/.journal ]]; then
	echo -e "Aucun journal de synchronisation trouvé, choissisez  quel dossier synchroniser \n1 pour le premier dossier\n2 pour le deuxieme dossier"
	read choix
	if [[ $choix = 1 ]]; then
		rm -rf $DossB # suppresion et copie/colle
		cp -pr $DossA $DossB
		touch ~/.journal #creation du journal
		echo -e "$(ls -lR $DossA  | grep ^- | tr -d " ")\n" >> ~/.journal #copie les méta données de DossA dans le journal
		echo "Mise a niveau des dossiers et création du journal de synchronisation"
	else 
		rm -rf $DossA
		cp -pr $DossB $DossA
		touch ~/.journal
		echo -e "$(ls -lR $DossB  | grep ^- | tr -d " ")\n" >> ~/.journal #pareil
		echo "Mise a niveau des dossiers et création du journal de synchronisation"
	fi
else
	echo "Le journal existe deja"
	parcourir $pathA $pathA $pathB 
	parcourir $pathB $pathB $pathA 
fi





