#************************************************************************************
# SHELL      : SFCSMIG09.sh                                                         *
# DESCRIPCION: Descarga de Tablas BOPERS_MAE_IDE y BOPERS_MAE_NAT_BSC               *
# union por a.PEMID_NRO_INN_IDE = b.PEMID_NRO_INN_IDE_K                             *
#************************************************************************************

cd ${FACT_HOME}
PROCESO=SFCSMIG09
TABLA=MAE_IDE_Y_MAE_NAT_BSC
PATH_DAT=/u02/users/deba_sfc/batch/dat/
export TS_FACT_ORACLE_SID=${ORACLE_SID}
export TS_FACT_DB_USER=${DB_USERI}
export TS_FACT_DB_PASS=${DB_PASSI}
export TS_FACT_PATH_DAT=${PATH_DAT}
export TS_FACT_PATH_ADM=${PATH_ADM}
export TS_FACT_FICH_SQL=${PROCESO}
export TS_FACT_FICH_OUT=${PATH_DAT}SFCSMIG09_MAE_FALLECIDO.txt


anno=`echo $par|awk '{print substr($0,1,4)}'`
mes=`echo $par|awk '{print substr($0,5,2)}'`
dia=`echo $par|awk '{print substr($0,7,2)}'`
fctm=${anno}${mes}${dia}
fctmYMODATE=${anno}${mes}

#****************************************************
# PASO 2 Query para realizar descarga
#****************************************************
echo ""
echo "Borrando archivos proceso previo"
rm -f ${TS_FACT_FICH_OUT}             2>/dev/null
rm -f ${PATH_ADM}/fact/${PROCESO}.sql 2>/dev/null
echo " SELECT TRIM(TO_CHAR(A.PEMID_GLS_NRO_DCT_IDE_K, '00000000'))||                        "  >  ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(A.PEMID_DVR_NRO_DCT_IDE,' '),1,' ')   ||                                    " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " TRIM(TO_CHAR(A.PEMID_NRO_INN_IDE,'0000000000'))||                                    " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " DECODE(B.PEMNB_FCH_FLL, NULL,'               ',                                      " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo "                     TO_CHAR(B.PEMNB_FCH_FLL, 'YYYYMMDD HH24MISS'))                   " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " from BOPERS_MAE_IDE A, BOPERS_MAE_NAT_BSC b                                          " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " where a.PEMID_NRO_INN_IDE = b.PEMID_NRO_INN_IDE_K                                    " >>  ${PATH_ADM}/fact/${PROCESO}.sql
echo " ORDER BY trim(to_char(a.PEMID_GLS_NRO_DCT_IDE_K, '00000000'))                        " >>  ${PATH_ADM}/fact/${PROCESO}.sql

ls -l ${PATH_ADM}/fact/${PROCESO}.sql

if [ ! -s ${PATH_ADM}/fact/${PROCESO}.sql ]
then
   echo ""
   echo "$PROCESO.sh: ERROR en Descarga TABLA: $TABLA"
   echo ""
   cd ${PATH_CAD}
   exit 1
fi



#****************************************************
# PASO 3   EJECUCION PROCESO SQL DE BAJADA DE TABLA
#****************************************************

echo ""
echo "-----------------------------------------------"
date
echo "Descargando..."
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
# PASO 4 Verificacion de proceso
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

echo "Registros descargados del archivo: $TS_FACT_FICH_OUT"
wc -l ${TS_FACT_FICH_OUT}

#****************************************************
# PASO 5   EJECUCION PROGRAMA SFCPMIG0901
#****************************************************

echo "$PROCESO.sh: Pareo de Archivos, Componente SFCPMIG0901"

echo "$PROCESO.sh: archivo de datos solo para desarrollo"

export FENTRADA1=${PATH_DAT}/SFCSMIG05_RUTERO_ORD.txt
export FENTRADA2=${PATH_DAT}/SFCSMIG09_MAE_FALLECIDO.txt
export FSALIDA1=${PATH_DAT}/SFCSMIG09_MIGRADOS.txt
export FSALIDA2=${PATH_DAT}/SFCSMIG09_FALLECIDOS.txt


cd $PATH_EJE
SFCPMIG0901
if [ $? != 0 ]
then
      echo "$PROCESO.sh: Error Componente SFCPMIG0901"
      exit 1
else
      echo "$PROCESO.sh: Ejecucion OK del Componente SFCPMIG0901"
fi



echo "$PROCESO.sh: Archivos de Entrada SFCPMIG0901"
wc -l ${FENTRADA1}
wc -l ${FENTRADA2}
echo "$PROCESO.sh: Archivos de Salida SFCPMIG0901"
wc -l ${FSALIDA1}
wc -l ${FSALIDA2}


#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0
