#************************************************************************************
# SHELL      : SFCSMIG06.sh                                                         *
# DESCRIPCION: baja tabla T7542350                                                  *
# Justo Loyola Donoso                                                               *
# Fecha : 23/10/2018                                                                *
#************************************************************************************

cd ${FACT_HOME}
PROCESO=SFCSMIG06
TABLA=T7542350
export TS_FACT_ORACLE_SID=${ORACLE_SID}
export TS_FACT_DB_USER=${DB_USERI}
export TS_FACT_DB_PASS=${DB_PASSI}
export TS_FACT_PATH_DAT=${PATH_DAT}
export TS_FACT_PATH_ADM=${PATH_ADM}
export TS_FACT_FICH_SQL=${PROCESO}
export TS_FACT_FICH_OUT=${PATH_DAT}/SFCSMIG06_T7542350.txt


anno=`echo $par|awk '{print substr($0,1,4)}'`
mes=`echo $par|awk '{print substr($0,5,2)}'`
dia=`echo $par|awk '{print substr($0,7,2)}'`
fctm=${anno}${mes}${dia}
fctmYMODATE=${anno}${mes}

#****************************************************
# PASO 1 Query para realizar descarga
#****************************************************
echo ""                                           
echo "$PROCESO.sh: Borrando archivos proceso previo"  
rm -f ${PATH_DAT}${TS_FACT_FICH_OUT}             2>/dev/null 
rm -f ${PROCESO}${PATH_ADM}/fact/${PROCESO}.sql 2>/dev/null 


echo " SELECT                                                       " >   ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CODENTID,' '),8,' ')||                        " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CODPROGR,' '),8,' ')||                        " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CODCUENT,' '),20,' ')||                       " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(NUMMOVIM,0),'000000'))||              " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CODCOM,' '),15,' ')||                         " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(CODSUC,0),'0000000000'))||            " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(FECTRX,0),'00000000'))||              " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CODCAJ,' '),6,' ')||                          " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(NRODOCTO,0),'000000'))||              " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(TIPOTRX,0),'00'))||                   " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(MTOTRX,0),'0000000000'))||            " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       DECODE(SIGN(PUNOBTEN), -1,'-','+')||                   " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(ABS(NVL(PUNOBTEN,0)),'0000000000000'))||  " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(TIPOPAG,0),'00'))||                   " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(CODTRX,0),'0000'))||                  " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       TRIM(TO_CHAR(NVL(INDICADOR,0),'00'))||                 " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CONCONCE,' '),8,' ')||                        " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "       RPAD(NVL(CONCONDI,' '),8,' ')                          " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " as Registro                                                  " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " FROM T7542350                                                " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " ORDER BY CODCUENT                                            " >>  ${PATH_ADM}/fact/${PROCESO}.sql


ls -l ${PATH_ADM}/fact/${PROCESO}.sql

if [ ! -s ${PATH_ADM}/fact/${PROCESO}.sql ]
then
   echo ""
   echo "$PROCESO.sh: ERROR en Descarga TABLA: $TABLA"
   echo ""
   cd ${PATH_CAD}
   exit 1
else
   echo ""
   echo "$PROCESO.sh: Descarga de TABLA: $TABLA OK"  
fi

echo ""
echo "-----------------------------------------------"
date
echo "$PROCESO.sh: Descargando..."
echo "File: ${TS_FACT_FICH_OUT}"
echo ""
FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`
echo "${PROCESO}: Ejecutando SQL via fact para bajar a archivo plano ${TABLA} Hora: ${FECUNIX}"
fact -s -d ${FACT_HOME}/FACT.ini
respuesta=$?
if [ respuesta -ne 0 ]
then
FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`
echo "${PROCESO}: ERROR, En proceso descarga tabla ${TABLA}"
echo "${PROCESO}: ERROR, SE ABORTA PROCESO DE DESCARGA"
echo "${PROCESO}: Hora Final : " ${FECUNIX}
exit 1
fi
#****************************************************
# PASO Verificacion de proceso
#****************************************************

FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`
echo "${PROCESO}: Procesado SQL via fact terminado descargar tabla: ${TABLA} Hora: ${FECUNIX}"
echo "-----------------------------------------------"
if [ ! -s ${TS_FACT_FICH_OUT} ]
then
   echo ""
   echo "$PROCESO .sh: Archivo vacio o inexistente $TS_FACT_FICH_OUT"
   echo "ATENCION: No hay registros para procesar. Se cancela proceso."
   echo ""
   cd ${PATH_CAD}
   exit 1
fi

echo "$PROCESO.sh: Registros descargados del archivo: $TS_FACT_FICH_OUT"
wc -l ${TS_FACT_FICH_OUT}


#Paso 2, Pareo de Archivos
echo "$PROCESO.sh: Pareo de Archivos, Componente SFCPMIG0601"


export FENTRADA1=${PATH_DAT}/SFCSMIG05_RUTERO_ORD.txt
export FENTRADA2=${PATH_DAT}/SFCSMIG06_T7542350.txt
export FSALIDA1=${PATH_DAT}/SFCSMIG06_TRANSACTIONS.txt
export FSALIDA2=${PATH_DAT}/SFCSMIG06_NOPareodo.txt

cd $PATH_EJE
SFCPMIG0601

if [ $? != 0 ]
then
      echo "$PROCESO.sh: Error Componente SFCPMIG0601"
      exit 1
fi

echo "$PROCESO.sh: Archivos de Entrada  "
wc -l ${FENTRADA1}
wc -l ${FENTRADA2}
echo "$PROCESO.sh: Archivos de Salida   "
wc -l ${FSALIDA1}
wc -l ${FSALIDA2}

#***************************************************************
#     FIN  SCRIPT  SHELL 
#***************************************************************
exit 0

