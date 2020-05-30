#!/bin/bash
# Fichier contenant la fonction comparaison 
# Compare le fichier parcouru vis à vis du journal, si le fichier parcouru a des métadonnées différentes du journal, c'est que tout n'est pas synchroniser et qu'il faut effectuer des modfications
# Return 0 si aucune modification à faire, return 1 si une modification est a réalisé 
# $1 Fichier parcouru 
function comparaison

{
	
	fichier1=`ls -l $1 | grep $1`
	file_in_log=`grep $1 ~/.journal`
	echo "$fichier1"
	echo "$file_in_log"
	if [[ "fichier1" = "file_in_log"  ]]; then		
		return 0
	else 
		return 1
	fi

}
