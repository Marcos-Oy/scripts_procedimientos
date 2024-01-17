CREATE OR REPLACE PROCEDURE CUADRA.Cup_siebel_analiza_dbox_sieb01
IS
--
   Var_existpackhd               NUMBER ( 1 );
   Var_existpackhd_dac           NUMBER ( 1 );
   Var_handlesvacio_dac          NUMBER ( 1 );
   Var_activated_dac             NUMBER ( 1 );
   Var_onplant_dac               NUMBER ( 1 );
--
   Var_sw_ejecuta                CHAR ( 1 );
   Var_exist_mac_adre            NUMBER ( 1 );
   Var_exist_mac_uim             NUMBER ( 1 );
   Var_exist_mac_dac             NUMBER ( 1 );
   Var_exist_mac_dacactivonplan  NUMBER ( 1 );
   Var_error_mac_channel         NUMBER ( 1 );
   Var_flag_retorno              VARCHAR2 ( 1 );
   Var_localidad                 VARCHAR2 ( 30 );
   Var_direccion                 VARCHAR2 (
    200 );
   Var_id_direccion              VARCHAR2 ( 100 );
   Var_existe                    CHAR ( 1 );
   Var_cpe_misma_marca           NUMBER ( 1 );
   Var_ret_misma_marca           VARCHAR2 ( 100 );
   Var_cpe_mismo_modelo          NUMBER ( 1 );
   Var_ret_mismo_modelo          VARCHAR2 ( 100 );
   Var_integration_id            VARCHAR2 ( 30 );
   Var_cpe_enotrorut             NUMBER ( 1 );
   Var_cpe_sinprodprinc          NUMBER ( 1 );
   Var_cpe_sinprodactiv          NUMBER ( 1 );
   Var_cpe_sinprodprincactiv     CHAR ( 2 );
   Var_cpe_otrorutserv_uim       NUMBER ( 1 );
   Var_cpe_distestado_siebuim    NUMBER ( 1 );
   Var_cpe_noexiste_siebuim      NUMBER ( 1 );
   Var_cpe_distintipo_siebuim    NUMBER ( 1 );
   Var_cpe_distinretorno_siebuim NUMBER ( 1 );
   Var_cpe_canalduplicado        NUMBER ( 1 );
   Var_cpe_noexisteretor_siebuim NUMBER ( 1 );
   Var_cpe_noexistecanal_siebuim NUMBER ( 1 );
   Var_cpe_singrilla_siebuim     NUMBER ( 1 );
   Var_datos_customer_adre       VARCHAR2 ( 5 );
   Var_validatecnodac            NUMBER ( 1 );
   Var_canalcrm_noadrenalin      NUMBER ( 1 );
   Var_packhdcrm_noadrenalin     NUMBER ( 1 );
   Var_replaycrm_noadrenalin     NUMBER ( 1 );
   Var_vodcrm_noadrenalin        NUMBER ( 1 );
   Var_grillacrm_noadrenalin     NUMBER ( 1 );
   Var_progadrenalin_novod       NUMBER ( 1 );
   Var_progadrenalin_norepplay   NUMBER ( 1 );
   Var_progadrenalin_nohd        NUMBER ( 1 );
   Var_progadrenalin_nocrm       NUMBER ( 1 );
   Var_adrenalin_borrar          NUMBER ( 1 );
   Var_cpe_sinretorsiebel_actadre NUMBER ( 1 );
   Var_grillacrm_prognoadre      VARCHAR2 ( 250 );
   Var_cpeunitmac                VARCHAR2 ( 255 );
   Var_noexistedispo_adrenalin   NUMBER ( 1 );
   Var_retornoadre_varios        VARCHAR2 ( 300 );
   Var_retoadre_variossiebel     VARCHAR2 ( 5 );
   Var_cpe_distinretorno_siebadr NUMBER ( 1 );
   Var_errorgridtypeuim          NUMBER ( 1 );
   Var_cpe_duplicada_siebel      NUMBER ( 1 );
   Var_cust_noexist_adr          NUMBER ( 1 );
--
   Var_cpetype                   VARCHAR2 ( 250 );
   Var_cpedefinition             VARCHAR2 ( 255 );
   Var_cpetype_siebel            VARCHAR2 ( 255 );
   Var_externalobjectid          VARCHAR2 ( 255 );
   Var_existecanal               NUMBER ( 1 );
   Var_row_id_sie                VARCHAR2 ( 15 );
   Var_asset_id_sie              VARCHAR2 ( 15 );
   Var_name_prod                 VARCHAR2 ( 100 );
   Var_sp_num                    VARCHAR2 ( 250 );
   Var_tecno                     VARCHAR2 ( 2 );
   Var_rut_vivienda              VARCHAR2 ( 30 );
   Var_cpegrilla_uim             VARCHAR2 ( 255 ) := NULL;
   Var_codicanaladre             VARCHAR2 ( 1000 );
   Var_nmro_tupla                NUMBER ( 6 );
   Var_row_id                    VARCHAR2 ( 15 );
   Var_gridtype_siebel           VARCHAR2 ( 255 ) := NULL;
   Var_tecnologia_ebs            VARCHAR2 ( 10 ) := NULL;
   Var_cust_isbarred             NUMBER ( 1 );
   Var_cust_limite_cred          NUMBER ( 1 );
--
   Var_cpe_nmro_error            NUMBER ( 4 );
   Var_cpe_con_error             NUMBER ( 1 );
   Var_con_error                 NUMBER ( 1 );
   Var_ejeretdac                 CHAR ( 1 );
--
   Var_iden_vivienda             NUMBER ( 8 );
   Var_existedupl                CHAR ( 1 );
   Var_nmro_duplic               NUMBER ( 6 );
--
   Cur_mac                       VARCHAR2 ( 100 );
   Cur_unitaddr                  VARCHAR2 ( 250 );
   Cur_name                      VARCHAR2 ( 100 );
   Cur_rut                       VARCHAR2 ( 30 );
   Cur_ou_num_1_dbox             VARCHAR2 ( 30 );
   Cur_marca                     VARCHAR2 ( 100 );
   Cur_modelo                    VARCHAR2 ( 100 );
   Cur_root_asset_id             VARCHAR2 ( 15 );
   Cur_x_ocs_subclase            VARCHAR2 ( 30 );
   Cur_otrorut                   VARCHAR2 ( 255 );
   Cur_row_id                    VARCHAR2 ( 15 );
   Cur_status_cd                 VARCHAR2 ( 30 );
   Cur_tipo_tecnologia           VARCHAR2 ( 30 );
   Cur_cuenta_servicio           VARCHAR2 ( 100 );
   Cur_part_num                  VARCHAR2 ( 50 );
   Cur_nmro                      NUMBER ( 6 );
   Cur_x_ocs_attrib_59           VARCHAR2 ( 100 );
   Cur_ou_num_1                  VARCHAR2 ( 30 );
   Cur_nombre_producto           VARCHAR2 ( 100 );
   Cur_nombre_prod               VARCHAR2 ( 100 );
   Cur_x_ocs_attrib_59dupli      VARCHAR2 ( 100 );
   Cur_nmro_dboxdupli            NUMBER ( 6 );
   Cur_prod_id                   VARCHAR2 ( 15 );
   Cur_bill_accnt_id             VARCHAR2 ( 15 );
   Cur_rowid_canal               VARCHAR2 ( 15 );
   Cur_fecha_instala             DATE;
   Cur_integration_id            VARCHAR2 ( 30 );
   Cur_row_id_dbox               VARCHAR2 ( 15 );
--
   Var_macaddressvacia_sieb      NUMBER ( 1 );
   Var_macaddressvacia_uim       NUMBER ( 1 );
   Var_macaddressexiste_uim      NUMBER ( 1 );
   Var_errornodo                 NUMBER ( 1 );
   Var_errorsubnodo              NUMBER ( 1 );
   Var_errorserialnumber         NUMBER ( 1 );
   Var_ciclo_inicio              NUMBER ( 1 );
   Var_rut_distinto              NUMBER ( 1 );
   Var_nmro_nodo                 VARCHAR2 ( 50 );
   Var_nmro_subnodo              VARCHAR2 ( 50 );
   Var_cpe_existebs              NUMBER ( 1 );
   Var_cpe_existmacadressebs     NUMBER ( 1 );
   Var_marca_uim                 VARCHAR2 ( 100 );
   Var_modelo_uim                VARCHAR2 ( 100 );
   Var_difdia                    NUMBER ( 4 );
   Var_tipo_red                  VARCHAR2 ( 50 );
   Var_channelmap                VARCHAR2 ( 25 );
   Var_existeserv                CHAR ( 1 );
   Var_esprospecto               CHAR ( 1 );
   Var_conorden_ruts             CHAR ( 1 );

--
   CURSOR Cur_siebel_dbox
   IS
      SELECT A.X_ocs_attrib_59,
             REPLACE ( A.X_ocs_attrib_61,
                       CHR ( 9 ),
                       ''
                     ),
             A.NAME,
             TRIM ( A.Ou_num_1 ),
             A.Attrib_44,
             A.Attrib_45,
             A.Root_asset_id,
             A.X_ocs_subclase,
             A.Row_id,
             A.Status_cd,
             A.X_ocs_cod_tipo_item,
             A.Prod_id,
             A.Bill_accnt_id
        FROM Cuadra.Cut_siebel_dbox_01 A
        Left join Cuadra.Cut_Siebel_dBoxOtroRut c on c.cpe=a.x_Ocs_Attrib_59 
       WHERE A.X_ocs_attrib_59 IS NOT NULL
         AND A.Status_cd IN ( 'Activo' )                                                                --,'Suspendido')
         AND SUBSTR ( A.X_ocs_attrib_59,1,1) != 'P'
         AND SUBSTR ( A.X_ocs_attrib_59,1,1) != 'G'
         AND SUBSTR ( A.X_ocs_attrib_59,1,1) != 'C'
         AND NOT EXISTS ( SELECT *
                           FROM Rut_excluidos B
                          WHERE B.Rut_persona = A.Ou_num_1 )
         And c.cpe is null;
--     And a.x_Ocs_Cod_Tipo_Item != 'DBOXIPTV';
--     And a.x_Ocs_ATTRIB_54    != 'ACHFDE';
--     And rownum                < 1000;
--     And a.ou_num_1            In (select trim(rut_persona) from Cut_TMP_RutViv);
--     And a.x_ocs_cod_tipo_item != 'OXEOS';
--     And a.x_ocs_attrib_59     In ('M91509EQ0749');
--     And x_ocs_subclase       != 'Sin Servicios Activos';
--     And x_Ocs_Attrib_59       In ('M91513EQE141', 'M11342TEJ184');
--
   CURSOR Cur_dbox_duplicado
   IS
      SELECT   X_ocs_attrib_59,
               COUNT ( 1 ) Nmro_ruts
          FROM Cuadra.Cut_siebel_dbox
         WHERE X_ocs_attrib_59 IS NOT NULL
           AND Status_cd = 'Activo'
           AND X_ocs_attrib_59 = Cur_mac
      GROUP BY X_ocs_attrib_59
        HAVING COUNT ( 1 ) > 1;

   CURSOR Cur_dbox_ruts
   IS
      SELECT Ou_num_1,
             Row_id
        FROM Cuadra.Cut_siebel_dbox
       WHERE Status_cd = 'Activo'
         AND X_ocs_attrib_59 = Cur_mac;

--
--
   CURSOR Cur_canales_duplicados
   IS
      SELECT   Rut_cte,
               Asset_num,
               Part_num,
               Nombre_producto,
               COUNT ( 1 ) Nmro
          FROM Cuadra.Cut_siebel_canales
      GROUP BY Rut_cte,
               Asset_num,
               Part_num,
               Nombre_producto
        HAVING COUNT ( 1 ) > 1;

   CURSOR Cur_canal_borrar
   IS
      SELECT   Row_id,
               Fecha_instalacion
          FROM Cuadra.Cut_siebel_canales
         WHERE Rut_cte = Cur_otrorut
           AND Cuenta_servicio = Cur_cuenta_servicio
           AND Part_num = Cur_part_num
      ORDER BY Fecha_instalacion;

--
--
   CURSOR Cur_canales_siebel
   IS
      SELECT /*+ INDEX(Cuadra.Cut_Siebel_Canales CUI_CANAL_RUTS) */
             Nombre_producto,
             Part_num
        FROM Cuadra.Cut_siebel_canales
       WHERE Rut_cte = Cur_rut
         AND Cuenta_servicio = Cur_name;

--
--
   CURSOR Cur_cables_sindbox
   IS
      SELECT DISTINCT B.Row_id,
                      B.Integration_id,
                      B.Root_asset_id,
                      B.X_ocs_attrib_59,
                      B.Ou_num_1
                 FROM Cuadra.Cut_siebel_dbox A,
                      Cuadra.Cut_siebel_productop B
                WHERE A.Root_asset_id = B.Root_asset_id(+)
                  AND B.Permitted_type = '/service/cable'
                  AND B.Status_cd = 'Activo'
                  AND B.X_ocs_attrib_59 IS NOT NULL
                  AND SUBSTR ( B.X_ocs_attrib_59,
                               1,
                               1
                             ) != 'P'
                  AND SUBSTR ( B.X_ocs_attrib_59,
                               1,
                               1
                             ) != 'G'
                  AND B.X_ocs_categoria_detallada = 'Producto Principal';

--
   CURSOR Cur_dbox_noexist_adre
   IS
      SELECT B.Cpe
        FROM Cuadra.Cut_siebel_resulttvadr A,
             Cuadra.Cut_siebel_resultdbox B
       WHERE A.Cust_noexist_adr = 1
         AND A.Cpe = B.Cpe
         AND B.Con_orden_pend = 0
         AND B.Con_bi_pend = 0;
--
BEGIN
   BEGIN
      DELETE      Cuadra.Cut_siebel_retorno;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   BEGIN
      DELETE      Cuadra.Cut_logtelev;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   BEGIN
      DELETE      Cuadra.Cut_siebel_resulttvadr;                         --where Customer_Id = '0021415960-0_18448272';

      COMMIT;

      DELETE      Cuadra.Cut_siebel_unitaddres;                           --where CustomerId = '0021415960-0_18448272';

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   BEGIN
      DELETE      Cuadra.Cut_uim_retornoserv;                                             --Where Cpe = 'M91824ER7413';

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   BEGIN
      Var_sw_ejecuta             := 'N';

      DELETE      Cuadra.Cut_siebel_resultdbox;                                     --where rut_persona = '21415960-0';

      COMMIT;
      Var_sw_ejecuta             := 'S';
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         Var_sw_ejecuta             := 'N';
   END;

   BEGIN
      Var_sw_ejecuta             := 'N';

      DELETE      Cuadra.Cut_siebel_resultdetalle;                                          --where rut = '21415960-0';

      COMMIT;
      Var_sw_ejecuta             := 'S';
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         Var_sw_ejecuta             := 'N';
   END;

   IF Var_sw_ejecuta = 'S'
   THEN
      /*BEGIN
         Cup_siebel_analiza_duplicidad;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;*/

      --
      --
      OPEN Cur_siebel_dbox;

      LOOP
         FETCH Cur_siebel_dbox
          INTO Cur_mac,
               Cur_unitaddr,
               Cur_name,
               Cur_rut,
               Cur_marca,
               Cur_modelo,
               Cur_root_asset_id,
               Cur_x_ocs_subclase,
               Cur_row_id,
               Cur_status_cd,
               Cur_tipo_tecnologia,
               Cur_prod_id,
               Cur_bill_accnt_id;

         EXIT WHEN Cur_siebel_dbox%NOTFOUND;

         BEGIN
--          Dbms_Output.Put_Line('Rut --> '||Cur_Rut);
--          Dbms_Output.Put_Line('Name --> '||Cur_Name);
--          Dbms_Output.Put_Line('Root_Asset_Id --> '||Cur_Root_Asset_Id);
--          Dbms_Output.Put_Line('dBox --> '||Cur_MAC);
            Var_exist_mac_adre         := 0;
            Var_exist_mac_dac          := 0;
            Var_exist_mac_uim          := 0;
            Var_error_mac_channel      := 0;
            Var_cpe_misma_marca        := 0;
            Var_cpe_mismo_modelo       := 0;
            Var_cpe_distintipo_siebuim := 0;
            Var_cpe_distinretorno_siebuim := 0;
            Var_cpe_noexisteretor_siebuim := 0;
            Var_cpe_otrorutserv_uim    := 0;
            Var_cpe_distestado_siebuim := 0;
            Var_cpe_noexiste_siebuim   := 0;
            Var_existpackhd            := 0;
            Var_existpackhd_dac        := 0;
            Var_handlesvacio_dac       := 0;
            Var_activated_dac          := 0;
            Var_onplant_dac            := 0;
            Var_cpe_singrilla_siebuim  := 0;
            Var_progadrenalin_nocrm    := 0;
            Var_cpe_duplicada_siebel   := 0;
            Var_cpe_existebs           := 0;
            Var_cpe_existmacadressebs  := 0;
            Var_tecnologia_ebs         := '*';

            OPEN Cur_dbox_duplicado;

            LOOP
               FETCH Cur_dbox_duplicado
                INTO Cur_x_ocs_attrib_59dupli,
                     Cur_nmro_dboxdupli;

               EXIT WHEN Cur_dbox_duplicado%NOTFOUND;

               BEGIN
                  --
                  -- Validar si cliente es Prospecto
                  Var_esprospecto            := 'N';
                  Var_conorden_ruts          := 'N';

                  OPEN Cur_dbox_ruts;

                  LOOP
                     FETCH Cur_dbox_ruts
                      INTO Cur_ou_num_1_dbox,
                           Cur_row_id_dbox;

                     EXIT WHEN Cur_dbox_ruts%NOTFOUND;

                     BEGIN
                        BEGIN
                           SELECT 'S'
                             INTO Var_esprospecto
                             FROM Cuadra.S_asset A,
                                  Cuadra.S_asset_x Ax,
                                  Cuadra.S_org_ext Cli,
                                  Cuadra.S_org_ext Clif,
                                  Cuadra.S_prod_int Prod,
                                  Cuadra.S_addr_per Adr
                            WHERE A.Row_id = Ax.Row_id
                              AND A.Serv_acct_id = Cli.Row_id
                              AND A.Bill_accnt_id = Clif.Row_id
                              AND Prod.Row_id = A.Prod_id
                              AND Cli.Pr_addr_id = Adr.Row_id
                              AND A.Status_cd IN ( 'Activo', 'Suspendido' )
                              AND Cli.Cust_stat_cd = 'Prospecto'
                              AND Cli.Accnt_type_cd = 'Servicio'
                              AND Cli.Ou_num_1 = Cur_ou_num_1_dbox
                              AND A.Row_id = Cur_row_id_dbox;

                           IF SQL%FOUND
                           THEN
                              Var_esprospecto            := 'S';
                           END IF;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              Var_esprospecto            := 'N';
                        END;

                        BEGIN
                           --
                           -- Validar que ninguno de los rut4s que tiene el material no tenga orden pendiente
                           SELECT 'S'
                             INTO Var_conorden_ruts
                             FROM Cuadra.S_order A,
                                  Cuadra.S_org_ext E
                            WHERE E.Ou_num_1 = Cur_ou_num_1_dbox
                              AND E.Row_id = A.Accnt_id
                              AND A.Status_cd NOT IN ( 'Completada', 'Cancelado', 'Revisado' )
                              AND A.X_ocs_tipo_orden != 'Temporal';

                           IF SQL%FOUND
                           THEN
                              Var_conorden_ruts          := 'S';
                           END IF;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              Var_conorden_ruts          := 'N';
                        END;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END LOOP;

                  CLOSE Cur_dbox_ruts;

                  IF     Var_esprospecto = 'N'
                     AND Var_conorden_ruts = 'N'
                  THEN
                     Var_cpe_duplicada_siebel   := 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;
            END LOOP;

            CLOSE Cur_dbox_duplicado;

            --
            BEGIN
               SELECT Tecnologia
                 INTO Var_tecnologia_ebs
                 FROM Cuadra.Xvtr_siebel_info_series_t
                WHERE Cod_serie = TRIM ( Cur_mac );

               IF SQL%FOUND
               THEN
                  NULL;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  Var_tecnologia_ebs         := '*';
            END;

            --
            --
            -- Valida para la MAC Siebel la Existencia en Adrenalin
            --
            BEGIN
               Var_externalobjectid       := NULL;

               SELECT          /*+ INDEX(Cuadra.Cut_Siebel_ProductoP CUI_SIEBEL_PROD_04) */
                      DISTINCT X_ocs_flag_retorno,
                               X_ocs_codigo_localidad,
                               Addr,
                               Integration_id,
                               NAME,
                               Addr_name,
                               Row_id,
                               X_ocs_nodo,
                               X_ocs_subnodo,
                               X_ocs_modo_red
                          INTO Var_flag_retorno,
                               Var_localidad,
                               Var_direccion,
                               Var_integration_id,
                               Var_name_prod,
                               Var_id_direccion,
                               Var_row_id,
                               Var_nmro_nodo,
                               Var_nmro_subnodo,
                               Var_tipo_red
                          FROM Cuadra.Cut_siebel_productop
                         WHERE Cuenta_serv = Cur_name
                           AND Root_asset_id = Cur_root_asset_id
                           AND Ou_num_1 = Cur_rut
                           AND X_ocs_categoria_detallada = 'Producto Principal'
                           AND ROWNUM = 1;

--              Dbms_Output.Put_Line('Integration_ID --> '||Var_Integration_ID);
               IF SQL%FOUND
               THEN
                  -----
                  IF     Cur_modelo = 'DCT2500'
                     AND Var_flag_retorno = 'Y'
                  THEN
                     BEGIN
                        INSERT INTO Cuadra.Cut_siebel_retorno
                                    ( Cpe,
                                      Row_id,
                                      Cod_modelo,
                                      Retorno,
                                      Cod_error
                                    )
                             VALUES ( Cur_mac,
                                      Cur_row_id,
                                      Cur_modelo,
                                      Var_flag_retorno,
                                      1
                                    );

                        IF SQL%ROWCOUNT > 0
                        THEN
                           COMMIT;
                        ELSE
                           ROLLBACK;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           ROLLBACK;
                     END;
                  END IF;

                  -----
                  BEGIN
                     SELECT C.Addr_name
                       INTO Var_iden_vivienda
                       FROM Cuadra.S_asset A,
                            Cuadra.S_org_ext B,
                            Cuadra.S_addr_per C
                      WHERE A.Root_asset_id = Cur_root_asset_id
                        AND B.Row_id = A.Serv_acct_id
                        AND C.Row_id = B.Pr_addr_id
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        Var_iden_vivienda          := NULL;
                  END;

                  Var_errorgridtypeuim       := 0;

                  BEGIN
                     SELECT /*+ INDEX(Cuadra.S_Asset_XA S_ASSET_XA_01) */
                            Char_val
                       INTO Var_gridtype_siebel
                       FROM Cuadra.S_asset_xa
                      WHERE Attr_name = 'GridType'
                        AND Asset_id = Var_row_id;

                     IF SQL%FOUND
                     THEN
                        NULL;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        Var_gridtype_siebel        := '*';
                  END;

                  Var_externalobjectid       := Var_integration_id;
                  Var_cpegrilla_uim          := '*';

--                  Dbms_OutPut.Put_Line('R '||Var_Flag_Retorno);
--                  Dbms_OutPut.Put_Line('Cur_Tipo_Tecnologia -->'||Cur_Tipo_Tecnologia);
--                  Dbms_OutPut.Put_Line('Cur_UnitAddr -->'||Cur_UnitAddr);
                  BEGIN
                     SELECT /*+ INDEX(Cuadra.Cut_UIM_RFS CUI_UIM_RFS_01) */
                            VALUE
                       INTO Var_cpegrilla_uim
                       FROM Cuadra.Cut_uim_rfs
                      WHERE Externalobjectid = Var_integration_id
                        AND Caracteristica = 'GridType';

--                      Dbms_OutPut.Put_Line('Grilla Siebel -->'||Var_GridType_Siebel);
--                      Dbms_OutPut.Put_Line('Grilla UIM    -->'||Var_CPEGrilla_UIM);
                     IF     UPPER ( TRIM ( Var_cpegrilla_uim )) != UPPER ( TRIM ( Var_gridtype_siebel ))
                        AND TRIM ( Var_gridtype_siebel ) != '*'
                     THEN
                        IF Var_tipo_red IN ( 'FUDIG', 'ANDIG' )
                        THEN
                           Var_errorgridtypeuim       := 1;
                        END IF;
                     ELSE
                        Var_errorgridtypeuim       := 0;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        Var_errorgridtypeuim       := 0;
                  END;

                  IF     Var_flag_retorno = 'Y'
                     AND Cur_tipo_tecnologia != 'DBOXEOS'
                     AND Cur_tipo_tecnologia != 'DBOXIPTV'
                     AND Cur_marca NOT IN ( 'SEI Robotics', 'Evolution' )
                     AND Cur_unitaddr IS NOT NULL
                  THEN
                     Var_rut_vivienda           :=
                                         LPAD ( TRIM ( Cur_rut ),
                                                12,
                                                0
                                              ) ||
                                         '_' ||
                                         TRIM ( TO_CHAR ( Var_id_direccion ));
                     Var_channelmap             := TRIM ( Cur_modelo ) ||
                                                   'YES' ||
                                                   TRIM ( Var_localidad );

                     IF Cur_mac IN
                           ( 'M91516EQ8131', 'M91824ER7413', 'M91615EQG311', 'M11502TC3049', 'M91052FY3500',
                             'M91904ERR489' )
                     THEN
                        NULL;
                     END IF;

                    /* Var_exist_mac_adre         :=
                                     Cuf_siebel_existmac_adr ( Cur_mac,
                                                               Cur_unitaddr,
                                                               Var_rut_vivienda,
                                                               Var_channelmap
                                                             );

                     BEGIN
                        INSERT INTO Cuadra.Cut_siebel_unitaddres
                                    ( Customerid,
                                      Unitaddr
                                    )
                             VALUES ( Var_rut_vivienda,
                                      Cur_unitaddr
                                    );
                     END;*/

                     BEGIN
               
                        Var_retoadre_variossiebel  :=0;
                                      /* Cuf_siebel_canal_adr ( Var_rut_vivienda,
                                                              Var_gridtype_siebel,
                                                              Var_flag_retorno
                                                            );
                        Var_progadrenalin_novod    := SUBSTR ( Var_retoadre_variossiebel,
                                                               1,
                                                               1
                                                             );
                        Var_progadrenalin_norepplay := SUBSTR ( Var_retoadre_variossiebel,
                                                                2,
                                                                1
                                                              );
                        Var_progadrenalin_nohd     := SUBSTR ( Var_retoadre_variossiebel,
                                                               3,
                                                               1
                                                             );
                        Var_progadrenalin_nocrm    := SUBSTR ( Var_retoadre_variossiebel,
                                                               4,
                                                               1
                                                             );
                        Var_adrenalin_borrar       := SUBSTR ( Var_retoadre_variossiebel,
                                                               5,
                                                               1
                                                             );
                        Var_codicanaladre          :=
                                SUBSTR ( Var_retoadre_variossiebel,
                                         6,
                                         LENGTH ( TRIM ( Var_retoadre_variossiebel )) -
                                         5
                                       );*/
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           Var_progadrenalin_novod    := 0;
                           Var_progadrenalin_norepplay := 0;
                           Var_progadrenalin_nohd     := 0;
                           Var_progadrenalin_nocrm    := 0;
                           Var_adrenalin_borrar       := 0;
                     END;
                  ELSE
                     Var_exist_mac_adre         := 0;
                     Var_cpe_distinretorno_siebadr := 0;
                     Var_rut_vivienda           :=
                                         LPAD ( TRIM ( Cur_rut ),
                                                12,
                                                0
                                              ) ||
                                         '_' ||
                                         TRIM ( TO_CHAR ( Var_id_direccion ));
                  END IF;

                  BEGIN
                     Var_datos_customer_adre    := '00000';

                     IF     Var_flag_retorno = 'Y'
                        AND Cur_tipo_tecnologia NOT IN ( 'DBOXEOS', 'DBOXIPTV' )
                        AND Cur_marca NOT IN ( 'SEI Robotics', 'Evolution' )
                     THEN
                          Var_datos_customer_adre    := 0;
                       -- Var_datos_customer_adre    := Cuadra.Cuf_siebel_existcustomer_adr ( Cur_rut, Var_id_direccion );
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

                  Var_cpe_nmro_error         := TO_NUMBER ( SUBSTR ( Var_datos_customer_adre,
                                                                     1,
                                                                     3
                                                                   ));

                  IF Var_cpe_nmro_error > 0
                  THEN
                     Var_cpe_con_error          := 1;
                  ELSE
                     Var_cpe_con_error          := 0;
                  END IF;

                  IF     Var_flag_retorno = 'Y'
                     AND Cur_tipo_tecnologia NOT IN ( 'DBOXEOS', 'DBOXIPTV' )
                     AND Cur_marca NOT IN ( 'SEI Robotics', 'Evolution' )
                  THEN
                     BEGIN
--                          Var_RetornoAdre_Varios    := '00000';
                        Var_canalcrm_noadrenalin   := 0;
                        Var_packhdcrm_noadrenalin  := 0;
                        Var_replaycrm_noadrenalin  := 0;
                        Var_vodcrm_noadrenalin     := 0;
                        Var_grillacrm_noadrenalin  := 0;
                        Var_grillacrm_prognoadre   := NULL;
                        Var_retornoadre_varios     := 0;
                          /* Cuf_siebel_existcanal_adr ( Cur_rut,
                                                       LPAD ( TRIM ( Cur_rut ),
                                                              12,
                                                              0
                                                            ) ||
                                                       '_' ||
                                                       TRIM ( TO_CHAR ( Var_id_direccion )),
                                                       Cur_name,
                                                       Var_gridtype_siebel,
                                                       Var_flag_retorno,
                                                       Cur_mac
                                                     );
                        Var_canalcrm_noadrenalin   := SUBSTR ( Var_retornoadre_varios,
                                                               1,
                                                               1
                                                             );
                        Var_packhdcrm_noadrenalin  := SUBSTR ( Var_retornoadre_varios,
                                                               2,
                                                               1
                                                             );
                        Var_replaycrm_noadrenalin  := SUBSTR ( Var_retornoadre_varios,
                                                               3,
                                                               1
                                                             );
                        Var_vodcrm_noadrenalin     := SUBSTR ( Var_retornoadre_varios,
                                                               4,
                                                               1
                                                             );
                        Var_grillacrm_noadrenalin  := SUBSTR ( Var_retornoadre_varios,
                                                               5,
                                                               1
                                                             );
                        Var_grillacrm_prognoadre   := SUBSTR ( Var_retornoadre_varios,
                                                               6,
                                                               250
                                                             );*/
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     BEGIN
                        Var_noexistedispo_adrenalin := 0;

                        SELECT /*+ INDEX(Cuadra.Cut_UIM_RFS CUI_UIM_RFS_01) */
                               VALUE
                          INTO Var_cpeunitmac
                          FROM Cuadra.Cut_uim_rfs
                         WHERE Externalobjectid = Var_integration_id
                           AND Caracteristica = 'CPEUNITMACAddress';

                        IF SQL%FOUND
                        THEN
                           Var_noexistedispo_adrenalin :=0;
                             /* Cuf_siebel_dispo_adr ( LPAD ( TRIM ( Cur_rut ),
                                                            12,
                                                            0
                                                          ) ||
                                                     '_' ||
                                                     TRIM ( TO_CHAR ( Var_id_direccion )),
                                                     LPAD ( TRIM ( Cur_rut ),
                                                            12,
                                                            0
                                                          ),
                                                     Var_cpeunitmac
                                                   );*/
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           Var_noexistedispo_adrenalin := 0;
                     END;
                  END IF;

                  BEGIN
                     Var_cust_noexist_adr       := SUBSTR ( Var_datos_customer_adre,
                                                            1,
                                                            1
                                                          );

                     IF Var_cust_noexist_adr = 1
                     THEN
                        Var_exist_mac_adre         := 0;
                        Var_cust_isbarred          := 0;
                        Var_cust_limite_cred       := 0;
                     ELSE
                        Var_cust_isbarred          := SUBSTR ( Var_datos_customer_adre,
                                                               2,
                                                               1
                                                             );
                        Var_cust_limite_cred       := SUBSTR ( Var_datos_customer_adre,
                                                               3,
                                                               1
                                                             );
                     END IF;
                    /*+ INDEX(Cuadra.Cut_Siebel_ResultTVADR CUI_SIEBEL_RESULTTVADR_01) */
                   /*  UPDATE Cuadra.Cut_siebel_resulttvadr
                        SET Row_id = Cur_row_id,
                            Root_asset_id = Cur_root_asset_id,
                            Unit_addres = Cur_unitaddr,
                            Cust_noexist_adr = SUBSTR ( Var_datos_customer_adre,
                                                        1,
                                                        1
                                                      ),
                            Cust_isbarred = Var_cust_isbarred,
                            Cust_limite_cred = Var_cust_limite_cred,
                            Con_orden_pend = 0,
                            Cpe_con_error = Var_cpe_con_error,
                            Canalcrm_noadrenalin = Var_canalcrm_noadrenalin,
                            Packhdcrm_noadrenalin = Var_packhdcrm_noadrenalin,
                            Replaycrm_noadrenalin = Var_replaycrm_noadrenalin,
                            Vodcrm_noadrenalin = Var_vodcrm_noadrenalin,
                            Grillacrm_noadrenalin = Var_grillacrm_noadrenalin,
                            Vodadrenalin_noadre = Var_progadrenalin_novod,
                            Replayadrenalin_noadre = Var_progadrenalin_norepplay,
                            Packhdadrenalin_noadr = Var_progadrenalin_nohd,
                            Canal_adrenalin_nocrm = Var_progadrenalin_nocrm,
                            Adrenalin_borrar = Var_adrenalin_borrar,
                            Grillacrm_prognoadre = Var_grillacrm_prognoadre,
                            Noexistedispo_adrenalin = Var_noexistedispo_adrenalin
                      WHERE Customer_id = LPAD ( TRIM ( Cur_rut ),
                                                 12,
                                                 0
                                               ) ||
                                          '_' ||
                                          TRIM ( TO_CHAR ( Var_id_direccion ))
                        AND Cpe = Cur_mac;

                     IF SQL%ROWCOUNT > 0
                     THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;*/
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
--                  Dbms_Output.Put_Line('No lo encentro en la ProductoP --> '||SqlErrm);
                  Var_integration_id         := NULL;
                  NULL;
            END;

            BEGIN
               INSERT INTO Cuadra.Cut_siebel_resultdetalle
                           ( Cpe,
                             Unit_addres,
                             Marca,
                             Modelo,
                             Rut,
                             Externalobjectid,
                             Row_id
                           )
                    VALUES ( Cur_mac,
                             Cur_unitaddr,
                             UPPER ( TRIM ( Cur_marca )),
                             Cur_modelo,
                             Cur_rut,
                             Var_integration_id,
                             Cur_row_id
                           );

               IF SQL%ROWCOUNT > 0
               THEN
                  COMMIT;
               ELSE
                  ROLLBACK;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  ROLLBACK;
            END;

            --
            --
            BEGIN
               Var_cpe_existmacadressebs  := Cuf_siebel_existmacadress_ebs ( Cur_mac );
            EXCEPTION
               WHEN OTHERS
               THEN
                  Var_cpe_existmacadressebs  := 0;
            END;

            --
            --
            IF NVL ( TRIM ( Var_integration_id ), '*' ) != '*'
            THEN
               BEGIN
                  Var_cpe_existebs           := Cuf_siebel_existmate_ebs ( Cur_mac );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     Var_cpe_existebs           := 0;
               END;

               --
               -- Valida para el IntegrationID de Siebel la Existencia en UIM
               --
               --Var_CPE_NoExiste_SiebUIM := Cuf_Siebel_ExisServ_UIM(Var_Integration_ID);
               Var_cpe_noexiste_siebuim   := 0;

               IF Var_cpe_noexiste_siebuim = 0
               THEN
                  Var_cpe_distestado_siebuim := Cuf_siebel_estdserv_uim ( Cur_status_cd, Var_integration_id );
               ELSE
                  Var_cpe_distestado_siebuim := 0;
               END IF;

               --
               --
               --
               Var_exist_mac_uim          := 0;
               Var_errornodo              := 0;
               Var_errorsubnodo           := 0;
               Var_errorserialnumber      := 0;
               Var_macaddressvacia_sieb   := 0;
               Var_macaddressvacia_uim    := 0;
               Var_macaddressexiste_uim   := 0;

               IF Var_cpe_noexiste_siebuim != 1
               THEN
                  --
                  -- Valida para la MAC Siebel la Existencia en UIM
                  --
                  Var_exist_mac_uim          := Cuf_siebel_existmac_uim ( Cur_mac, Var_integration_id );

                  --
                  --
                  --
                  IF Var_exist_mac_uim = 0
                  THEN
                     BEGIN
                        Var_rut_distinto           := 0;
                     --Var_Rut_Distinto := Cuf_Tango_DifRut(Cur_Rut,Var_Integration_ID);
                     END;

                     BEGIN
                        Var_ciclo_inicio           := Cuf_siebel_ciclocero ( Var_integration_id );
                     END;

                     BEGIN
                        Var_errornodo              := Cuf_siebel_valida_nodouim ( Var_nmro_nodo, Var_integration_id );
                        Var_errorsubnodo           :=
                                                  Cuf_siebel_valida_subnodouim ( Var_nmro_subnodo, Var_integration_id );
                        Var_errorserialnumber      := Cuf_siebel_valida_serieuim ( Cur_mac, Var_integration_id );
                        Var_macaddressvacia_sieb   := Cuf_premium_macaddressvacia ( Cur_mac, Cur_row_id );
                        Var_macaddressvacia_uim    :=
                                             Cuf_premium_macaddressvaciauim ( Var_integration_id,
                                                                              Cur_mac,
                                                                              Cur_row_id
                                                                            );
                        Var_macaddressexiste_uim   :=
                                                Cuf_prem_macaddressexisteuim ( Var_integration_id,
                                                                               Cur_mac,
                                                                               Cur_row_id
                                                                             );
                     END;

                     Var_ret_misma_marca        :=
                                                  Cuadra.Cuf_siebel_marca_uim ( Cur_mac,
                                                                                Cur_marca,
                                                                                Var_integration_id
                                                                              );
                     Var_cpe_misma_marca        := TO_NUMBER ( SUBSTR ( Var_ret_misma_marca,
                                                                        1,
                                                                        1
                                                                      ));
                     Var_marca_uim              :=
                                         SUBSTR ( Var_ret_misma_marca,
                                                  2,
                                                  ( LENGTH ( TRIM ( Var_ret_misma_marca )) -
                                                    1 )
                                                );
                     --
                     Var_ret_mismo_modelo       :=
                                                Cuadra.Cuf_siebel_modelo_uim ( Cur_mac,
                                                                               Cur_modelo,
                                                                               Var_integration_id
                                                                             );
                     Var_cpe_mismo_modelo       := TO_NUMBER ( SUBSTR ( Var_ret_mismo_modelo,
                                                                        1,
                                                                        1
                                                                      ));
                     Var_modelo_uim             :=
                                       SUBSTR ( Var_ret_mismo_modelo,
                                                2,
                                                ( LENGTH ( TRIM ( Var_ret_mismo_modelo )) -
                                                  1 )
                                              );

                     BEGIN
                        UPDATE Cuadra.Cut_siebel_resultdetalle
                           SET Marca_uim = UPPER ( Var_marca_uim ),
                               Modelo_uim = Var_modelo_uim
                         WHERE Cpe = Cur_mac
                           AND Externalobjectid = Var_integration_id;

                        IF SQL%ROWCOUNT > 0
                        THEN
                           COMMIT;
                        ELSE
                           ROLLBACK;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           ROLLBACK;
                     END;

                     IF Var_cpe_mismo_modelo = 1
                     THEN
                        BEGIN
                           SELECT /*+ INDEX(Cuadra.Cut_Siebel_dBox CUI_SIEBEL_DBOX_01) */
                                  NVL ( COUNT ( 1 ), 0 )
                             INTO Var_nmro_tupla
                             FROM Cuadra.Cut_siebel_dbox B,
                                  Cuadra.Cut_siebel_productop C,
                                  Cuadra.Cut_siebel_resulttvadr D
                            WHERE B.X_ocs_attrib_59 = Cur_mac
                              AND C.Cuenta_serv = B.NAME
                              AND C.Ou_num_1 = B.Ou_num_1
                              AND C.X_ocs_flag_retorno != 'Y'
                              AND C.X_ocs_categoria_detallada = 'Producto Principal'
                              AND D.Cpe = B.X_ocs_attrib_59
                              AND D.Cust_noexist_adr = 0;

                           IF SQL%ROWCOUNT > 0
                           THEN
                              Var_cpe_sinretorsiebel_actadre := 1;

                              BEGIN
                                 UPDATE /*+ INDEX(Cuadra.Cut_Siebel_ResultTVADR CUI_SIEBEL_RESULTTVADR_02) */Cuadra.Cut_siebel_resulttvadr
                                    SET Cpe_sinretorsiebel_actadre = Var_cpe_sinretorsiebel_actadre
                                  WHERE Cpe = Cur_mac;

                                 IF SQL%ROWCOUNT > 0
                                 THEN
                                    COMMIT;
                                 ELSE
                                    ROLLBACK;
                                 END IF;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    ROLLBACK;
                              END;
                           ELSE
                              Var_cpe_sinretorsiebel_actadre := 0;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              Var_cpe_sinretorsiebel_actadre := 0;
                        END;
                     ELSE
                        Var_cpe_sinretorsiebel_actadre := 0;
                     END IF;

                     --
                     --
                     IF TRIM ( Var_tecnologia_ebs ) != 'IPTV'
                     THEN
                        Var_cpe_otrorutserv_uim    :=
                                                 Cuadra.Cuf_siebel_otrorut_uim ( Cur_mac,
                                                                                 Cur_rut,
                                                                                 Var_integration_id
                                                                               );
                     ELSE
                        Var_cpe_otrorutserv_uim    := 0;
                     END IF;

                     --
                     --
                     BEGIN
                        SELECT /*+ INDEX(Cuadra.Cut_Siebel_Equipos CUI_SIEBEL_EQUI_02) */
                               Char_val,
                               Row_id,
                               Asset_id
                          INTO Var_cpetype,
                               Var_row_id_sie,
                               Var_asset_id_sie
                          FROM Cuadra.Cut_siebel_equipos
                         WHERE Root_asset_id = Cur_root_asset_id
                           AND Asset_id = Cur_row_id
                           AND Attr_name = 'CPE Type';

                        IF SQL%FOUND
                        THEN
                           BEGIN
                              SELECT /*+ INDEX(Cuadra.Cut_Siebel_Equipos CUI_SIEBEL_EQUI_02) */
                                     Char_val
                                INTO Var_cpedefinition
                                FROM Cuadra.Cut_siebel_equipos
                               WHERE Root_asset_id = Cur_root_asset_id
                                 AND Asset_id = Cur_row_id
                                 AND Attr_name = 'Definition';

                              IF SQL%FOUND
                              THEN
                                 IF UPPER ( TRIM ( Var_cpetype )) != 'EQUIPO'
                                 THEN
                                    Var_cpetype_siebel         :=
                                       UPPER ( TRIM ( REPLACE ( Var_cpetype, '-' ))) ||
                                       UPPER ( TRIM ( Var_cpedefinition )) ||
                                       '_CPE';
                                 ELSE
                                    Var_cpetype_siebel         := UPPER ( TRIM ( 'dBoxEOS' )) ||
                                                                  '_CPE';
                                 END IF;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 Var_cpe_distintipo_siebuim := 0;
                           END;

                           BEGIN
                              UPDATE /*+ INDEX(Cuadra.Cut_Siebel_ResultDetalle CUI_SIEBEL_RESULTDETA_01) */Cuadra.Cut_siebel_resultdetalle
                                 SET Tipo = Var_cpetype,
                                     Tecnologia = Var_cpedefinition,
                                     Row_id_sie = Var_row_id_sie,
                                     Asset_id_sie = Var_asset_id_sie
                               WHERE Cpe = Cur_mac;

                              IF SQL%ROWCOUNT > 0
                              THEN
                                 COMMIT;
                              ELSE
                                 ROLLBACK;
                              END IF;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 ROLLBACK;
                           END;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     --
                     --
                     Var_cpe_distintipo_siebuim :=
                                    Cuf_siebel_tipo_uim ( Cur_mac,
                                                          Var_cpetype,
                                                          Var_cpetype_siebel,
                                                          Var_integration_id
                                                        );
                     --
                     --
                     Var_cpe_distinretorno_siebuim :=
                                         Cuadra.Cuf_siebel_retorno_uim ( Cur_mac,
                                                                         Var_flag_retorno,
                                                                         Var_integration_id
                                                                       );
                     --
                     --
                     Var_cpe_singrilla_siebuim  := Cuadra.Cuf_siebel_grilla_uim ( Cur_mac, Var_integration_id );
                     --
                     --
                     Var_cpe_noexistecanal_siebuim := 0;

                     --Dbms_Output.Put_Line('Inicio Canales --> '||Trim(To_Char(Var_CPE_NoExisteCanal_SiebUIM)));
                     --Dbms_Output.Put_Line('Rut --> '||Cur_Rut);
                     --Dbms_Output.Put_Line('dBox --> '||Cur_MAC);
                     --Dbms_Output.Put_Line('Integration_ID --> '||Var_Integration_ID);
                     OPEN Cur_canales_siebel;

                     LOOP
                        FETCH Cur_canales_siebel
                         INTO Cur_nombre_producto,
                              Cur_part_num;

                        EXIT WHEN Cur_canales_siebel%NOTFOUND;

                        BEGIN
                           Var_existecanal            := Cuf_siebel_canal_uim ( Var_integration_id, Cur_part_num );

                           IF Var_existecanal = 1
                           THEN
                              BEGIN
                                 SELECT TO_DATE ( B.Attrib_26, 'dd-mm-yyyy' ) -
                                        TO_DATE ( SYSDATE, 'dd-mm-yyyy' )
                                   INTO Var_difdia
                                   FROM Cuadra.Cut_siebel_canales A,
                                        Cuadra.S_asset_x B,
                                        Cuadra.S_asset C,
                                        Cuadra.S_prod_int D
                                  WHERE A.Rut_cte = Cur_rut
                                    AND A.Row_id = B.Row_id
                                    AND A.Row_id = C.Row_id
                                    AND C.Prod_id = D.Row_id
                                    AND D.X_ocs_categoria_detallada = 'Try and Buy'
                                    AND A.Part_num = Cur_part_num;

                                 IF SQL%FOUND
                                 THEN
                                    IF Var_difdia > 0
                                    THEN
                                       IF    NVL ( TRIM ( Cur_tipo_tecnologia ), '*' ) = 'DBOXSD'
                                          OR NVL ( TRIM ( Cur_tipo_tecnologia ), '*' ) = 'DBOXANALOGO'
                                       THEN
                                          Var_tecno                  := 'SD';
                                       ELSE
                                          Var_tecno                  := 'HD';
                                       END IF;

                                       Var_cpe_noexistecanal_siebuim := 1;

                                       BEGIN
                                          INSERT INTO Cut_result_2040
                                                      ( Externalobjectid,
                                                        Rut,
                                                        Row_id_prod,
                                                        Addr_name,
                                                        Root_asset_id,
                                                        Canal_uim,
                                                        Nombre_producto,
                                                        Tecnologia,
                                                        Con_error
                                                      )
                                               VALUES ( Var_integration_id,
                                                        Cur_rut,
                                                        Cur_row_id,
                                                        Var_iden_vivienda,
                                                        Cur_root_asset_id,
                                                        Cur_part_num,
                                                        Var_tecno,
                                                        Cur_nombre_producto,
                                                        1
                                                      );

                                          IF SQL%ROWCOUNT > 0
                                          THEN
                                             COMMIT;
                                          ELSE
                                             ROLLBACK;
                                          END IF;
                                       EXCEPTION
                                          WHEN OTHERS
                                          THEN
                                             ROLLBACK;
                                       END;
                                    ELSE
                                       Var_cpe_noexistecanal_siebuim := 0;
                                    END IF;
                                 END IF;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    Var_cpe_noexistecanal_siebuim := 1;
                              END;

                              BEGIN
                                 SELECT /*+ INDEX(Cuadra.Cut_Siebel_dBox CUI_SIEBEL_DBOX_01) */
                                        Sp_num
                                   INTO Var_sp_num
                                   FROM Cuadra.Cut_siebel_dbox
                                  WHERE X_ocs_attrib_59 = Cur_mac;

                                 IF SQL%FOUND
                                 THEN
                                    IF    NVL ( TRIM ( Var_sp_num ), '*' ) = 'DBOXSD'
                                       OR NVL ( TRIM ( Var_sp_num ), '*' ) = 'DBOXANALOGO'
                                    THEN
                                       Var_tecno                  := 'SD';
                                    ELSE
                                       Var_tecno                  := 'HD';
                                    END IF;
                                 END IF;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    Var_tecno                  := NULL;
                              END;
                           END IF;
                        END;
                     END LOOP;

                     CLOSE Cur_canales_siebel;
                  --Dbms_Output.Put_Line('Fin Canales --> '||Trim(To_Char(Var_CPE_NoExisteCanal_SiebUIM)));
                  --Dbms_Output.Put_Line('Rut --> '||Cur_Rut);
                  --Dbms_Output.Put_Line('dBox --> '||Cur_MAC);
                  --Dbms_Output.Put_Line('Integration_ID --> '||Var_Integration_ID);
                  ELSE
                     BEGIN
                        SELECT /*+ INDEX(Cuadra.Cut_Siebel_dBoxOtroRut Cui_dBoxOtroRut_01) */
                               'S'
                          INTO Var_existedupl
                          FROM Cuadra.Cut_siebel_dboxotrorut
                         WHERE Cpe = Cur_mac
                            OR     (    Rut_01 = Cur_rut
                                     OR Rut_02 = Cur_rut )
                               AND ROWNUM = 1;

                        IF SQL%FOUND
                        THEN
                           Var_exist_mac_uim          := 0;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;

                     BEGIN
                        SELECT 'S'
                          INTO Var_existeserv
                          FROM Cuadra.Cut_uim_servicios
                         WHERE Externalobjectid = Var_integration_id;

                        IF SQL%FOUND
                        THEN
                           Var_exist_mac_uim          := 1;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           Var_exist_mac_uim          := 0;
                     END;

                     Var_cpe_distestado_siebuim := 0;
                     Var_cpe_otrorutserv_uim    := 0;
                     Var_cpe_distintipo_siebuim := 0;
                     Var_cpe_distinretorno_siebuim := 0;
                     Var_cpe_noexisteretor_siebuim := 0;
                     Var_cpe_noexistecanal_siebuim := 0;
                     Var_cpe_singrilla_siebuim  := 0;
                     Var_errornodo              := 0;
                     Var_errorsubnodo           := 0;
                     Var_errorserialnumber      := 0;
                     Var_macaddressvacia_sieb   := 0;
                     Var_macaddressvacia_uim    := 0;
                     Var_macaddressexiste_uim   := 0;
                  END IF;
               ELSE
                  Var_cpe_noexiste_siebuim   := 0;
                  Var_exist_mac_uim          := 0;
                  Var_cpe_distestado_siebuim := 0;
                  Var_cpe_otrorutserv_uim    := 0;
                  Var_cpe_distintipo_siebuim := 0;
                  Var_cpe_distinretorno_siebuim := 0;
                  Var_cpe_noexisteretor_siebuim := 0;
                  Var_cpe_noexistecanal_siebuim := 0;
                  Var_cpe_singrilla_siebuim  := 0;
                  Var_errornodo              := 0;
                  Var_errorsubnodo           := 0;
                  Var_errorserialnumber      := 0;
--Validar ***** 17Jun
                  Var_macaddressvacia_sieb   := 0;
                  Var_macaddressvacia_uim    := 0;
                  Var_macaddressexiste_uim   := 0;
               --
               --
               --Fco.Cabello 17-mar2020
               --
               --
               END IF;

               --
               --
               -- Valida para la MAC Siebel la Existencia en DAC
               --
               Var_exist_mac_dac          := 0;
               Var_exist_mac_dacactivonplan := 0;

               IF Cur_tipo_tecnologia NOT IN ( 'DBOXEOS', 'DBOXIPTV' )
               THEN
                  Var_exist_mac_dac          := Cuf_siebel_existmac_dac ( Cur_mac, 1 );

                  IF Var_exist_mac_dac = 0
                  THEN
                     Var_error_mac_channel      := Cuf_siebel_valchannelmap ( Cur_mac );
                  END IF;
               --Var_Exist_MAC_DACActivOnPlan := Cuf_Siebel_ExistMAC_DAC(Cur_MAC,2);
               END IF;

               IF     Var_flag_retorno = 'Y'
                  AND Cur_tipo_tecnologia NOT IN ( 'DBOXEOS', 'DBOXIPTV' )
               THEN
                  BEGIN
                     Var_ejeretdac              := 'S';

                     SELECT 'N'
                       INTO Var_ejeretdac
                       FROM Cuadra.S_prod_int
                      WHERE Row_id = Cur_prod_id
                        AND UPPER ( NAME ) LIKE '%ANALOGO%';

                     IF SQL%FOUND
                     THEN
                        NULL;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        Var_ejeretdac              := 'S';
                  END;

                  IF Var_ejeretdac = 'S'
                  THEN
                     Var_validatecnodac         := Cuf_siebel_validatecno ( Cur_mac, Var_flag_retorno );

                     BEGIN
                        IF Var_validatecnodac = 1
                        THEN
                           Var_con_error              := 1;
                        ELSE
                           Var_con_error              := 0;
                        END IF;

                        UPDATE /*+ INDEX(Cuadra.CUT_Siebel_ResultTvDAC CUI_SIEBEL_RESULTTVDAC_01) */Cuadra.Cut_siebel_resulttvdac
                           SET Error_tecnodac = Var_validatecnodac,
                               Cpe_con_error = Var_con_error
                         WHERE Cpe = Cur_mac;

                        COMMIT;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           ROLLBACK;
                     END;
                  ELSE
                     Var_validatecnodac         := 0;
                  END IF;
               END IF;

               --
               --
               BEGIN
                  SELECT COUNT ( 1 )
                    INTO Var_nmro_duplic
                    FROM Cuadra.Cut_siebel_dboxotrorut
                   WHERE Cpe = Cur_mac
                     AND ROWNUM = 1;

                  IF Var_nmro_duplic > 0
                  THEN
                     Var_cpe_sinprodprincactiv  :=
                                               Cuadra.Cuf_equiactivo_prominact ( Cur_root_asset_id, Cur_bill_accnt_id );
                     Var_cpe_sinprodprinc       := SUBSTR ( Var_cpe_sinprodprincactiv,
                                                            1,
                                                            1
                                                          );
                     Var_cpe_sinprodactiv       := SUBSTR ( Var_cpe_sinprodprincactiv,
                                                            2,
                                                            1
                                                          );
--                      Var_CPE_SinProdPrinc := Cuadra.Cuf_Siebel_ProdPrinc(Cur_Root_Asset_Id,Cur_Bill_Accnt_Id);
                     Var_existpackhd_dac        := Cuadra.Cuf_siebel_packhd_dac ( Cur_mac, '1' );
--                      Var_HandlesVacio_Dac := Cuadra.Cuf_Siebel_PackHd_Dac(Cur_MAC,'2');
                     Var_handlesvacio_dac       := 0;
--                      Var_Activated_Dac    := Cuadra.Cuf_Siebel_PackHd_Dac(Cur_MAC,'3');
                     Var_activated_dac          := 0;
--                      Var_Onplant_Dac      := Cuadra.Cuf_Siebel_PackHd_Dac(Cur_MAC,'4');
                     Var_onplant_dac            := 0;
                  ELSE
                     Var_cpe_sinprodprincactiv  := '00';
                     Var_cpe_sinprodprinc       := 0;
                     Var_cpe_sinprodactiv       := 0;
                     Var_existpackhd_dac        := 0;
                     Var_handlesvacio_dac       := 0;
                     Var_activated_dac          := 0;
                     Var_onplant_dac            := 0;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     Var_cpe_sinprodprincactiv  := '00';
                     Var_cpe_sinprodprinc       := 0;
                     Var_cpe_sinprodactiv       := 0;
                     Var_existpackhd_dac        := 0;
                     Var_handlesvacio_dac       := 0;
                     Var_activated_dac          := 0;
                     Var_onplant_dac            := 0;
               END;
            END IF;

            --
            -- Termino de validacisn de exietencia de dBox
            -- Sobre la tabla de Productos Principales de Siebel
            --
            BEGIN
               SELECT /*+ INDEX(Cuadra.Cut_Siebel_ResultdBox CUI_SIEBEL_RESULTDBOX_01) */
                      'S'
                 INTO Var_existe
                 FROM Cuadra.Cut_siebel_resultdbox
                WHERE Cpe = Cur_mac
                  AND Rut_persona = Cur_rut;

               IF SQL%FOUND
               THEN
                  BEGIN
                     INSERT INTO Cuadra.Cut_logtelev
                                 ( Corr_log,
                                   Fech_log,
                                   Accion,
                                   Cpe,
                                   Rut_proceso,
                                   Nmro_valida,
                                   Valor
                                 )
                          VALUES ( Cuq_corr_log.NEXTVAL,
                                   SYSDATE,
                                   'Update',
                                   Cur_mac,
                                   Cur_rut,
                                   2012,
                                   Var_cpe_sinprodprinc
                                 );

                     IF SQL%ROWCOUNT > 0
                     THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;

/*
                    Begin
                        Insert Into Cuadra.CUT_LOG2040
                        (Rut_Persona,
                         CPE,
                         CPE_NoExisteCanal_SiebUIM,
                         Integration_ID)
                        Values
                        (Cur_Rut,
                         Cur_MAC,
                         Var_CPE_NoExisteCanal_SiebUIM,
                         Var_Integration_ID);
                        Commit;
                        Exception When Others Then
                            Rollback;
                    End;
*/
                  BEGIN
                     UPDATE /*+ INDEX(Cuadra.Cut_Siebel_ResultdBox CUI_SIEBEL_RESULTDBOX_01) */Cuadra.Cut_siebel_resultdbox
                        SET Cpe_noexist_adrenalin = Var_exist_mac_adre,
                            Cpe_noexist_dac = Var_exist_mac_dac,
                            Cpe_noexist_uim = Var_exist_mac_uim,
                            Cpe_channelmap_vcmlab = 0                      --Var_Error_MAC_Channel comentado 21-Feb-2020
                                                     ,
                            Cpe_distinta_marca = Var_cpe_misma_marca,
                            Cpe_distinto_modelo = Var_cpe_mismo_modelo,
                            Codi_localidad = Var_localidad,
                            Integration_id = Var_integration_id,
                            Addres_id = Var_iden_vivienda,
                            Desc_direccion = Var_direccion,
                            Indica_serv_ensiebel = Cur_x_ocs_subclase,
                            Cpe_enotro_rut = Var_cpe_enotrorut,
                            Cpe_sinprodprin = Var_cpe_sinprodprinc,
                            Cpe_otrorutserv_uim = Var_cpe_otrorutserv_uim,
                            Cpe_distestado_siebuim = Var_cpe_distestado_siebuim,
                            Cpe_noexiste_siebuim = Var_cpe_noexiste_siebuim,
                            Cpe_distintipo_siebuim = Var_cpe_distintipo_siebuim,
                            Cpe_distinretorno_siebuim = Var_cpe_distinretorno_siebuim,
                            Cpe_noexisteretorno_siebuim = Var_cpe_noexisteretor_siebuim,
                            Cpe_noexistecanal_siebuim = Var_cpe_noexistecanal_siebuim,
                            Cpe_noexistepackhd_siebdac = Var_existpackhd_dac,
                            Cpe_activate_dac = Var_activated_dac,
                            Cpe_onplan_dac = Var_onplant_dac,
                            Cpe_handles_dac = Var_handlesvacio_dac,
                            Cpe_singrilla_siebuim = Var_cpe_singrilla_siebuim,
                            Progadrenalin_nocrm = Var_progadrenalin_nocrm,
                            Codicanaladre = Var_codicanaladre,
                            Cpe_distinretorno_siebadr = Var_cpe_distinretorno_siebadr,
                            Errorgridtypeuim = Var_errorgridtypeuim,
                            Cpe_duplicada_siebel = Var_cpe_duplicada_siebel,
                            Cpe_sinprodactiv = Var_cpe_sinprodactiv,
                            Cpe_errornodo = Var_errornodo,
                            Cpe_errorsubnodo = Var_errorsubnodo,
                            Cpe_errorserialnumber = Var_errorserialnumber,
                            Ciclo_inicio = Var_ciclo_inicio,
                            Rut_distinto = Var_rut_distinto,
                            Cpe_existebs = Var_cpe_existebs,
                            Cpe_macaddressvacia_sieb = Var_macaddressvacia_sieb,
                            Cpe_macaddressvacia_uim = Var_macaddressvacia_uim,
                            Cpe_macaddressexiste_uim = Var_macaddressexiste_uim,
                            Cpe_existmacadressebs = Var_cpe_existmacadressebs
                      WHERE Cpe = Cur_mac
                        AND Rut_persona = Cur_rut;

                     IF SQL%ROWCOUNT > 0
                     THEN
                        COMMIT;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
                     INSERT INTO Cuadra.Cut_logtelev
                                 ( Corr_log,
                                   Fech_log,
                                   Accion,
                                   Cpe,
                                   Rut_proceso,
                                   Nmro_valida,
                                   Valor
                                 )
                          VALUES ( Cuq_corr_log.NEXTVAL,
                                   SYSDATE,
                                   'Insert',
                                   Cur_mac,
                                   Cur_rut,
                                   2012,
                                   Var_cpe_sinprodprinc
                                 );

                     IF SQL%ROWCOUNT > 0
                     THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;

                  BEGIN
                     INSERT INTO Cuadra.Cut_siebel_resultdbox
                                 ( Cpe,
                                   Row_id,
                                   Unit_addres,
                                   Rut_persona,
                                   Codi_localidad,
                                   Integration_id,
                                   Addres_id,
                                   Desc_direccion,
                                   Indica_serv_ensiebel,
                                   Cpe_noexist_adrenalin,
                                   Cpe_noexist_dac,
                                   Cpe_noexist_uim,
                                   Cpe_distinta_marca,
                                   Cpe_distinto_modelo,
                                   Cpe_channelmap_vcmlab,
                                   Cpe_enotro_rut,
                                   Cpe_sinprodprin,
                                   Cpe_distestado_siebuim,
                                   Cpe_noexiste_siebuim,
                                   Cpe_otrorutserv_uim,
                                   Cpe_distintipo_siebuim,
                                   Cpe_distinretorno_siebuim,
                                   Cpe_noexisteretorno_siebuim,
                                   Cpe_noexistecanal_siebuim,
                                   Cpe_noexistepackhd_siebdac,
                                   Cpe_activate_dac,
                                   Cpe_onplan_dac,
                                   Cpe_handles_dac,
                                   Cpe_singrilla_siebuim,
                                   Progadrenalin_nocrm,
                                   Codicanaladre,
                                   Cpe_distinretorno_siebadr,
                                   Errorgridtypeuim,
                                   Cpe_duplicada_siebel,
                                   Nmro_duplicadas,
                                   Cpe_duplicada_ctaserv,
                                   Cpe_duplicada_otrorut,
                                   Cpe_duplicada_mismorut,
                                   Cpe_noexist_brm,
                                   Cpe_canalduplicado,
                                   Cpe_sinprodactiv,
                                   Cpe_errornodo,
                                   Cpe_errorsubnodo,
                                   Cpe_errorserialnumber,
                                   Ciclo_inicio,
                                   Rut_distinto,
                                   Cpe_existebs,
                                   Cpe_macaddressvacia_sieb,
                                   Cpe_macaddressvacia_uim,
                                   Cpe_macaddressexiste_uim,
                                   Cpe_existmacadressebs
                                 )
                          VALUES ( Cur_mac,
                                   Cur_row_id,
                                   Cur_unitaddr,
                                   TRIM ( Cur_rut ),
                                   TRIM ( Var_localidad ),
                                   Var_integration_id,
                                   Var_iden_vivienda,
                                   TRIM ( Var_direccion ),
                                   Cur_x_ocs_subclase,
                                   Var_exist_mac_adre,
                                   Var_exist_mac_dac,
                                   Var_exist_mac_uim,
                                   Var_cpe_misma_marca,
                                   Var_cpe_mismo_modelo,
                                   Var_error_mac_channel,
                                   Var_cpe_enotrorut,
                                   Var_cpe_sinprodprinc,
                                   Var_cpe_distestado_siebuim,
                                   Var_cpe_noexiste_siebuim,
                                   Var_cpe_otrorutserv_uim,
                                   Var_cpe_distintipo_siebuim,
                                   Var_cpe_distinretorno_siebuim,
                                   Var_cpe_noexisteretor_siebuim,
                                   Var_cpe_noexistecanal_siebuim,
                                   Var_existpackhd_dac,
                                   Var_activated_dac,
                                   Var_onplant_dac,
                                   Var_handlesvacio_dac,
                                   Var_cpe_singrilla_siebuim,
                                   Var_progadrenalin_nocrm,
                                   Var_codicanaladre,
                                   Var_cpe_distinretorno_siebadr,
                                   Var_errorgridtypeuim,
                                   Var_cpe_duplicada_siebel,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   Var_cpe_sinprodactiv,
                                   Var_errornodo,
                                   Var_errorsubnodo,
                                   Var_errorserialnumber,
                                   Var_ciclo_inicio,
                                   Var_rut_distinto,
                                   Var_cpe_existebs,
                                   Var_macaddressvacia_sieb,
                                   Var_macaddressvacia_uim,
                                   Var_macaddressexiste_uim,
                                   Var_cpe_existmacadressebs
                                 );

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
               WHEN OTHERS
               THEN
                  ROLLBACK;
            END;
         --
         --
         END;
      END LOOP;

      CLOSE Cur_siebel_dbox;

      --
      --
      OPEN Cur_canales_duplicados;

      LOOP
         FETCH Cur_canales_duplicados
          INTO Cur_otrorut,
               Cur_cuenta_servicio,
               Cur_part_num,
               Cur_nombre_prod,
               Cur_nmro;

         EXIT WHEN Cur_canales_duplicados%NOTFOUND;

         BEGIN
            Var_cpe_canalduplicado     := 1;

            BEGIN
               UPDATE /*+ INDEX(Cuadra.Cut_Siebel_ResultdBox CUI_SIEBEL_RESULTDBOX_03) */Cuadra.Cut_siebel_resultdbox
                  SET Cpe_canalduplicado = Var_cpe_canalduplicado
                WHERE Rut_persona = Cur_otrorut;

               IF SQL%ROWCOUNT > 0
               THEN
                  COMMIT;
               ELSE
                  BEGIN
                     INSERT INTO Cuadra.Cut_siebel_resultdbox
                                 ( Cpe,
                                   Row_id,
                                   Unit_addres,
                                   Rut_persona,
                                   Codi_localidad,
                                   Desc_direccion,
                                   Indica_serv_ensiebel,
                                   Cpe_noexist_adrenalin,
                                   Cpe_noexist_dac,
                                   Cpe_noexist_uim,
                                   Cpe_distinta_marca,
                                   Cpe_distinto_modelo,
                                   Cpe_channelmap_vcmlab,
                                   Cpe_enotro_rut,
                                   Cpe_sinprodprin,
                                   Cpe_distestado_siebuim,
                                   Cpe_noexiste_siebuim,
                                   Cpe_otrorutserv_uim,
                                   Cpe_distintipo_siebuim,
                                   Cpe_distinretorno_siebuim,
                                   Cpe_noexisteretorno_siebuim,
                                   Cpe_duplicada_mismorut,
                                   Cpe_duplicada_otrorut,
                                   Cpe_canalduplicado,
                                   Cpe_duplicada_siebel,
                                   Nmro_duplicadas,
                                   Cpe_duplicada_ctaserv,
                                   Cpe_noexist_brm
                                 )
                          VALUES ( '999999',
                                   0,
                                   0,
                                   TRIM ( Cur_otrorut ),
                                   NULL,
                                   NULL,
                                   NULL,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0
                                 );

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  BEGIN
                     INSERT INTO Cuadra.Cut_siebel_resultdbox
                                 ( Cpe,
                                   Row_id,
                                   Unit_addres,
                                   Rut_persona,
                                   Codi_localidad,
                                   Desc_direccion,
                                   Indica_serv_ensiebel,
                                   Cpe_noexist_adrenalin,
                                   Cpe_noexist_dac,
                                   Cpe_noexist_uim,
                                   Cpe_distinta_marca,
                                   Cpe_distinto_modelo,
                                   Cpe_channelmap_vcmlab,
                                   Cpe_enotro_rut,
                                   Cpe_sinprodprin,
                                   Cpe_distestado_siebuim,
                                   Cpe_noexiste_siebuim,
                                   Cpe_otrorutserv_uim,
                                   Cpe_distintipo_siebuim,
                                   Cpe_distinretorno_siebuim,
                                   Cpe_noexisteretorno_siebuim,
                                   Cpe_canalduplicado,
                                   Cpe_duplicada_siebel,
                                   Nmro_duplicadas,
                                   Cpe_duplicada_ctaserv,
                                   Cpe_duplicada_otrorut,
                                   Cpe_duplicada_mismorut,
                                   Cpe_noexist_brm
                                 )
                          VALUES ( '999999',
                                   0,
                                   0,
                                   TRIM ( Cur_otrorut ),
                                   NULL,
                                   NULL,
                                   NULL,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0
                                 );

                     COMMIT;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
            END;

            OPEN Cur_canal_borrar;

            LOOP
               FETCH Cur_canal_borrar
                INTO Cur_rowid_canal,
                     Cur_fecha_instala;

               EXIT WHEN Cur_canal_borrar%NOTFOUND;

               BEGIN
                  BEGIN
                     INSERT INTO Cut_2036
                                 ( Rut_persona,
                                   Row_id,
                                   Cuenta_servicio,
                                   Part_num,
                                   Fecha_instalacion
                                 )
                          VALUES ( Cur_otrorut,
                                   Cur_rowid_canal,
                                   Cur_cuenta_servicio,
                                   Cur_part_num,
                                   Cur_fecha_instala
                                 );

                     IF SQL%ROWCOUNT > 0
                     THEN
                        COMMIT;
                        EXIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        ROLLBACK;
                  END;
               END;
            END LOOP;

            CLOSE Cur_canal_borrar;
         END;
      END LOOP;

      CLOSE Cur_canales_duplicados;

      --
      --
      OPEN Cur_cables_sindbox;

      LOOP
         FETCH Cur_cables_sindbox
          INTO Cur_row_id,
               Cur_integration_id,
               Cur_root_asset_id,
               Cur_x_ocs_attrib_59,
               Cur_ou_num_1;

         EXIT WHEN Cur_cables_sindbox%NOTFOUND;

         BEGIN
            UPDATE Cuadra.Cut_siebel_resultdbox
               SET Cpe_cablesindbox = 1
             WHERE Cpe = Cur_x_ocs_attrib_59;

            IF SQL%ROWCOUNT > 0
            THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  INSERT INTO Cuadra.Cut_siebel_resultdbox
                              ( Cpe,
                                Row_id,
                                Unit_addres,
                                Rut_persona,
                                Codi_localidad,
                                Desc_direccion,
                                Indica_serv_ensiebel,
                                Cpe_noexist_adrenalin,
                                Cpe_noexist_dac,
                                Cpe_noexist_uim,
                                Cpe_distinta_marca,
                                Cpe_distinto_modelo,
                                Cpe_channelmap_vcmlab,
                                Cpe_enotro_rut,
                                Cpe_sinprodprin,
                                Cpe_distestado_siebuim,
                                Cpe_noexiste_siebuim,
                                Cpe_otrorutserv_uim,
                                Cpe_distintipo_siebuim,
                                Cpe_distinretorno_siebuim,
                                Cpe_noexisteretorno_siebuim,
                                Cpe_canalduplicado,
                                Cpe_duplicada_siebel,
                                Nmro_duplicadas,
                                Cpe_duplicada_ctaserv,
                                Cpe_duplicada_otrorut,
                                Cpe_duplicada_mismorut,
                                Cpe_noexist_brm,
                                Cpe_cablesindbox
                              )
                       VALUES ( Cur_x_ocs_attrib_59,
                                Cur_row_id,
                                0,
                                TRIM ( Cur_ou_num_1 ),
                                NULL,
                                NULL,
                                NULL,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1
                              );

                  IF SQL%ROWCOUNT > 0
                  THEN
                     COMMIT;
                  ELSE
                     ROLLBACK;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
               END;
            WHEN OTHERS
            THEN
               ROLLBACK;
         END;
      END LOOP;

      CLOSE Cur_cables_sindbox;

      --
  /*    OPEN Cur_dbox_noexist_adre;

      LOOP
         FETCH Cur_dbox_noexist_adre
          INTO Cur_mac;

         EXIT WHEN Cur_dbox_noexist_adre%NOTFOUND;

         BEGIN
            Var_existe                 := 'N';

            SELECT 'S'
              INTO Var_existe
              FROM Cuadra.Cut_result_tablaxvtr
             WHERE Cod_serie = Cur_mac
               AND Tipo_material = 'dBox'
               AND Existe = 1;

            IF Var_existe = 'S'
            THEN
               BEGIN
                  UPDATE Cuadra.Cut_siebel_resulttvadr
                     SET Cust_noexist_adr = 0
                   WHERE Cpe = Cur_mac;

                  IF SQL%ROWCOUNT > 0
                  THEN
                     COMMIT;
                  ELSE
                     ROLLBACK;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
               END;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;

      CLOSE Cur_dbox_noexist_adre;*/
   --
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;