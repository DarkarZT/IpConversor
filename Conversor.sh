#!/bin/bash

# Verificar si se han proporcionado los argumentos necesarios
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Por favor, proporciona una cadena de dirección IP y un número de bits de máscara como argumentos."
    exit 1
fi

# Obtener los argumentos proporcionados
input=$1
bits=$2

# Guardar el valor original de IFS y establecer IFS a '.'
OLD_IFS=$IFS
IFS='.'

# Dividir la cadena en partes usando '.' como delimitador
parts=($input)

# Restaurar el valor original de IFS
IFS=$OLD_IFS

# Inicializar una variable para la cadena resultante
result=""

# Crear una máscara binaria con 1s
mask=$(printf "%0${bits}s" | tr ' ' '1')$(printf "%0$((32 - bits))s" | tr ' ' '0')

# Separar la máscara en grupos de 8 bits con puntos
formatted_mask=$(echo $mask | sed 's/.\{8\}/&./g;s/\.$//')

# Transformar y padear cada parte de la dirección IP
for part in "${parts[@]}"; do
    # Transformar la parte actual
    transformed_part=$(echo "obase=2; $part" | bc)

    # Calcular la longitud de la parte transformada
    length=${#transformed_part}

    # Padear con ceros si es necesario
    if [ $length -lt 8 ]; then
        padded_part=$(printf "%08s" "$transformed_part" | tr ' ' '0')
    else
        padded_part=$transformed_part
    fi

    # Agregar la parte transformada y padeada al resultado
    result+="$padded_part"
done

# Imprimir los resultados
echo "El resultado es: $(echo $result | sed 's/.\{8\}/&./g;s/\.$//')"

# Convertir la máscara binaria a decimal
mask_parts=($(echo $mask | sed 's/.\{8\}/& /g'))
decimal_mask=""
for part in "${mask_parts[@]}"; do
    decimal_part=$(echo "obase=10; ibase=2; $part" | bc)
    decimal_mask+="$decimal_part."
done

# Quitar el punto final sobrante
decimal_mask=${decimal_mask%.}

echo "La Mascara es: $decimal_mask"

# Inicializar una nueva variable para almacenar el Network ID
network_id=""

# Aplicar la máscara a cada bit de la dirección IP
for ((i=0; i<32; i++)); do
    result_char="${result:$i:1}"
    mask_char="${mask:$i:1}"
    if [[ "$result_char" == "1" && "$mask_char" == "1" ]]; then
        network_id+="1"
    else
        network_id+="0"
    fi
done

# Separar el Network ID en grupos de 8 caracteres con puntos
formatted_network_id=$(echo $network_id | sed 's/.\{8\}/&./g;s/\.$//')

# Convertir cada parte del Network ID a decimal
network_id_parts=($(echo $network_id | sed 's/.\{8\}/& /g'))
decimal_network_id=""
for part in "${network_id_parts[@]}"; do
    decimal_part=$(echo "obase=10; ibase=2; $part" | bc)
    decimal_network_id+="$decimal_part."
done

# Quitar el punto final sobrante
decimal_network_id=${decimal_network_id%.}

# Calcular la dirección de broadcast
broadcast_id=""
for ((i=0; i<32; i++)); do
    network_char="${network_id:$i:1}"
    mask_char="${mask:$i:1}"
    if [[ "$mask_char" == "0" ]]; then
        broadcast_id+="1"
    else
        broadcast_id+="$network_char"
    fi
done

# Separar el Broadcast ID en grupos de 8 caracteres con puntos
formatted_broadcast_id=$(echo $broadcast_id | sed 's/.\{8\}/&./g;s/\.$//')

# Convertir cada parte del Broadcast ID a decimal
broadcast_id_parts=($(echo $broadcast_id | sed 's/.\{8\}/& /g'))
decimal_broadcast_id=""
for part in "${broadcast_id_parts[@]}"; do
    decimal_part=$(echo "obase=10; ibase=2; $part" | bc)
    decimal_broadcast_id+="$decimal_part."
done

# Quitar el punto final sobrante
decimal_broadcast_id=${decimal_broadcast_id%.}

# Imprimir los resultados
echo "Network ID es: $decimal_network_id"
echo "Broadcast ID es: $decimal_broadcast_id"

