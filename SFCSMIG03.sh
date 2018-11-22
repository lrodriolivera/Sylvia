#************************************************************************************
# SHELL      : SFCSMIG03_V2.sh                                                         *
# DESCRIPCION: Descarga de información desde esquema SFC, de la tabla T7542600      * 
#************************************************************************************

cd ${FACT_HOME}
PROCESO=SFCSMIG03
TABLA=T7542600
export TS_FACT_ORACLE_SID=${ORACLE_SID}
export TS_FACT_DB_USER=${DB_USERI}   
export TS_FACT_DB_PASS=${DB_PASSI}
export TS_FACT_PATH_DAT=${PATH_DAT}
export TS_FACT_PATH_ADM=${PATH_ADM}
export TS_FACT_FICH_SQL=${PROCESO}
export TS_FACT_FICH_OUT=${PATH_DAT}/SFCSMIG03_MAE_NAT_BSC.txt


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
echo " select RPAD(NVL(CODCUENT,' '),20,' ') ||     "  >  ${PATH_ADM}/fact/${PROCESO}.sql
echo "        RPAD(NVL(FECHALTA,' '),8,' ')  ||     "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo "        RPAD(NVL(FECHACTI,' '),8,' ')  ||     "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo "        RPAD(NVL(IDCLIENT,' '),20,' ')        "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " as Registro  from T7542600                   "  >> ${PATH_ADM}/fact/${PROCESO}.sql
echo " order by CODCUENT                            "  >> ${PATH_ADM}/fact/${PROCESO}.sql

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
                                                                    
                                                                    
file=${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt                       
if [ ! -f ${file} ]                                                 
then                                                                
   FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`                              
   echo "${PROCESO}: ERROR, En Validacion"                          
   echo "${PROCESO}: ERROR, Archivo de descarga $file no existe"    
   echo "${PROCESO}: Hora Final       : " ${FECUNIX}                
   exit 1                                                           
fi                                                                  
              
echo "Borrando archivo proceso previo"
rm -f ${PATH_DAT}/SFCSMIG03_UNI_2600.txt          2>/dev/null

syncsort                                                 \
/INFILE ${PATH_DAT}/SFCSMIG02_UNION_IDE_BSC.txt 121      \
/DATADICTIONARY $PATH_CPY/FD-UNION-MAE-IDE-BSC COBOL     \
/JOINKEYS PEMID_CUENTA                                   \
/INFILE ${PATH_DAT}/SFCSMIG03_MAE_NAT_BSC.txt 56         \
/DATADICTIONARY $PATH_CPY/FD-EXTRACTO-T7542600 COBOL     \
/JOINKEYS CODCUENT-CTA                                   \
/OUTFILE ${PATH_DAT}/SFCSMIG03_UNI_2600.txt           \
/REFORMAT LEFTSIDE : PEMID_CUENTA,                       \
                     PEMID_DVR_NRO_DCT_IDE,              \
                     PEMID_NRO_INN_IDE,                  \
                     PEMNB_GLS_NOM_PEL,                  \
                     PEMNB_GLS_APL_PAT,                  \
                     PEMNB_GLS_APL_MAT,                  \
          RIGHTSIDE: IDCLIENT,                           \
                     FECHACTI                            \
/STATISTICS                                              \
/END                                                    
                                                               
echo "Registros pareados y ubicacion del archivo"              
wc -l ${PATH_DAT}/SFCSMIG03_UNI_2600.txt               

                                      
#***************************************************************
#     FIN  SCRIPT  SHELL
#***************************************************************
exit 0

