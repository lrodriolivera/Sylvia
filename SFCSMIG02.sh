#************************************************************************************
# SHELL      : SFCSMIG02.sh                                                         *
# DESCRIPCION: Descarga de Tabla  BOPERS_MAE_NAT_BSC, desde el esquema BOPERS       * 
#************************************************************************************

cd ${FACT_HOME}
PROCESO=SFCSMIG02
TABLA=BOPERS_MAE_NAT_BSC
PATH_DAT=/u02/users/deba_sfc/batch/dat/
export TS_FACT_ORACLE_SID=${ORACLE_SID}
export TS_FACT_DB_USER=${DB_USERI}
export TS_FACT_DB_PASS=${DB_PASSI}
export TS_FACT_PATH_DAT=${PATH_DAT}
export TS_FACT_PATH_ADM=${PATH_ADM}
export TS_FACT_FICH_SQL=${PROCESO}
export TS_FACT_FICH_OUT=${PATH_DAT}/SFCSMIG02_MAE_NAT_BSC.txt


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
echo " select trim(to_char(PEMID_NRO_INN_IDE_K,'0000000000'))                                                        || "  >  ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_APL_PAT,' '),30,' ')                                                                       || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_APL_MAT,' '),30,' ')                                                                       || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_NOM_PEL,' '),30,' ')                                                                       || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_NAC,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))          || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_SEX,'00000'),'00000'))                                                             || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_EST_CIV,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_SAD_COY,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_NAD_PEL,'000'),'000'))                                                             || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_PRF_PEL,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_ITT_PRF,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_NIV_EDC,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_NRO_ANO_ETO,'00'),'00'))                                                               || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_IDI_SDO,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_COD_TIP_SDO,'00000'),'00000'))                                                         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_NOM_PRF,' '),20,' ')                                                                       || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_NOM_IPM_TAR,' '),50,' ')                                                                   || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_MTM,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))          || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_FLL ,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))         || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_ING_VID_LAB ,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS')) || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMNB_COD_APP_FIN_ACL,'00000'))                                                                  || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(PEMNB_COD_PRO_FIN_ACL,'00000'))                                                                  || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " RPAD(NVL(PEMNB_GLS_USR_FIN_ACL,' '),15,' ')                                                                   || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_ING_REG ,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))     || "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " trim(to_char(NVL(PEMNB_FCH_FIN_ACL ,TO_DATE('19000101 000001','YYYYMMDD HH24MISS')),'YYYYMMDD HH24MISS'))        "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " as Registro  from BOPERS_MAE_NAT_BSC order by PEMID_NRO_INN_IDE_K                                                "  >> ${PATH_ADM}/fact/${PROCESO}.sql

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

##****************************************************
## PASO 4   validacion de archivo
##****************************************************
          
file=${PATH_DAT}/SFCSMIG01_MAE_IDE.txt
if [ ! -f ${file} ]
then
   FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`
   echo "${PROCESO}: ERROR, En Validacion"                         
   echo "${PROCESO}: ERROR, Archivo de descarga $file no existe"   
   echo "${PROCESO}: Hora Final       : " ${FECUNIX}               
   exit 1
fi
          
#****************************************************
# PASO 5   SYNCSORT
#****************************************************
echo "Borrando archivo proceso previo"
rm -f ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt        2>/dev/null


syncsort                                               \
/INFILE ${PATH_DAT}/SFCSMIG01_MAE_IDE.txt  159         \
/DATADICTIONARY $PATH_CPY/FD-BOPERS-MAE-IDE COBOL      \
/JOINKEYS PEMID_NRO_INN_IDE                            \
/INFILE ${PATH_DAT}/SFCSMIG02_MAE_NAT_BSC.txt 330      \
/DATADICTIONARY $PATH_CPY/FD-BOPERS-MAE-NAT-BSC COBOL  \
/JOINKEYS PEMID_NRO_INN_IDE_K                          \
/OUTFILE ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt       \
/REFORMAT LEFTSIDE : PEMID_GLS_NRO_DCT_IDE_K,          \
                     PEMID_DVR_NRO_DCT_IDE,            \
                     PEMID_NRO_INN_IDE,                \
          RIGHTSIDE: PEMNB_GLS_NOM_PEL,                \
                     PEMNB_GLS_APL_PAT,                \
                     PEMNB_GLS_APL_MAT                 \
/STATISTICS                                            \
/END                                                  

if [ $? != 0 ]
then
   FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`
   echo "${PROCESO}: ERROR, SE ABORTA PROCESO DE SORT"    
   echo "${PROCESO}: Hora Final Sort   : " ${FECUNIX}     
   exit 1
fi

echo "Registros pareados y ubicacion del archivo"
wc -l ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt

#****************************************************
# PASO 6   SYNCSORT para ordenar archivo
#****************************************************

rm -f ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC_ORD.txt 2>/dev/null

syncsort                                                 \
/INFILE ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt 121      \
/DATADICTIONARY $PATH_CPY/FD-UNION-MAE-IDE-BSC COBOL     \
/KEYS  PEMID_GLS_NRO_DCT_IDE_K                           \
/OUTFILE ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC_ORD.txt     \
/STATISTICS                                              \
/END

rm -f ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt                                           2>/dev/null
mv ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC_ORD.txt ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt  2>/dev/null
                                                   
if [ $? != 0 ]                                               
then                                                         
   FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`                       
   echo "${PROCESO}: ERROR, SE ABORTA PROCESO DE SORT"       
   echo "${PROCESO}: Hora Final Sort   : " ${FECUNIX}        
   exit 1                                                    
else      
   FECUNIX=`date +"%Y-%m-%d %H:%M:%S"` 
   echo "${PROCESO}: SE HA ORDENADO ARCHIVO PAREADO POR RUT"       
fi                                                           
                                                   
#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0


