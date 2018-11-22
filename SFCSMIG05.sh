#************************************************************************************
# SHELL      : SFCSMIG05.sh                                                         *
# DESCRIPCION: Ejecuta componente cobol que permite parear y generar archivos de    *
#              MEMBER, CONTACTS y NO Pareados(RUTERO)                               *
# Justo Loyola Donoso                                                               *
# Fecha : 25/10/2018                                                                *
#************************************************************************************

PROCESO=SFCSMIG05

export FILEINT=${PATH_DAT}/SFCSMIG04_RUTERO.txt
export FILEOUT=${PATH_DAT}/SFCSMIG05_RUTERO_ORD.txt


if [ -f "${FILEINT}" ]; then
    echo "$PROCESO.sh: Archivo Existe se procede a Ordenar por RUT"
else
    echo "$PROCESO.sh: Archivo no Existe, error grave se detiene proceso"
    exit 1
fi


syncsort                                            \
/INFILE ${FILEINT} 18                               \
/FIELDS RUT               1  CHAR   8,              \
        CODPROGR          9  CHAR  18               \
/KEYS   RUT                                         \
/OUTFILE ${FILEOUT} overwrite                       \
/STATISTICS                                         \
/END

if [ $? != 0 ]
then
   echo "$PROCESO.sh: Error cpsyncsort.sh SFC Ordenar por RUT"
   exit 1
fi


echo "$PROCESO.sh: Reg.Ord. Ubicacion"
wc -l ${FILEOUT}
#exit 0

#Paso 2, Pareo de Archivos
echo "$PROCESO.sh: Pareo de Archivos, Componente SFCPMIG0501"

echo "$PROCESO.sh: archivo de datos solo para desarrollo"

export FENTRADA1=${PATH_DAT}/SFCSMIG05_RUTERO_ORD.txt
export FENTRADA2=${PATH_DAT}/SFCSMIG03_UNI_2600.txt
export FSALIDA1=${PATH_DAT}/SFCSMIG05_MEMBER.csv
export FSALIDA2=${PATH_DAT}/SFCSMIG05_CONTACTS.csv
export FSALIDA3=${PATH_DAT}/SFCSMIG05_NOPAREADO.txt

cd $PATH_EJE
SFCPMIG0501
if [ $? != 0 ]
then
      echo "$PROCESO.sh: Error Componente SFCPMIG0501"
      exit 1
else
      echo "$PROCESO.sh: Ejecucion OK del Componente SFCPMIG0501"
fi



echo "$PROCESO.sh: Archivos de Entrada SFCPMIG0501"
wc -l ${FENTRADA1}
wc -l ${FENTRADA2}
echo "$PROCESO.sh: Archivos de Salida SFCPMIG0501"
wc -l ${FSALIDA1}
wc -l ${FSALIDA2}
wc -l ${FSALIDA3}

#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0

