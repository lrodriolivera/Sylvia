        IDENTIFICATION DIVISION.
        PROGRAM-ID. SFCPMIG0601 .
        AUTHOR.     JUSTO LOYOLA DONOSO.
      * Componente que se utiliza para el pareo tabla T7542350 y Archivo Rutero
      * Para el sistema Loyalty
      * Fecha : 23-10-2018
      * COMPILAR-LINK : cobol.sh SFCPMIG0601
      *---------------------------------------------------------------*
      *             E N V I R O N M E N T   D I V I S I O N           *
      *             =======================================           *
      *---------------------------------------------------------------*

       ENVIRONMENT DIVISION.
      *--------------------.

       CONFIGURATION SECTION.
      *---------------------.

       SPECIAL-NAMES.
               DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
      *--------------------.
       FILE-CONTROL.

                SELECT ENTRADA1 ASSIGN TO EXTERNAL FENTRADA1
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT ENTRADA2 ASSIGN TO EXTERNAL FENTRADA2
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT SALIDA1 ASSIGN TO EXTERNAL FSALIDA1
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT SALIDA2 ASSIGN TO EXTERNAL FSALIDA2
                       ORGANIZATION LINE SEQUENTIAL.

      *---------------------------------------------------------------*
      *                    D A T A   D I V I S I O N                  *
      *                    =========================                  *
      *---------------------------------------------------------------*

       DATA DIVISION.
      *-------------.

       FILE SECTION.
      *------------.


       FD ENTRADA1
           RECORDING MODE IS F
           BLOCK 0
           RECORD CONTAINS   18 CHARACTERS
           LABEL RECORD IS STANDARD.

       01  REG-ENTRADA1 .
           copy COPY_RUTERO_ORD .

       FD ENTRADA2
          RECORDING MODE IS F
          BLOCK 0
          RECORD CONTAINS 218 CHARACTERS
          LABEL RECORDS STANDARD.

       01 REG-ENTRADA2 .
          COPY COPY_T7542350 .

       FD SALIDA1
          RECORDING MODE IS F
          RECORD CONTAINS 547 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA1 .
           COPY COPY_TRANSACTIONS .

       FD SALIDA2
          RECORDING MODE IS F
          RECORD CONTAINS 16 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA2 .
           COPY COPY_RUTERO_NOPAREADO .

       WORKING-STORAGE SECTION.
      *-----------------------.

        01 WS-RARAS.
           05 WS-STATUS                         PIC X(02) .
           05 WS-FIN-1                          PIC 9(01) VALUE ZEROS .
           05 WS-FIN-2                          PIC 9(01) VALUE ZEROS .
           05 WS-C-ENT-1                        PIC 9(12) VALUE ZEROS .
           05 WS-C-ENT-2                        PIC 9(12) VALUE ZEROS .
           05 WS-C-SAL-1                        PIC 9(12) VALUE ZEROS .
           05 WS-C-SAL-2                        PIC 9(12) VALUE ZEROS .
           05 WS-FECHA .
              10 WS-FAA                         PIC X(04) .
              10 WS-FMM                         PIC X(02) .
              10 WS-FDD                         PIC X(02) .
           05 WS-REGCONT                        PIC x(12) .

           05 WS-CONCONCE                       pic x(08) .
              88 88-PG VALUE
              "00000009", "00000010", "00000018", "00000100", "00000101",
              "00000127", "00000128", "00000129", "00000130", "00000501",
              "00000502", "00000503", "00000504", "00000505", "00000506",
              "00000507" .

        05 WS-NUMERO                            PIC X(15) .
        05 WS-NUMERO-R REDEFINES WS-NUMERO.
           10 WS-NUMERO1                        PIC X(03) .
           10 WS-NUMERO-SEP01                   PIC X(01) .
           10 WS-NUMERO2                        PIC X(03) .
           10 WS-NUMERO-SEP02                   PIC X(01) .
           10 WS-NUMERO3                        PIC X(03) .
           10 WS-NUMERO-SEP03                   PIC X(01) .
           10 WS-NUMERO4                        PIC X(03) .
           10 WS-NUMERO-SEP04                   PIC X(01) .


        01 WS-SFCUENT .
           COPY SFCUENT .

        PROCEDURE DIVISION .

        MAIN-SEC SECTION.
        PP-MAIN.
                PERFORM 100000-INICIO
                PERFORM 200000-PROCESO 
                   UNTIL WS-FIN-1 = 1 or WS-FIN-2 = 1
                IF WS-FIN-1 = ZEROS
                   PERFORM GENERA-NOPAREADOS UNTIL WS-FIN-1 = 1
                END-IF
                PERFORM 300000-FINAL.
                MOVE ZEROS                 TO RETURN-CODE
                STOP RUN .

        100000-INICIO .
                OPEN INPUT ENTRADA1 .
                PERFORM LEE-01
                IF WS-FIN-1 = 1
                   DISPLAY "ARCHIVO RUTERO SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN INPUT ENTRADA2 .
                PERFORM LEE-02
                IF WS-FIN-2 = 1
                   DISPLAY "ARCHIVO T7542350 SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN OUTPUT SALIDA1 .
                OPEN OUTPUT SALIDA2 .

        200000-PROCESO .
                EVALUATE TRUE
                   WHEN RUTORD-RUT = R2350-RUT
                      PERFORM GRABA-REG01 UNTIL RUTORD-RUT <> R2350-RUT
                                          OR WS-FIN-2 = 1
                      PERFORM LEE-01
                   WHEN RUTORD-RUT < R2350-RUT
                      PERFORM GRABA-REG02
                      PERFORM LEE-01
                   WHEN OTHER
                      PERFORM LEE-02
                END-EVALUATE .

        LEE-01 .
                READ ENTRADA1 AT END MOVE 1     TO WS-FIN-1 .
                IF WS-FIN-1 = ZEROS
                   ADD 1                        TO WS-C-ENT-1
                END-IF .
                IF WS-FIN-1 = 1 OR
                ( RTRA-SEP08 = " " AND RTRA-SEP08 = " " )
                   MOVE 99999999                TO RTRA-RUT
                END-IF .

        LEE-02 .
                READ ENTRADA2 AT END MOVE 1     TO WS-FIN-2 .
                IF WS-FIN-2 = ZEROS
                   ADD 1                        TO WS-C-ENT-2
                ELSE
                   MOVE 99999999                TO R2350-RUT
                END-IF .

        GRABA-REG01 .
                ADD 1                           TO WS-C-SAL-1
                MOVE ";"                        TO RTRA-SEP01
                                                RTRA-SEP02
                                                RTRA-SEP03
                                                RTRA-SEP04
                                                RTRA-SEP05
                                                RTRA-SEP06
                                                RTRA-SEP07
                                                RTRA-SEP08
                                                RTRA-SEP09
                                                RTRA-SEP10
                                                RTRA-SEP11
                                                RTRA-SEP12
                                                RTRA-SEP13
                                                RTRA-SEP14
                                                RTRA-SEP15
                                                RTRA-SEP16
                                                RTRA-SEP17
                                                RTRA-SEP18
                                                RTRA-SEP19
                                                RTRA-SEP20
                                                RTRA-SEP21
                                                RTRA-SEP22
                                                RTRA-SEP23
                                                RTRA-SEP24
                                                RTRA-SEP25
                                                RTRA-SEP26
                                                RTRA-SEP27
                                                RTRA-SEP28
                                                RTRA-SEP29
                                                RTRA-SEP30
                                                RTRA-SEP31
                                                RTRA-SEP32
                                                RTRA-SEP33
                                                RTRA-SEP34
                MOVE R2350-CONCONCE             TO WS-CONCONCE
                MOVE "RPGCL"                    TO RTRA-PROGRAM_NAME
                MOVE SPACES                     TO RTRA-TXN_NUM
                STRING "TRX"                    DELIMITED BY SIZE
                       R2350-RUT                delimited by size
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                                                INTO RTRA-TXN_NUM
                END-STRING
                MOVE SPACES                     TO RTRA-MEM_NUM
                STRING "CL01"                   DELIMITED BY SIZE
                       R2350-RUT DELIMITED BY SIZE
                                                INTO RTRA-MEM_NUM
                END-STRING
                display "R2350-RUT==" R2350-RUT "<<<>>>"
                  "Indicador>>>" R2350-INDICADOR
      *------------BONIFICACION
     
                IF R2350-INDICADOR = 4
                   MOVE "ORA_TXN_ACC"           TO RTRA-TYPE_CODE
                ELSE
                   MOVE "ORA_TXN_RED"           TO RTRA-TYPE_CODE
                END-IF
                MOVE "ORA_ACC_PROD"             TO RTRA-SUB_TYPE_CODE
                MOVE "ORA_TXN_STAT_PROCESSED"   TO RTRA-STATUS_CODE
      *------------BONIFICACION
                IF R2350-INDICADOR = 4
                   MOVE R2350-MTOTRX            TO RTRA-AMT_VAL
                ELSE
                   MOVE ZEROS                   TO RTRA-AMT_VAL
                END-IF
                MOVE R2350-FECTRX               TO RTRA-TXN_DT
                IF 88-PG
                   MOVE "PG"                    TO RTRA-INTERNAL_NAME
                ELSE
                   MOVE "PGC"                   TO RTRA-INTERNAL_NAME
                END-IF .
                MOVE "RIPLEY"                   TO RTRA-ORG_CODE
                MOVE "PENDIENTE"                TO RTRA-ITEM_NUMBER
                                                RTRA-ATT_CHAR010
                                                RTRA-CHANNEL_CODE
                MOVE "CLP"                      TO RTRA-CURCY_CODE
                MOVE "PENDIENTE"                TO RTRA-ATT_CHAR015
                MOVE "CODCOM DESDE T7542340"    TO RTRA-ATT_CHAR019
                MOVE "CODSUC"                   TO RTRA-ATT_CHAR011
                MOVE R2350-NRODOCTO             TO RTRA-ATT_CHAR007
                EVALUATE TRUE
                   WHEN R2350-TIPOPAG = 03
                      MOVE R2350-MTOTRX         TO RTRA-ATT_NUMBER010
                   WHEN R2350-TIPOPAG = 01
                      MOVE R2350-MTOTRX         TO RTRA-ATT_NUMBER011
                   WHEN R2350-TIPOPAG = 13
                      MOVE R2350-MTOTRX         TO RTRA-ATT_NUMBER020
                END-EVALUATE
                MOVE 999999999999               TO RTRA-ATT_NUMBER019
                                                RTRA-ATT_NUMBER018
                                                RTRA-ATT_NUMBER017
                                                RTRA-ATT_NUMBER016
                                                RTRA-ATT_NUMBER012
                                                RTRA-ATT_NUMBER014
                                                RTRA-ATT_NUMBER013
                                                RTRA-ATT_NUMBER021
                                                RTRA-ATT_NUMBER015
                MOVE SPACES                     TO RTRA-ATT_CHAR014
                STRING "TRX"                    DELIMITED BY SIZE
                       R2350-RUT                DELIMITED BY SIZE
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                                                INTO RTRA-ATT_CHAR014
                END-STRING
                MOVE "01-MIGRACION"             TO RTRA-COMMENTS
                MOVE RUTORD-CODPROGR            TO RTRA-CODPROGR
                WRITE REG-SALIDA1 
                END-WRITE .
                PERFORM LEE-02 .

        GRABA-REG02 .
                ADD 1                           TO WS-C-SAL-2
                WRITE REG-SALIDA2 FROM REG-ENTRADA1
                END-WRITE .

        GENERA-NOPAREADOS .
                PERFORM GRABA-REG02
                PERFORM LEE-02 .

        300000-FINAL .
                CLOSE ENTRADA1
                CLOSE ENTRADA2

                IF WS-C-SAL-1 > 0
                   MOVE WS-C-SAL-1              TO WS-REGCONT
                   MOVE SPACES                  TO REG-SALIDA1
                   MOVE FUNCTION CURRENT-DATE   TO WS-FECHA
                   STRING WS-FDD                DELIMITED BY SIZE
                          WS-FMM                DELIMITED BY SIZE
                          WS-FAA                DELIMITED BY SIZE
                          WS-REGCONT            DELIMITED BY SIZE
                                                INTO REG-SALIDA1
                   END-STRING
                   WRITE REG-SALIDA1 END-WRITE
                END-IF 
                CLOSE SALIDA1 .
                CLOSE SALIDA2 .
                display "Registros Leidos 1=" WS-C-ENT-1
                display "Registros Leidos 2=" WS-C-ENT-2
                display "Registros Grabados 1=" WS-C-SAL-1 .
                display "Registros Grabados 2=" WS-C-SAL-2 .

