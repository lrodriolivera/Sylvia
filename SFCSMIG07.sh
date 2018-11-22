#************************************************************************************
# SHELL      : SFCSMIG07.sh                                                         *
# DESCRIPCION: Pareo de Archivos para la Generacion de archivo ACURUALS             *
# Justo Loyola Donoso                                                               *
# Fecha : 29/10/2018                                                                *
#************************************************************************************

echo "Pareo de Archivos, Componente SFCPMIG0701"


export FENTRADA1=${PATH_DAT}/SFCSMIG06_TRANSACTIONS.txt
export FENTRADA2=${PATH_DAT}/SFCSMIG06_T7542350.txt
export FSALIDA1=${PATH_DAT}/SFCSMIG07_ACURUALS.txt
export FSALIDA2=${PATH_DAT}/SFCSMIG07_NOPareodo.txt

cd $PATH_EJE
SFCPMIG0701


if [ $? != 0 ]
then
      echo "Error Componente SFCPMIG0701"
      exit 1
fi

echo "Archivo de Entrada"
wc -l ${FENTRADA1}
wc -l ${FENTRADA2}
echo "Reg.Gen.   Ubicacion"
wc -l ${FSALIDA1}
wc -l ${FSALIDA2}

#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0

