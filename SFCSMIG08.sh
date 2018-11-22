#************************************************************************************
# SHELL      : SFCSMIG08.sh                                                         *
# DESCRIPCION: Pareo de Archivos para la Generacion de archivo REDEMPTIONS          *
# Justo Loyola Donoso                                                               *
# Fecha : 30/10/2018                                                                *
#************************************************************************************

echo "Shel SFCSMIG08.sh Inicio"

echo "Pareo de Archivos, Componente SFCPMIG0801"


export FENTRADA1=${PATH_DAT}/SFCSMIG06_TRANSACTIONS.txt
export FENTRADA2=${PATH_DAT}/SFCSMIG06_T7542350.txt
export FSALIDA1=${PATH_DAT}/SFCSMIG08_REDEMPTIONS.txt
export FSALIDA2=${PATH_DAT}/SFCSMIG08_NOPareodo.txt

cd $PATH_EJE
SFCPMIG0801


if [ $? != 0 ]
then
      echo "Error Componente SFCPMIG0801"
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
echo "Shel SFCSMIG08.sh Final"
exit 0

