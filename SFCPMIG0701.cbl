        IDENTIFICATION DIVISION.
        PROGRAM-ID. SFCPMIG0701 .
        AUTHOR.     JUSTO LOYOLA DONOSO.
      * Componente que se utiliza para el pareo tabla T7542350 y Archivo TRANSACTIONS
      * Para el sistema Loyalty
      * Fecha : 29-10-2018
      * COMPILAR-LINK : cobol.sh SFCPMIG0701
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
           RECORD CONTAINS   176 CHARACTERS
           LABEL RECORD IS STANDARD.

       01  REG-ENTRADA1 .
           copy COPY_TRANSACTIONS .

       FD ENTRADA2
          RECORDING MODE IS F
          BLOCK 0
          RECORD CONTAINS 218 CHARACTERS
          LABEL RECORDS STANDARD.

       01 REG-ENTRADA2 .
          COPY COPY_T7542350 .

       FD SALIDA1
          RECORDING MODE IS F
          RECORD CONTAINS 333 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA1 .
           COPY COPY_ACURUALS .

       FD SALIDA2
          RECORDING MODE IS F
          RECORD CONTAINS 176 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA2                          PIC X(176) .

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
                display "RTRA-RUT=" RTRA-RUT
                "<<>>R2350-RUT=" R2350-RUT
                "<<>>R2350-INDICADOR=" R2350-INDICADOR
                EVALUATE TRUE
                   WHEN RTRA-RUT = R2350-RUT
                      PERFORM GRABA-REG01 UNTIL RTRA-RUT <> R2350-RUT
                                          OR WS-FIN-2 = 1
                      PERFORM LEE-01
                   WHEN RTRA-RUT < R2350-RUT
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
                IF WS-FIN-1 = 1
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
      *------------BONIFICACION
                IF R2350-INDICADOR = 4
                   display "R2350-RUT=" R2350-RUT
                   "<<>>R2350-INDICADOR=" R2350-INDICADOR
                   PERFORM GRABA-BONI
                END-IF .
                PERFORM LEE-02 .

        GRABA-BONI .
                ADD 1                           TO WS-C-SAL-1
                MOVE ";"                        TO RACUR-SEP01
                                                RACUR-SEP02
                                                RACUR-SEP03
                                                RACUR-SEP04
                                                RACUR-SEP05
                                                RACUR-SEP06
                                                RACUR-SEP07
                                                RACUR-SEP08
                                                RACUR-SEP09
                                                RACUR-SEP10
                                                RACUR-SEP11
                                                RACUR-SEP12
                                                RACUR-SEP13
                                                RACUR-SEP14
                                                RACUR-SEP15
                                                RACUR-SEP16
                                                RACUR-SEP17
                                                RACUR-SEP18
                                                RACUR-SEP19
                                                RACUR-SEP20

                MOVE "RPGCL"                    TO RACUR-MEMBER
                MOVE SPACES                     TO RACUR-ITEM_NUM
                STRING "TRX"                    DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                       R2350-CONCONCE           DELIMITED BY SIZE
                                                INTO RACUR-ITEM_NUM
                END-STRING
                MOVE SPACES                     TO RACUR-MEM_NUM
                STRING "CL01"                   DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                                                INTO RACUR-MEM_NUM
                END-STRING

                MOVE SPACES                     TO RACUR-TRX_NUM
                STRING "TRX"                    DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                                                INTO RACUR-TRX_NUM
                END-STRING
                MOVE R2350-PUNOBTEN             TO RACUR-ACCRUALED_VALUE
                                                RACUR-EXPIRED_VALUE
                MOVE "RPGCL"                    TO RACUR-PROGRAM_NAME
                MOVE "POINTTYPEAVAL"            TO RACUR-INTERNAL_NAME
                MOVE R2350-FECTRX               TO RACUR-EXPIRATION_DT
                IF RTRA-CODPROGR = "GOLD"
                   ADD 2                        TO RACUR-EXPIRATION_DT_A
                ELSE
                   ADD 1                        TO RACUR-EXPIRATION_DT_A
                END-IF
                MOVE R2350-FECTRX               TO RACUR-PROCESS_DT
                MOVE SPACES                     TO RACUR-NAME_PROMO
                STRING "CL01"                   DELIMITED BY SIZE
                       R2350-RUT                DELIMITED BY SIZE
                                                INTO RACUR-NAME_PROMO
                END-STRING
                MOVE "Base"                     TO RACUR-PTSUBTYPE
                MOVE "Y"                        TO RACUR-QUALIFYNG_FLAG
                                                RACUR-REPAID_FLAG
                MOVE R2350-FECTRX               TO RACUR-RET_EFF_DT
                MOVE "Avalaiable"               TO RACUR-STATUS_CODE
                MOVE "Accrual"                  TO RACUR-TYPE_CODE
                MOVE ZEROS                      TO RACUR-USED_VALUE
                MOVE "Carga Inicial"            TO RACUR-ACTION_NOTE
                MOVE "000"                      TO RACUR-ORDER_NUM

                WRITE REG-SALIDA1 
                END-WRITE .

        GRABA-REG02 .
                ADD 1                           TO WS-C-SAL-2
                WRITE REG-SALIDA2 FROM REG-ENTRADA1
                END-WRITE .
                PERFORM LEE-02 .

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

