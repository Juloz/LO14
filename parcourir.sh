#!/bin/bash


function parcourir {
	if [[ -d $1 ]]; then
		cd $1
		for i in * ; do
			parcourir $i $2 $3 $4
		done
		cd ..
	else
		lien=`pwd`
		comparaison $lien/$1
		echo "$?"
		#if [[ $? -eq 1 ]]; then
		#	modifier $1 $2 $3 $4   #path$1, nom arbre explorer, path arbre explorer, path autre arbre
		#fi
		echo -e " entrer $lien/$1\n "
	fi
}