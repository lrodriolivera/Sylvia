        IDENTIFICATION DIVISION.
        PROGRAM-ID. SFCPMIG0501 .
        AUTHOR.     JUSTO LOYOLA DONOSO.
      * Componente que se utiliza para el pareo Archivo Rutero y la Unificacion
      * T7542600 para generar archivos MEMBER y CONTACTS. Y no Pareados
      * Fecha : 25-10-2018
      * COMPILAR-LINK : cobol.sh SFCPMIG0501
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

                SELECT SALIDA3 ASSIGN TO EXTERNAL FSALIDA3
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
          RECORD CONTAINS 137 CHARACTERS
          LABEL RECORDS STANDARD.

       01 REG-ENTRADA2 .
          COPY COPY_UNI_2600 .

       FD SALIDA1
          RECORDING MODE IS F
          RECORD CONTAINS 236 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA1 .
           COPY COPY_MEMBER .

       FD SALIDA2
          RECORDING MODE IS F
          RECORD CONTAINS 72 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA2 .
           COPY COPY_CONTACTS .

       FD SALIDA3
          RECORDING MODE IS F
          RECORD CONTAINS 18 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA3 .
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
           05 WS-C-SAL-3                        PIC 9(12) VALUE ZEROS .
           05 WS-FECHA .
              10 WS-FAA                         PIC X(04) .
              10 WS-FMM                         PIC X(02) .
              10 WS-FDD                         PIC X(02) .
           05 WS-REGCONT                        PIC x(12) .



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
                   DISPLAY "ARCHIVO T7542600 SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN OUTPUT SALIDA1 .
                OPEN OUTPUT SALIDA2 .
                OPEN OUTPUT SALIDA3 .

        200000-PROCESO .
                EVALUATE TRUE
                   WHEN RUTORD-RUT = RUNIFI-RUT
                      PERFORM GRABA-REG01 UNTIL RUTORD-RUT <> RUNIFI-RUT
                                          OR WS-FIN-2 = 1
                      PERFORM LEE-01
                   WHEN RUTORD-RUT < RUNIFI-RUT
                      PERFORM GRABA-REG02
                      PERFORM LEE-01
                   WHEN OTHER
                      PERFORM LEE-02
                END-EVALUATE .

        LEE-01 .
                READ ENTRADA1 AT END MOVE 1     TO WS-FIN-1 .
                IF WS-FIN-1 = ZEROS
                   ADD 1                        TO WS-C-ENT-1
                IF WS-FIN-1 = 1
                   MOVE 99999999                TO RUTORD-RUT
                END-IF .

        LEE-02 .
                READ ENTRADA2 AT END MOVE 1     TO WS-FIN-2 .
                IF WS-FIN-2 = ZEROS
                   ADD 1                        TO WS-C-ENT-2
                END-IF
                IF WS-FIN-2 = 1
                   MOVE 99999999                TO RUNIFI-RUT
                END-IF .

        GRABA-REG01 .
                ADD 1                           TO WS-C-SAL-1
                MOVE ";"                        TO RMEM-SEP01
                                                RMEM-SEP02
                                                RMEM-SEP03
                                                RMEM-SEP04
                                                RMEM-SEP05
                                                RMEM-SEP06
                                                RMEM-SEP07
                                                RMEM-SEP08
                                                RMEM-SEP09
                                                RMEM-SEP10
                                                RMEM-SEP11
                                                RMEM-SEP12
                                                RMEM-SEP13
                                                RMEM-SEP14
                MOVE "RPGCL"                    TO RMEM-PROGRAM_NAME
                MOVE SPACES                     TO RMEM-MEM_NUM
                STRING "CL01"                   DELIMITED BY SIZE
                       RUNIFI-RUT                DELIMITED BY SIZE
                                                INTO RMEM-MEM_NUM
                END-STRING
                MOVE SPACES                     TO RMEM-NAME
                STRING RUNIFI-PEMNB_GLS_NOM_PEL DELIMITED BY SPACES
                       " "                      DELIMITED BY SIZE
                       RUNIFI-PEMNB_GLS_APL_PAT DELIMITED BY SPACES
                                                INTO RMEM-NAME
                END-STRING
                MOVE "ORA_MEM_TYPE_INDIVIDUAL"  TO RMEM-MEM_TYPE_CODE
                MOVE "ORA_MEM_STATUS_ACTIVE"    TO RMEM-STATUS_CODE
                MOVE SPACES                     TO RMEM-PARTY_NUMBER
                STRING "CL01"                   DELIMITED BY SIZE
                RUNIFI-RUT  DELIMITED BY SIZE
                                                INTO RMEM-PARTY_NUMBER
                END-STRING
                MOVE R2600-FECHACTI             TO RMEM-START_DT
                MOVE RUTORD-CODPROGR            TO RMEM-NAME_MEM
                MOVE "Y"                        TO RMEM-ONLY_ACTIVE_FLAG
                MOVE RUNIFI-IDCLIENT-10         TO RMEM-MEM_TIER_NUM
                MOVE "RPGCL"                    TO RMEM-NAME_CLASE_MEM

                MOVE SPACES                     TO RMEM-START_DT_INI
                STRING R2600-FECHACTI_AA        DELIMITED BY SIZE
                       "-"                      DELIMITED BY SIZE
                       R2600-FECHACTI_MM        DELIMITED BY SIZE
                       "-"                      DELIMITED BY SIZE
                       R2600-FECHACTI_DD        DELIMITED BY SIZE
                                                INTO RMEM-START_DT_INI
                END-STRING
                MOVE SPACES                     TO RMEM-CHAR004
                STRING "0"                     DELIMITED BY SIZE
                      RUNIFI-RUT                DELIMITED BY SIZE
                      RUNIFI-DIGVER             DELIMITED BY SIZE
                                                INTO RMEM-CHAR004
                END-STRING
                MOVE "RUT"                      TO RMEM-CHAR003
                WRITE REG-SALIDA1 
                END-WRITE .
                ADD 1                           TO WS-C-SAL-2
                MOVE ";"                        TO RCONT-SEP01
                                                RCONT-SEP02
                                                RCONT-SEP03
                                                RCONT-SEP04
                                                RCONT-SEP05
                MOVE RUNIFI-PEMNB_GLS_NOM_PEL   
                                          TO RCONT-PERSON_FIRST_NAME
                MOVE RUNIFI-PEMNB_GLS_APL_PAT
                                          TO RCONT-PERSON_LAST_NAME
                MOVE SPACES                     TO RCONT-PARTY_NUMBER
                STRING "CL01"                   DELIMITED BY SIZE
                       RUNIFI-RUT               DELIMITED BY SIZE
                                                INTO RCONT-PARTY_NUMBER
                END-STRING
                MOVE "ZCA_CONTACT"              TO RCONT-PARTY_TYPE
                MOVE "CL"                       TO RCONT-COUNTRY
                WRITE REG-SALIDA2 
                END-WRITE .
                PERFORM LEE-02 .

        GRABA-REG02 .
                ADD 1                           TO WS-C-SAL-3
                WRITE REG-SALIDA3 FROM REG-ENTRADA1
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
                   WRITE REG-SALIDA2 FROM REG-SALIDA1 END-WRITE
                END-IF 
                CLOSE SALIDA1 .
                CLOSE SALIDA2 .
                CLOSE SALIDA3 .
                display "Registros Leidos 1=" WS-C-ENT-1
                display "Registros Leidos 2=" WS-C-ENT-2
                display "Reg.Grabados MEMBER    =" WS-C-SAL-1 .
                display "Reg.Grabados CONTACTS  =" WS-C-SAL-2 .
                display "Reg.Grabados NoPareados=" WS-C-SAL-3 .

