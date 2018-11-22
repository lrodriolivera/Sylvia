#************************************************************************************
# SHELL      : SFCSMIG01.sh                                                         *
# DESCRIPCION: Descarga de información desde esquema BOPERS, de las tablas          * 
#              BOPERS_MAE_IDE                                                       *
#************************************************************************************

cd ${FACT_HOME}
PROCESO=SFCSMIG01
TABLA=BOPERS_MAE_IDE
export TS_FACT_ORACLE_SID=${ORACLE_SID}
export TS_FACT_DB_USER=${DB_USERI}
export TS_FACT_DB_PASS=${DB_PASSI}
export TS_FACT_PATH_DAT=${PATH_DAT}
export TS_FACT_PATH_ADM=${PATH_ADM}
export TS_FACT_FICH_SQL=${PROCESO}
export TS_FACT_FICH_OUT=${PATH_DAT}/SFCSMIG01_MAE_IDE.txt


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
echo " select trim(to_char(PEMID_COD_PAI_K,'000'))                                                                    || "  >  ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_COD_TIP_DCT_IDE_K,'00000'))                                                                 || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMID_GLS_NRO_DCT_IDE_K,' '),20,' ')                                                                  || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMID_DVR_NRO_DCT_IDE,' '),1,' ')                                                                     || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMID_GLS_SER_DCT_IDE,' '),20,' ')                                                                    || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_NRO_INN_IDE,'0000000000'))                                                                  || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_COD_TIP_PEL,'00000'))                                                                       || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_COD_APP_FIN_ACL,'00000'))                                                                   || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_COD_PRO_FIN_ACL,'00000'))                                                                   || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMID_GLS_USR_FIN_ACL,' '),15,' ')                                                                    || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_FCH_FIN_ACL, 'yyyymmdd hh24miss'))                                                          || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMID_FCH_ING_REG, 'yyyymmdd hh24miss'))                                                          || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMID_FCH_VNC_DCT ,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))      || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMID_COD_EST_DCT,'00000'),'00000'))                                                          || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMID_COD_MOT_EST_DCT,'00000'),'00000'))                                                      || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMID_FCH_COS_VER_DCT, TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))     "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " as Registro  from BOPERS_MAE_IDE                                                                                  "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " where length(PEMID_GLS_NRO_DCT_IDE_K) = 8                                                                         "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " order by PEMID_NRO_INN_IDE                                                                                        "  >> ${PATH_ADM}/fact/${PROCESO}.sql

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

echo "Registros descargados del archivo: $TS_FACT_FICH_OUT"
wc -l ${TS_FACT_FICH_OUT}

#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0

