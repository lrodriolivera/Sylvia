##########################################################################
# NOMBRE  SHELL: SFCSMIG04.sh                                             #
# DESCRIPCION  : rescata archivo CAMBIO MASIVO DE CATEGORIAS
#                El cual permite cambiar de categoria a cuentas
# Autor: Justo Loyola Donoso
# Fecha: 03-07-2018
##########################################################################
## Lectura archivo de credenciales IP, user, pass
param1=`head -n 1 ${PATH_CAD}/SFCSMIG04.ini | tail -n 1`
param2=`head -n 2 ${PATH_CAD}/SFCSMIG04.ini | tail -n 1`
param3=`head -n 3 ${PATH_CAD}/SFCSMIG04.ini | tail -n 1`
param4=`head -n 4 ${PATH_CAD}/SFCSMIG04.ini | tail -n 1`
param5=`head -n 5 ${PATH_CAD}/SFCSMIG04.ini | tail -n 1`
SFCSMIG04cfg=${PATH_DATT}/SFCSMIG04.cfg
#########################################################################
## Borra los archivos de entrada anteriores
echo ""
echo "Revision de Archivo "

if [ -f "${PATH_DAT}/SFCSMIG04_RUTERO.txt" ]; then
    echo "Se repalda Archivo"
    fechapro=`date +"%Y%m%d"`
    rm -f ${PATH_DAT}/SFCSMIG04_RUTERO.txt_${fechapro}  2>/dev/null
    mv ${PATH_DAT}/SFCSMIG04_RUTERO.txt ${PATH_DAT}/SFCSMIG04_RUTERO.txt_${fechapro}
    echo 
    echo "Respaldo realizado"
    ls -l ${PATH_DAT}/SFCSMIG04_RUTERO.txt_${fechapro}
    echo 
fi

echo "Chequeo de archivo de parametros "
##  Eliminar Archivo Configuracion FTP
rm -f ${SFCSMIG04cfg} 2>/dev/null

cd ${PATH_DAT}
FECUNIX=`date +"%Y-%m-%d %H:%M:%S"`

echo "open ${param1}                                " >  ${SFCSMIG04cfg}
echo "user ${param2} ${param3}                      " >> ${SFCSMIG04cfg}
echo "cd ${param4}                                  " >> ${SFCSMIG04cfg}
echo "ascii                                         " >> ${SFCSMIG04cfg}
echo "get  ${param5} SFCSMIG04_RUTERO.txt           " >> ${SFCSMIG04cfg}
echo "quit                                          " >> ${SFCSMIG04cfg}

if [ $? != 0 ]
   then
       echo "Error EN GENERACION DE ARCHIVO de parametros para  FTP"
       exit 1
   else
   		echo "Archivo de parametros para FTP - OK"
fi

ls -l ${SFCSMIG04cfg}
#########################################################################
# PASO020: Ejecuta GET de archivos desde casilla conso en  L117P        #
#########################################################################
ftp -n < ${SFCSMIG04cfg}

if [ $? -ne 0 ]
 then
    echo "Error EN FTP de ARCHIVO"
    exit 1
 else
    echo "No hay error EN FTP de ARCHIVO"
fi

echo ""
echo "Archivos rescatados"
ls -l $PATH_DAT/SFCSMIG04_RUTERO.txt

if [ -e $PATH_DAT/SFCSMIG04_RUTERO.txt ]
then
    echo "  "
else
    echo "Archivo no traspasado"
    echo "Error se detiene proceso"
    exit 1
fi
export NUMFILAS=`wc -l ${PATH_DAT}/SFCSMIG04_RUTERO.txt|awk '{ print $1}'`

echo "Resultado operacion:$?"
if [ $? -ne 0 ]
then
   echo "Termino con errores el traspaso"
   exit 1
fi

if [ ${NUMFILAS} -eq "" ]
then
   echo "Error grave, se detiene proceso no trajo archivo"
   echo ""
   echo ""
   exit 1
fi

echo "Cantidad de registros del archivo ==> ${NUMFILAS}"
echo ""
echo ""

#########################################################################
## FIN DEL SCRIPT                                                       #
#########################################################################
exit 0

