#!/bin/bash

function get_ring_path {
	find /opt/1C -name "ring" -exec dirname {} \;	
}

function get_lic_file {
	cat $1 | sed $'s/\t/ /g' | tr -s " " | sed $'s/-//g; s/ /;/g'
}

function get_param {
	if [ -z "$2" ]
	then
		echo ""
	else
		RES=$(echo $1 '"'$2'"' | sed -r 's/\r//')
		echo ${RES}
	fi
}

function get_lic_vl {
	echo "$LIC_DATA" | grep "Владелец лицензии" | cut -d":" -f2 | xargs
}

function get_company {
	echo "$LIC_DATA"  | grep "Организация" | cut -d":" -f2 | xargs
	
}

function get_last_name {
	echo "$LIC_DATA" | grep "Фамилия" | cut -d":" -f2 | xargs
}

function get_first_name {
	echo "$LIC_DATA" | grep "Имя" | cut -d":" -f2 | xargs
}

function get_middle_name {
	echo "$LIC_DATA" | grep "Отчество" | cut -d":" -f2 | xargs
}

function get_email {
	echo "$LIC_DATA" | grep "e-mail" | cut -d":" -f2 | xargs
}

function get_country {
	echo "$LIC_DATA" | grep "Страна" | cut -d":" -f2 | xargs | cut -d'|' -f2
}

function get_zip_code {
	echo "$LIC_DATA" | grep "Индекс" | cut -d":" -f2 | xargs
}

function get_region {
	echo "$LIC_DATA" | grep "Регион/область" | cut -d":" -f2 | xargs
}

function get_district {
	echo "$LIC_DATA" | grep "Район" | cut -d":" -f2 | xargs
}

function get_town {
	echo "$LIC_DATA" | grep "Город" | cut -d":" -f2 | xargs
}

function get_street {
	echo "$LIC_DATA" | grep "Улица" | cut -d":" -f2 | xargs
}

function get_house {
	echo "$LIC_DATA" | grep "Дом" | cut -d":" -f2 | xargs
}

function get_building {
	echo "$LIC_DATA" | grep "Корпус" | cut -d":" -f2 | xargs
}

function get_apartment {
	echo "$LIC_DATA" | grep "Квартира, офис" | cut -d":" -f2 | xargs
}

function lic_activate {
	
	SERIAL=$1
	
	PREV_PIN=$(echo "$LIC_LIST" | grep $SERIAL | cut -d"-" -f1)
	
	
	apartment=$(get_param "--apartment " "$(get_apartment)")
	building=$(get_param "--building " "$(get_building)")
	company=$(get_param "--company " "$(get_company)")
	country=$(get_param "--country " "$(get_country)")
	district=$(get_param "--district " "$(get_district)")
	email=$(get_param "--email " "$(get_email)")
	first_name=$(get_param "--first-name " "$(get_first_name)")
	house=$(get_param "--house " "$(get_house)")
	last_name=$(get_param "--last-name " "$(get_last_name)")
	middle_name=$(get_param "--middle-name " "$(get_middle_name)")
	region=$(get_param "--region " "$(get_region)")
	street=$(get_param "--street " "$(get_street)")
	town=$(get_param "--town " "$(get_town)")
	zip_code=$(get_param "--zip-code " "$(get_zip_code)")
	
	LIC_PARAM="$company $email $first_name $last_name $middle_name $country $region $district $town $street $house $building $apartment $zip_code"
	
	SUCCED='успешно активирована'
	
		
	if [ "x$PREV_PIN" == "x" ]
	then
		PIN=$2
		COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --send-statistics false $LIC_PARAM)	
		RES=$(bash -c "$COMMAND")		
		if [[ "$RES" == *$SUCCED* ]]
		then
			echo $RES
			exit			
		fi
		
		PIN=$3
		COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --send-statistics false $LIC_PARAM)	
		RES=$(bash -c "$COMMAND")		
		if [[ "$RES" == *$SUCCED* ]]
		then
			echo $RES
			exit			
		fi
		
		PIN=$4
		COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --send-statistics false $LIC_PARAM)	
		RES=$(bash -c "$COMMAND")		
		if [[ "$RES" == *$SUCCED* ]]
		then
			echo $RES
			exit			
		fi
		
		PIN=$3
		PREV_PIN=$2
		COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --previous-pin $PREV_PIN  --send-statistics false $LIC_PARAM)	
		RES=$(bash -c "$COMMAND")		
		if [[ "$RES" == *$SUCCED* ]]
		then
			echo $RES
			exit			
		fi
		
		PIN=$4
		PREV_PIN=$3
		COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --previous-pin $PREV_PIN  --send-statistics false $LIC_PARAM)	
		RES=$(bash -c "$COMMAND")		
		if [[ "$RES" == *$SUCCED* ]]
		then
			echo $RES
			exit			
		fi
		
	fi
	
	PIN=$2
	COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --previous-pin $PREV_PIN --send-statistics false $LIC_PARAM)	
	RES=$(bash -c "$COMMAND")
	if [[ "$RES" == *$SUCCED* ]]
	then
		echo $RES
		exit			
	fi
	
	PIN=$3
	COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --previous-pin $PREV_PIN --send-statistics false $LIC_PARAM)	
	RES=$(bash -c "$COMMAND")
	if [[ "$RES" == *$SUCCED* ]]
	then
		echo $RES
		exit			
	fi
	
	PIN=$4
	COMMAND=$(echo $RING_PATH/ring license activate --serial $SERIAL --pin $PIN --previous-pin $PREV_PIN --send-statistics false $LIC_PARAM)	
	RES=$(bash -c "$COMMAND")
	if [[ "$RES" == *$SUCCED* ]]
	then
		echo $RES
		exit			
	fi

}

function lic_activate_list {
	DATA=$(get_lic_file $1)
	
	for STR in $DATA
	do
		NUMBER=$(echo $STR | cut -d';' -f1)
		PIN_1=$(echo $STR | cut -d';' -f2)		
		PIN_2=$(echo $STR | cut -d';' -f3)
		PIN_3=$(echo $STR | cut -d';' -f4)
		
		lic_activate $NUMBER $PIN_1 $PIN_2 $PIN_3
		
		exit
	done
}
#************************************************************************************

clear

LIC_FILE=~/license.txt
LIC_DATA=$(cat ~/LicData.txt)

RING_PATH=$(get_ring_path)

LIC_LIST=$($RING_PATH/ring license list 2> /dev/null)


lic_activate_list $LIC_FILE 
 
