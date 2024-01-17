CREATE OR REPLACE PROCEDURE CUADRA.Cup_Siebel_Analiza_Inet_Siebel
Is
--
Var_Sw_Ejecuta                   Char(1);
Var_Exist_MAC_UIM                Number(1);
Var_Flag_Retorno                 VarChar2(1);
Var_Localidad                    VarChar2(30);
Var_Direccion                    VarChar2(200);
Var_Existe                       Char(1);
Var_CPE_Misma_Marca              Number(1);
Var_CPE_Mismo_Modelo             Number(1);
Var_Integration_ID               VarChar2(30);
Var_CPE_EnOtroRut                Number(1);
Var_CPE_OtroRutServ_UIM          Number(1);
Var_CPE_DistEstado_SiebUIM       Number(1);
Var_CPE_NoExiste_SiebUIM         Number(1);
Var_Flag_CPETechnology           Number(1);
Var_Flag_RoutingMode             Number(1);
Var_Flag_CPEType                 Number(1);
Var_CPE_DistinVeloSiebUIM        Number(1);
Var_CPE_DistinVeloSiebIncog      Number(1);
Var_RutAux                       VarChar2(30);
Var_UnitAddr                     VarChar2(250);
Var_Adminstate                   VarChar2(50);
Var_CPETechnology                VarChar2(250);
Var_RoutingMode                  VarChar2(250);
Var_CPEType                      VarChar2(250);
Var_DocsisSiebel                 VarChar2(250);
Var_CPE_NoExisteIncognito        Number(1);
Var_CPE_DuplicadaIncognito       Number(1);
Var_CPE_RutDistinIncognito       Number(1);
Var_CPE_EstadoDistinIncognito    Number(1);
Var_CPE_LocaDistinIncognito      Number(1);
Var_CPE_MarcaDistinIncognito     Number(1);
Var_CPE_ModeloDistinIncognito    Number(1);
Var_CPE_RoutingModeIncognito     Number(1);
Var_CPE_ErrorDocsis              Number(1);
Var_ErrorModeloDocsis            Number(1);
Var_CPE_ErrorRetorno             Number(1);
Var_CPE_Duplicada_Siebel         Number(1);
Var_Flag_DocsisSieUIM            Number(1);
Var_Velo_DownStream              VarChar2(250);
Var_Velo_DownStreamTrial         VarChar2(250);
Var_Row_IdBeneficio              VarChar2(15);
Var_Row_Id_MTA                   VarChar2(15);
Var_Row_ID_MTARM                 VarChar2(15);
Var_Asset_Id_MTA                 VarChar2(15);
Var_MAC                          VarChar2(100);
Var_MismoMaterial                Char(1);
--
--Var_Result_Incognito             Char(600);
Var_MacDupli_UIM                 Number(1);
Var_CPE_MACVaciaEquipo           Number(1);
Var_CPE_MACVaciaPromo            Number(1);
Var_CPE_Vacio_RoutingMode        Number(1);
Var_CPE_Con_Error                Number(1);
Var_Flag_FTTH_IPTV               Char(1);
--
--
Cur_MAC                          VarChar2(100);
Cur_Name                         VarCHar2(100);
Cur_Rut                          VarChar2(30);
Cur_MacCM                        VarChar2(50);
Cur_Marca                        VarChar2(100);
Cur_Modelo                       VarChar2(100);
Cur_Root_Asset_Id                VarChar2(15);
Cur_x_Ocs_SubClase               VarChar2(30);
Cur_Row_Id                       VarChar2(15);
Cur_Status_CD                    VarChar2(30);
Cur_Owner_Accnt_ID               VarChar2(15);
Cur_Serv_Acct_ID                 VarChar2(15);
Cur_Asset_Num                    VarChar2(400);
Cur_Codi_Localidad               VarChar2(30);
Cur_MAC_Dupli                    VarChar2(100);
Cur_Nmros_CPE                    Number(4);
Cur_Integration_ID               VarChar2(30);
Cur_Asset_Integration_ID         VarChar2(30);
Cur_Integration                  VarChar2(30);
Cur_Nmro_Nodo                    VarChar2(50);
Cur_Nmro_SubNodo                 VarChar2(50);
--
--
Cur_RutInet                      VarChar2(30);
Cur_MACInet                      VarCHar2(100);
--
--
Cur_CPE_MarcaDistinIncognito     Number(1);
Cur_CPE_DuplicadaIncognito       Number(1);
Cur_CPE_LocaDistinIncognito      Number(1);
Cur_CPE_RutDistinIncognito       Number(1);
Cur_Cpe_RoutingModeIncognito     Number(1);
Cur_CPE_DistinVeloSiebIncog      Number(1);
Cur_Cpe_Modelodistintincognito   Number(1);
Cur_Cpe_Noexisteincognito        Number(1);
--
--
Var_ErrorEquiPromo               Number(1);
Var_Contador                     Number(6);
--
--
Var_External_Actual              VarChar2(30);
Var_Es_FTTH                      Char(1);
--
--
Var_SwTieneEquipo                Number(1);
Var_PromoInetIgualEquInact       Number(1);
Var_PromoInetSinEquipo           Number(1);
Var_PromoInetEquInact            Number(1);
--
--
Cur_EstadoMatPromo               VarChar2(30);
Cur_SerieEquipo                  VarChar2(100);
--
Var_ErrorNodo                    Number(1);
Var_ErrorSubNodo                 Number(1);
Var_ErrorMacAddress              Number(1);
Var_Ciclo_Inicio                 Number(1);
Var_Rut_Distinto                 Number(1);
Var_CPE_ExistEBS                 Number(1);
--
Var_ExisteServ                   Char(1);
--
Cursor Cur_Siebel_Inet
Is
    Select b.x_Ocs_Attrib_59
          ,b.Cuenta_Serv
          ,b.Ou_Num_1
          ,b.Attrib_42
          ,b.Attrib_44
          ,b.Attrib_45
          ,b.Root_Asset_Id
          ,b.x_Ocs_SubClase
          ,b.Row_Id
          ,b.Status_Cd
          ,b.Owner_Accnt_ID
          ,b.Serv_Acct_ID
          ,b.x_Ocs_Attrib_57
          ,b.x_Ocs_Codigo_Localidad
          ,b.Integration_ID
          ,b.x_Ocs_Nodo
          ,b.x_Ocs_SubNodo
      From Cuadra.Cut_Siebel_ProductoP b
     Where b.Permitted_Type = '/service/broadband'
       And b.Status_Cd      = 'Activo'
       And b.x_ocs_attrib_59 Not In (select CPE from Cuadra.Cut_Siebel_ResultInet where CPE_Duplicada_MismoRut = 1)
       And b.x_ocs_categoria_detallada   = 'Producto Principal'
       And b.x_Ocs_Attrib_59 Not In ('VALIDARX1021','VALIDARXG19','342CC4A250B5')
       And Not Exists (Select * From Rut_Excluidos a Where a.Rut_Persona = b.ou_num_1);
--       And b.row_id = '1-1HJCX-2670';
--       And b.x_ocs_attrib_59 In (select cpe from Cut_Siebel_ValidaMaterialINET Where CPE_conerror = 0);
--
Cursor Cur_Siebel_MACBaja
Is
    Select b.Status_CD,
           c.X_Ocs_Attrib_59
      From Cuadra.Cut_Siebel_ProductoP a
          ,Cuadra.Cut_Siebel_ProductoP d
          ,Cuadra.S_Asset b
          ,Cuadra.S_Asset_x c
     Where a.Cuenta_Serv               = Cur_Name
       And a.Permitted_Type            = '/service/broadband'
       And a.x_ocs_categoria_detallada = 'Producto Principal'
       And a.Serv_Acct_Id              = b.Serv_Acct_Id
       And b.Desc_Text in ('Caja MTA / CM' , 'Equipo')
       And b.Row_Id                    = c.Row_Id
       And d.Serv_Acct_Id              = b.Serv_Acct_Id
       And d.x_ocs_categoria_detallada = 'Producto Principal'
       And d.Permitted_Type            = '/service/broadband';
--
--
Cursor Cur_Siebel_Duplicada
Is
    Select x_Ocs_Attrib_59
          ,Count(1) Nmros_CPE
     From Cuadra.Cut_Siebel_ProductoP
     Where Permitted_Type            = '/service/broadband'
       And Status_CD                 = 'Activo'
       And X_OCS_CATEGORIA_DETALLADA = 'Producto Principal'
       And x_ocs_attrib_59           = Cur_MAC
    Group By x_Ocs_Attrib_59
    Having Count(1)        > 1;
--
--
Cursor Cur_Inet_SinMaterial
Is
    Select Distinct a.Ou_Num_1
          ,b.Integration_ID
          ,a.Asset_Integration_id
          ,a.X_Ocs_Attrib_59
          ,b.Serv_Acct_ID
          ,b.Cuenta_Serv
      From Cuadra.Cut_Siebel_Equipos_MTA a
          ,Cuadra.Cut_Siebel_ProductoP b
     Where b.Permitted_Type            = '/service/broadband'
       And b.Status_Cd                 = 'Activo'
       And b.x_ocs_categoria_detallada = 'Producto Principal'
       And b.x_Ocs_Attrib_57           = a.asset_integration_id(+)
       And a.x_Ocs_Attrib_59 Is Null
       And a.ou_num_1        Is Not Null;
--
--
Cursor Cur_Inet_ErrorMaterial
Is
   Select Distinct
          Ou_Num_1
         ,X_Ocs_Attrib_59
     From Cuadra.Cut_Siebel_Equipos_MTA
    Where Ou_Num_1 = Cur_Rut;
--
--
Cursor Cur_Update
Is
    Select CPE,
           CPE_MarcaDistinIncognito,
           CPE_DuplicadaIncognito,
           CPE_LocaDistinIncognito,
           CPE_RutDistinIncognito,
           Cpe_RoutingModeIncognito,
           CPE_DistinVeloSiebIncog,
           Cpe_Modelodistintincognito,
           Cpe_Noexisteincognito
      From Cuadra.Cut_Siebel_ResultDetaInet
     Where CPE_MarcaDistinIncognito   = 1
        Or CPE_DuplicadaIncognito     = 1
        or CPE_LocaDistinIncognito    = 1
        or CPE_RutDistinIncognito     = 1
        or Cpe_RoutingModeIncognito   = 1
        or CPE_DistinVeloSiebIncog    = 1
        or Cpe_Modelodistintincognito = 1
        or Cpe_Noexisteincognito      = 1;
--
--
Begin
    Begin
        Var_Sw_Ejecuta := 'N';
        Delete Cuadra.Cut_Siebel_ResultInet;
        Commit;
        Var_Sw_Ejecuta := 'S';
        Exception When Others Then
            Rollback;
            Var_Sw_Ejecuta := 'N';
    End;
    Begin
        Var_Sw_Ejecuta := 'N';
        Delete Cuadra.Cut_Siebel_ResultDetaInet;
        Commit;
        Var_Sw_Ejecuta := 'S';
        Exception When Others Then
            Rollback;
            Var_Sw_Ejecuta := 'N';
    End;
    Begin
        Var_Sw_Ejecuta := 'N';
        Delete Cuadra.Cut_Dif_Mat_SiebelSiebel;
        Commit;
        Var_Sw_Ejecuta := 'S';
        Exception When Others Then
            Rollback;
            Var_Sw_Ejecuta := 'N';
    End;
    Begin
        Var_Sw_Ejecuta := 'N';
        Delete Cuadra.Cut_MACDupli_UIM;
        Commit;
        Var_Sw_Ejecuta := 'S';
        Exception When Others Then
            Rollback;
            Var_Sw_Ejecuta := 'N';
    End;
    Begin
        Delete Cuadra.Cut_2080;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Begin
        Delete Cuadra.Cut_Siebel_WiFi_PromoEquipo;
        Commit;
        Exception When Others Then
            Rollback;
    End;

    Begin
        Cup_Siebel_Analiza_Duplic_Inet;
        Exception When Others Then
            Rollback;
    End;

    If Var_Sw_Ejecuta = 'S' Then
        --
        Open Cur_Siebel_Inet;
        Loop
        Fetch Cur_Siebel_Inet
         Into Cur_MAC
             ,Cur_Name
             ,Cur_Rut
             ,Cur_MacCM
             ,Cur_Marca
             ,Cur_Modelo
             ,Cur_Root_Asset_Id
             ,Cur_x_Ocs_SubClase
             ,Cur_Row_Id
             ,Cur_Status_CD
             ,Cur_Owner_Accnt_ID
             ,Cur_Serv_Acct_ID
             ,Cur_Asset_Num
             ,Cur_Codi_Localidad
             ,Cur_Integration
             ,Cur_Nmro_Nodo
             ,Cur_Nmro_SubNodo;
        Exit When Cur_Siebel_Inet%NotFound;
        Begin
            Var_CPE_MACVaciaEquipo    := 0;
            Var_CPE_MACVaciaPromo     := 0;
            Var_CPE_Vacio_RoutingMode := 0;
            Begin
                Select Count(Distinct b.integration_id)
                  Into Var_Contador
                  From Cuadra.s_asset_xa a,
                       Cuadra.s_asset b,
                       Cuadra.s_prod_int Prod,
                       Cuadra.S_ASSET_X AX,
                       Cuadra.S_ORG_EXT CLI
                 Where a.asset_id                     = b.row_id
                   And b.prod_id                      = prod.row_id
                   And prod.x_ocs_categoria_detallada = 'Otros Fijos'
                   And Prod.Name                      = 'Equipo'
                   And b.row_id                       = AX.row_id
                   And b.Serv_Acct_Id                 = Cli.Row_Id
                   And b.status_cd                   In ('Activo','Suspendido')
                   And Nvl(Trim(ax.Attrib_42),'*')    = '*'
                   And ax.x_ocs_Attrib_59             Is Not Null
                   And Cli.ou_num_1                   = Cur_Rut;
                If Var_Contador = 0 Then
                    Var_CPE_MACVaciaEquipo := 0;
                ElsIf Var_Contador > 0 Then
                    Var_CPE_MACVaciaEquipo := 1;
                End If;
                Exception When Others Then
                    Var_CPE_MACVaciaEquipo := 0;
            End;
            Begin
                If Nvl(Trim(Cur_MacCM),'*') = '*' And Cur_MAC Is Not Null Then
                     Var_CPE_MACVaciaPromo := 1;
                Else
                     Var_CPE_MACVaciaPromo := 0;
                End If;
                Exception When Others Then
                    Var_CPE_MACVaciaPromo := 0;
            End;
            Begin
                If Nvl(Trim(Cur_MAC),'*') != '*' Then
                    Var_MismoMaterial := Cuadra.Cuf_Siebel_MismoMater( Cur_MAC
                                                                      ,Cur_Rut
                                                                      ,Cur_Asset_Num
                                                                      ,Cur_Root_Asset_Id
                                                                      ,Cur_Asset_Num );
                End If;
                Exception When Others Then
                    Null;
            End;
            --
            --
            Begin
                Var_Integration_ID := Cur_Integration;
                Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP CUI_SIEBEL_PROD_04) */
                       x_OCS_Flag_Retorno
                      ,X_OCS_CODIGO_LOCALIDAD
                      ,ADDR
                  Into Var_Flag_Retorno
                      ,Var_Localidad
                      ,Var_Direccion
                  From Cuadra.Cut_Siebel_ProductoP
                 Where Cuenta_Serv   = Cur_Name
                   And Root_Asset_Id = Cur_Root_Asset_Id
                   And x_ocs_categoria_detallada = 'Producto Principal'
                   And RowNum        = 1;
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Null;
            End;
--            Cuadra.Cup_LogInet(2,'Select Cut_Siebel_ProductoP');
            Begin
                Select 'S'
                  Into Var_Existe
                  From Cuadra.Cut_Siebel_ResultDetaInet
                 Where CPE = Upper(Cur_MAC);
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Begin
                        Insert Into Cuadra.Cut_Siebel_ResultDetaInet
                        (CPE
                        ,Unit_Addres
                        ,Marca
                        ,Modelo
                        ,Rut
                        ,ExternalObjectId
                        ,Row_Id)
                        Values
                        (Cur_MAC
                        ,Var_UnitAddr
                        ,Cur_Marca
                        ,Cur_Modelo
                        ,Cur_Rut
                        ,Var_Integration_ID
                        ,Cur_Row_Id);
                        If Sql%RowCount > 0 Then
                            Commit;
                        Else
                            Rollback;
                        End If;
                        Exception When Others Then
                            Rollback;
                    End;
            End;
            --
            -- Valida para la MAC Siebel la Existencia en UIM
            --
            Begin
                Var_CPE_DistEstado_SiebUIM := 0;
                Var_CPE_NoExiste_SiebUIM   := 0;
                Select Adminstate
                  Into Var_Adminstate
                  From Cuadra.Cut_UIM_Servicios
                 Where externalobjectid = Cur_Integration
                   And Adminstate Is Not Null
                   And Rownum           = 1;
                If Upper(Trim(Var_Adminstate)) = 'IN_SERVICE' And Upper(Trim(Cur_Status_CD)) != 'ACTIVO' Then
                    Var_CPE_DistEstado_SiebUIM := 1;
                ElsIf Upper(Trim(Var_Adminstate)) = 'SUSPENDED' And Upper(Trim(Cur_Status_CD)) != 'SUSPENDIDO' Then
                    Var_CPE_DistEstado_SiebUIM := 1;
                End If;
                Exception When Others Then
                    Var_CPE_DistEstado_SiebUIM := 0;
                    Var_CPE_NoExiste_SiebUIM   := 1;
            End;
            Begin
                Var_Velo_DownStream := '0';
                Select Char_Val
                  Into Var_Velo_DownStream
                  From S_Asset_XA
                 Where Asset_Id  = Cur_Row_Id
                   And Attr_Name = 'Downstream';
                If Sql%Found Then
                    Begin
                         Select Row_id
                           Into Var_Row_IdBeneficio
                           From Cut_Siebel_Productop
                          Where Ou_Num_1                  = Trim(Cur_Rut)
                            And X_Ocs_Categoria_Detallada = 'Try and Buy'
                            And Permitted_Type            = '/service/broadband'
                            And Root_Asset_Id             = Cur_Root_Asset_Id
                            And rownum                    = 1;
                         If Sql%Found Then
                             Begin
                                 Select Char_val
                                   Into Var_Velo_DownStreamTrial
                                   From S_Asset_XA
                                  Where Asset_Id  = Trim(Var_Row_IdBeneficio)
                                    And Attr_Name = 'Downstream';
                                 If Sql%found Then
                                     Var_Velo_DownStream := Var_Velo_DownStreamTrial;
                                 End If;
                                 Exception When Others Then
                                     Null;
                             End;
                         End If;
                         Exception When Others Then
                             Null;
                    End;
                End If;
                Exception When Others Then
                    Var_Velo_DownStream := '0';
            End;
            --
            --
            Var_ErrorNodo           := 0;
            Var_ErrorSubNodo        := 0;
            Var_ErrorMacAddress     := 0;
            Var_Flag_RoutingMode    := 0;
            Var_CPE_OtroRutServ_UIM := 0;
            Var_CPE_OtroRutServ_UIM := Cuadra.Cuf_Siebel_OtroRutINET_UIM(Cur_Rut,Var_Integration_ID);
            --
            --
            Var_CPE_ExistEBS := 0;

            Begin
                Var_CPE_ExistEBS := Cuf_Siebel_ExistMate_EBS(Cur_MAC);
                Exception When Others Then
                    Null;
            End;

            --
            --
            Begin
                Var_Es_FTTH := 'N';
                Select 'S'
                  into Var_Es_FTTH
                  From Cuadra.xVTR_Siebel_Info_Series_t
                 Where Cod_Serie = Cur_MAC
                   And TipoCPE   In ('WIFI ROUTER GW','VP','ONT');
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Var_Es_FTTH := 'N';
            End;
            --
            Begin
                Var_Flag_RoutingMode := 0;

                Select distinct e.row_id
                Into Var_Row_ID_MTARM
                From Cuadra.S_Org_Ext b, S_Asset c, S_Prod_Int d, S_Asset_X e
                Where c.Serv_Acct_Id   = b.Row_Id
                 and d.Row_Id          = c.Prod_Id
                 and e.Row_Id          = c.Row_Id
                 and b.Name            = Cur_Name
                 and e.x_ocs_attrib_59 = Cur_MAC
                 and b.Cust_Stat_cd    = 'Activo'
                 and c.Status_CD       in ('Activo')
                 and d.Name            = 'Equipo';
                 If Sql%Found Then
                  Begin
                        Select Replace(Nvl(Trim(Char_Val),'*'),'N/A','*')--Nvl(Trim(Char_Val),'*')
                          Into Var_RoutingMode
                          From Cuadra.S_Asset_XA
                         Where Asset_Id  = Var_Row_ID_MTARM
                           And Attr_Name = 'Routing Mode';
                        If Sql%Found Then
                            Null;
                        End If;
                        Exception When Others Then
                            Var_RoutingMode := '*';
                    End;
                 End If;
                 Exception When Others Then
                   Begin
                      Var_Flag_RoutingMode          := 0;
                      Var_RoutingMode               := '*';
                      If Var_Es_FTTH = 'N' Then
                          Var_CPE_Vacio_RoutingMode := 1;
                      End If;
                   End;
               /* Select Row_Id
                      ,Row_Id
                      ,Asset_Id
                      ,X_Ocs_Attrib_59
                  Into Var_Row_Id_MTA
                      ,Var_Row_ID_MTARM
                      ,Var_Asset_Id_MTA
                      ,Var_MAC
                  From Cuadra.Cut_Siebel_Equipos_MTA
                 Where x_ocs_attrib_59      = Cur_MAC
                   And Attr_Name            = 'Routing Mode'
                   And Rownum               = 1;
                If Sql%Found Then
                    Begin
                        Select Nvl(Trim(Char_Val),'*')
                          Into Var_RoutingMode
                          From Cuadra.S_Asset_XA
                         Where Row_Id = Var_Row_ID_MTARM;
                        If Sql%Found Then
                            Null;
                        End If;
                        Exception When Others Then
                            Var_RoutingMode := '*';
                    End;
                End If;
                Exception When Others Then
                    Begin
                        Var_Flag_RoutingMode := 0;
                        Select Row_Id
                              ,Row_Id
                              ,Asset_Id
                              ,X_Ocs_Attrib_59
                              ,Nvl(Trim(Char_Val),'*')
                          Into Var_Row_Id_MTA
                              ,Var_Row_ID_MTARM
                              ,Var_Asset_Id_MTA
                              ,Var_MAC
                              ,Var_RoutingMode
                          From Cuadra.Tmp_Equipos_MTA
                         Where Cod_Serie = Cur_MAC
                           And Attr_Name = 'Routing Mode';
                        If Sql%Found Then
                            Null;
                        End If;
                        Exception When Others Then
                            Var_Flag_RoutingMode      := 0;
                            Var_RoutingMode           := '*';
                            If Var_Es_FTTH = 'N' Then
                                Var_CPE_Vacio_RoutingMode := 1;
                            End If;
                    End;*/
            End;
            If Var_CPE_NoExiste_SiebUIM = 0 And Var_CPE_OtroRutServ_UIM = 0 And Var_Es_FTTH = 'N' Then
                --
                -- Valida para la MAC Siebel la Existencia en UIM
                --
                Var_Exist_MAC_UIM  := 0;
                Var_Flag_FTTH_IPTV := 'N';
                Begin
                    Select 'S'
                      Into Var_ExisteServ
                      From Cuadra.Cut_UIM_Servicios
                     Where ExternalObjectId = Var_Integration_ID;
                    If Sql%Found Then
                        If (Cur_Marca            ='NOKIA'
                        Or SubStr(Cur_MAC,1,5)  ='ALCLB'
                        Or  SubStr(Cur_MAC,1,4) ='SCOM') Then
                            Var_Flag_FTTH_IPTV := 'S';
                        Else
                            Var_Flag_FTTH_IPTV := 'N';
                        End If;
                        If Var_Flag_FTTH_IPTV = 'N' Then
                            Var_Exist_MAC_UIM := Cuf_Siebel_ExistMACInet_UIM(Cur_MAC,Var_Integration_ID);
                        End If;
                    End If;
                    Exception When Others Then
                      Var_Exist_MAC_UIM := 0;
                 End;

--              Cuadra.Cup_LogInet(4,'Cuf_Siebel_ExistMACInet_UIM');
                If Var_Exist_MAC_UIM = 0 And Var_Flag_FTTH_IPTV = 'N' Then
                    Begin
                        Var_Rut_Distinto := Cuf_Tango_DifRut(Cur_Rut,Var_Integration_ID);
                        Exception When Others Then
                            Var_Rut_Distinto := 0;
                    End;
                    Begin
                        Var_Ciclo_Inicio := Cuf_Siebel_CicloCero(Cur_Integration);
                        Exception When Others Then
                            Var_Ciclo_Inicio := 0;
                    End;
                    Begin
                        Var_ErrorNodo       := Cuf_Siebel_Valida_NodoUIM(Cur_Nmro_Nodo,Cur_Integration); --Cur_Integration
                        Var_ErrorSubNodo    := Cuf_Siebel_Valida_SubNodoUIM(Cur_Nmro_SubNodo,Cur_Integration);
                        Var_ErrorMacAddress := Cuf_Siebel_Valida_MacAddresUIM (Cur_MAC,Cur_Integration);
                        Exception When Others Then
                            Var_ErrorNodo       := 0;
                            Var_ErrorSubNodo    := 0;
                            Var_ErrorMacAddress := 0;
                    End;
                    If Var_RoutingMode != '*' Then
                        Var_Flag_RoutingMode := Cuadra.Cuf_Siebel_RoutingMode_UIM( Var_Integration_ID
                                                                                  ,Var_RoutingMode
                                                                                  ,Cur_MAC
                                                                                  ,Var_Row_Id_MTA
                                                                                  ,Var_Asset_Id_MTA);
                    Else
                        Var_Flag_RoutingMode      := 0;
                        Var_CPE_Vacio_RoutingMode := 1;
                    End If;
                    --
                    --
                    Var_CPE_ErrorRetorno := Cuadra.Cuf_Siebel_InetRetorno_UIM(Var_Integration_ID,Var_Flag_Retorno);
                    --
                    --
                    Var_MacDupli_UIM := Cuadra.Cuf_Siebel_MacDupli_UIM( Cur_MAC,Cur_Rut,Var_Integration_ID );
                    --
                    --
                    If Nvl(Trim(Cur_Modelo),'*') != '*' Then
                        Var_CPE_Misma_Marca := Cuadra.Cuf_Siebel_MarcaInet_UIM(Cur_MAC,Nvl(Trim(Cur_Marca),'*'),Var_Integration_ID);
                    End If;
                    --
                    --
                    If Nvl(Trim(Cur_Modelo),'*') != '*' Then
                        Var_CPE_Mismo_Modelo := Cuadra.Cuf_Siebel_ModeloInet_UIM(Cur_MAC,Nvl(Trim(Cur_Modelo),'*'),Var_Integration_ID);
                    End If;
                    --
                    --
                    Var_Flag_CPETechnology := 0;
                    Begin
                        Select Char_Val
                              ,Row_Id
                              ,Asset_Id
                              ,X_Ocs_Attrib_59
                          Into Var_CPETechnology
                              ,Var_Row_Id_MTA
                              ,Var_Asset_Id_MTA
                              ,Var_MAC
                          From Cuadra.Cut_Siebel_Equipos_MTA
                         Where Asset_Integration_ID = Cur_Asset_Num
                           And Attr_Name            = 'CPE Technology';
                        If Sql%Found Then
                            Var_Flag_CPETechnology := Cuadra.Cuf_Siebel_Caract_UIM(1,Var_Integration_ID,Var_CPETechnology,Cur_MAC);
                        End If;
                        Exception When Others Then
                            Var_Flag_CPETechnology := 0;
                    End;
                    --
                    Begin
                        Begin
                            Select b.Char_Val
                              Into Var_DocsisSiebel
                              From Cuadra.S_Asset a,
                                   Cuadra.S_Asset_XA b
                             Where a.Row_id    = Cur_Row_id
                               And b.Asset_Id  = a.row_id
                               And b.Attr_Name = 'CPE Technology';
                            If Sql%Found Then
                                Var_Flag_DocsisSieUIM := Cuadra.Cuf_Siebel_Docsis_UIM(Cur_MAC,
                                                                                      Var_DocsisSiebel,
                                                                                      Var_Integration_ID);
                            End If;
                            Exception When Others Then
                                Var_Flag_DocsisSieUIM := 0;
                        End;
                        Exception When Others Then
                            Var_Flag_DocsisSieUIM := 0;
                    End;                --
                    --
                    Var_Flag_CPEType := 0;
                    Begin
                        Select Char_Val
                              ,Row_Id
                              ,Asset_Id
                              ,X_Ocs_Attrib_59
                          Into Var_CPEType
                              ,Var_Row_Id_MTA
                              ,Var_Asset_Id_MTA
                              ,Var_MAC
                          From Cuadra.Cut_Siebel_Equipos_MTA
                         Where Asset_Integration_ID = Cur_Asset_Num
                           And Attr_Name            = 'CPE Type';
                        If Sql%Found Then
                            Var_Flag_CPEType := Cuf_Siebel_Tipo_UIM(Cur_MAC,Var_CPEType,Var_CPEType,Var_Integration_ID);
                        End If;
                        Exception When Others Then
                            Var_Flag_CPEType := 0;
                    End;
                    --
                    --
                    Var_CPE_EnOtroRut := 0;
                    --
                    --
                    Var_CPE_DistinVeloSiebUIM := 0;
                    Var_CPE_DistinVeloSiebUIM := Cuadra.Cuf_Siebel_Caract_UIM(4,Var_Integration_ID,Var_Velo_DownStream,Cur_MAC);
                    --
                    --
                Else
                    Var_Flag_RoutingMode       := 0;
                    Var_MacDupli_UIM           := 0;
                    Var_CPE_Misma_Marca        := 0;
                    Var_CPE_Mismo_Modelo       := 0;
                    Var_Flag_CPETechnology     := 0;
                    Var_Flag_CPEType           := 0;
                    Var_CPE_EnOtroRut          := 0;
                    Var_CPE_DistinVeloSiebUIM  := 0;
                    Var_CPE_OtroRutServ_UIM    := 0;
                    Var_CPE_DistEstado_SiebUIM := 0;
                    Var_CPE_NoExiste_SiebUIM   := 0;
                End If;
            Else
                Begin
                    Select /*+ INDEX(Cuadra.Cut_UIM_RFS Cui_UIM_RFS_01) */
                           a.ExternalObjectID
                      Into Var_External_Actual
                      From Cuadra.Cut_Uim_Rfs a
                     Where a.Caracteristica   = 'CPESerialNumber'
                       And a.Value            = Cur_Mac
                       And RowNum           = 1;
                    If Sql%Found Then
                        Var_Exist_MAC_UIM := 0;
                    End If;
                    Exception When Others Then
                        Var_CPE_NoExiste_SiebUIM := 0;

                End;
                Var_Flag_RoutingMode       := 0;
                Var_MacDupli_UIM           := 0;
                Var_CPE_Misma_Marca        := 0;
                Var_CPE_Mismo_Modelo       := 0;
                Var_Flag_CPETechnology     := 0;
                Var_Flag_CPEType           := 0;
                Var_CPE_EnOtroRut          := 0;
                Var_CPE_DistinVeloSiebUIM  := 0;
                Var_CPE_DistEstado_SiebUIM := 0;
            End If;
            Begin
                Update Cuadra.Cut_Siebel_ResultDetaInet
                   Set Rut_UIM = Var_RutAux
                 Where CPE = Cur_MAC;
                If Sql%RowCount > 0 Then
                    Commit;
                Else
                    Rollback;
                End If;
                Exception When Others Then
                    Rollback;
            End;
            --
            --
            Var_ErrorEquiPromo         := 1;
            Var_PromoInetSinEquipo     := 0;
            Var_SwTieneEquipo          := 0;
            Var_PromoInetIgualEquInact := 0;
            Var_PromoInetEquInact      := 0;
            Open Cur_Inet_ErrorMaterial;
            Loop
            Fetch Cur_Inet_ErrorMaterial
             Into Cur_RutInet
                 ,Cur_MACInet;
            Exit When Cur_Inet_ErrorMaterial%NotFound;
            Begin
                Var_PromoInetSinEquipo := 0;
                Var_SwTieneEquipo      := 1;
                If Cur_MAC = Cur_MACInet Then
                    Var_ErrorEquiPromo := 0;
                End If;
                Exception When Others Then
                    Null;
            End;
            End Loop;
            Close Cur_Inet_ErrorMaterial;
            --
            If Var_SwTieneEquipo  = 0 Then
                Var_ErrorEquiPromo := 0;
                Open Cur_Siebel_MACBaja;
                Loop
                Fetch Cur_Siebel_MACBaja
                 Into Cur_EstadoMatPromo
                     ,Cur_SerieEquipo;
                Exit When Cur_Siebel_MACBaja%NotFound;
                Begin
                    If Cur_EstadoMatPromo = 'Inactivo' Then
                        If Cur_SerieEquipo = Cur_MAC Then
                            Var_PromoInetIgualEquInact := 1;
                        Else
                            Var_PromoInetEquInact := 1;
                        End If;
                    End If;
                    Exception When Others Then
                        Null;
                End;
                End Loop;
                Close Cur_Siebel_MACBaja;
            End If;
            --
/*
            Var_CPE_NoExisteIncognito     := 0;
            Var_CPE_DuplicadaIncognito    := 0;
            Var_CPE_RutDistinIncognito    := 0;
            Var_CPE_EstadoDistinIncognito := 0;
            Var_CPE_LocaDistinIncognito   := 0;
            Var_CPE_MarcaDistinIncognito  := 0;
            Var_CPE_ModeloDistinIncognito := 0;
            Var_CPE_RoutingModeIncognito  := 0;
            Var_CPE_DistinVeloSiebIncog   := 0;
            Var_CPE_ErrorDocsis           := 0;
            Var_ErrorModeloDocsis         := 0;
            Begin
                Var_Ejec_Incognito := 'N';
                Select 'S'
                  Into Var_Ejec_Incognito
                  From Cuadra.Xvtr_Siebel_Info_Series_t
                 Where Cod_Serie = Cur_MAC
                   And Tecnologia != 'GPON 1.0';
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Var_Ejec_Incognito := 'N';
            End;
            If Var_ErrorEquiPromo = 0 And Var_Ejec_Incognito = 'S' Then
                Begin
                    Var_Result_Incognito := CUF_SIEBEL_ESTDINET_INCOG
                                            ( Cur_MAC
                                             ,Cur_Rut
                                             ,Var_Localidad
                                             ,Cur_Status_CD
                                             ,Var_RoutingMode
                                             ,Cur_Marca
                                             ,Cur_Modelo
                                             ,Var_Velo_DownStream
                                             ,Cur_Row_Id
                                             ,Cur_Root_Asset_Id);
                    Var_CPE_NoExisteIncognito     := Substr(Var_Result_Incognito,1,1);
                    Var_CPE_DuplicadaIncognito    := Substr(Var_Result_Incognito,2,1);
                    Var_CPE_RutDistinIncognito    := Substr(Var_Result_Incognito,3,1);
                    Var_CPE_EstadoDistinIncognito := Substr(Var_Result_Incognito,4,1);
                    Var_CPE_LocaDistinIncognito   := Substr(Var_Result_Incognito,5,1);
                    Var_CPE_MarcaDistinIncognito  := Substr(Var_Result_Incognito,6,1);
                    Var_CPE_ModeloDistinIncognito := Substr(Var_Result_Incognito,7,1);
                    Var_CPE_RoutingModeIncognito  := Substr(Var_Result_Incognito,8,1);
                    Var_CPE_DistinVeloSiebIncog   := Substr(Var_Result_Incognito,9,1);
                    Var_CPE_ErrorDocsis           := Substr(Var_Result_Incognito,10,1);
                    Var_ErrorModeloDocsis         := Substr(Var_Result_Incognito,11,1);
                    Var_RoutingMode_Incog         := Substr(Var_Result_Incognito,13,20);
                    Var_Marca_Incog               := Substr(Var_Result_Incognito,33,20);
                    Var_Modelo_Incog              := Substr(Var_Result_Incognito,53,20);
                    Var_Veloc_Incog               := Substr(Var_Result_Incognito,73,20);
                    Var_Velo_DownStream_Incog     := Substr(Var_Result_Incognito,93,20);
                    Var_CPE_ConServicioFonoActivo := Substr(Var_Result_Incognito,113,10);
                    If Var_CPE_NoExisteIncognito = 1 Then
                        Var_CPE_DuplicadaIncognito    := 0;
                        Var_CPE_RutDistinIncognito    := 0;
                        Var_CPE_EstadoDistinIncognito := 0;
                        Var_CPE_LocaDistinIncognito   := 0;
                        Var_CPE_MarcaDistinIncognito  := 0;
                        Var_CPE_ModeloDistinIncognito := 0;
                        Var_CPE_RoutingModeIncognito  := 0;
                        Var_CPE_DistinVeloSiebIncog   := 0;
                    End If;
                    --
                    --
                    Begin
                        Update Cuadra.Cut_Siebel_ResultDetaInet
                           Set RoutingMode_Incog = trim(Var_RoutingMode_Incog)
                              ,Marca_Incog       = trim(Var_Marca_Incog)
                              ,Modelo_Incog      = trim(Var_Modelo_Incog)
                              ,Velocidad_Inc     = trim(Var_Veloc_Incog)
                              ,Velocidad_Sie     = trim(Var_Velo_DownStream_Incog)
                              ,Flag_ConServ_Fono = Var_CPE_ConServicioFonoActivo
                              ,Row_Id_MTA        = Var_Row_ID_MTARM
                              ,RoutingMode       = trim(Var_RoutingMode)
                        Where CPE = Upper(Cur_MAC);
                       If Sql%RowCount > 0 Then
                           Commit;
                       Else
                           Rollback;
                       End If;
                       Exception When Others Then
                           Rollback;
                    End;
                    --
                    If Var_RoutingMode = '*' Then
                        Var_CPE_RoutingModeIncognito := 0;
                    End If;
                    Exception When Others Then
                        Null;
                End;
            End If;
*/
            --
            --
            Var_CPE_Duplicada_Siebel := 0;
            Open Cur_Siebel_Duplicada;
            Loop
            Fetch Cur_Siebel_Duplicada
             Into Cur_MAC_Dupli
                 ,Cur_Nmros_CPE;
            Exit When Cur_Siebel_Duplicada%NotFound;
            Begin
                Var_CPE_Duplicada_Siebel := 1;
                Exit;
            End;
            End Loop;
            Close Cur_Siebel_Duplicada;
            --
            --
            Begin
                If Var_Exist_MAC_UIM = 1 Or Var_CPE_Misma_Marca = 1 Or Var_CPE_Mismo_Modelo = 1
                Or Var_CPE_EnOtroRut = 1 Or Var_CPE_DistEstado_SiebUIM = 1 Or Var_CPE_NoExiste_SiebUIM = 1
                Or Var_CPE_OtroRutServ_UIM = 1 Or Var_Flag_CPETechnology = 1 Or Var_Flag_CPEType = 1
                Or Var_CPE_Duplicada_Siebel = 1 Or Var_Flag_RoutingMode = 1 Or Var_CPE_NoExisteIncognito = 1
                Or Var_CPE_DuplicadaIncognito = 1 Or Var_CPE_RutDistinIncognito = 1
                Or Var_CPE_EstadoDistinIncognito = 1 Or Var_CPE_LocaDistinIncognito = 1
                Or Var_CPE_MarcaDistinIncognito = 1 Or Var_CPE_ModeloDistinIncognito = 1
                Or Var_CPE_RoutingModeIncognito = 1 Or Var_CPE_DistinVeloSiebUIM = 1
                Or Var_CPE_DistinVeloSiebIncog = 1 Or Var_CPE_ErrorDocsis = 1 Or Var_ErrorModeloDocsis = 1
                Or Var_Flag_DocsisSieUIM = 1 Or Var_CPE_ErrorRetorno = 1 Or Var_CPE_MACVaciaEquipo = 1
                Or Var_CPE_MACVaciaPromo = 1 Or Var_CPE_ExistEBS = 1 or Var_CPE_Vacio_RoutingMode = 1 Then
                    Var_CPE_Con_Error := 1;
                Else
                    Var_CPE_Con_Error := 0;
                End If;
                --
                --
                Select 'S'
                  Into Var_Existe
                  From Cuadra.Cut_Siebel_ResultInet
                 Where CPE = Cur_MAC;
                If Sql%Found Then
                    Begin
                        Update Cuadra.Cut_Siebel_ResultInet
                           Set CPE_NoExist_UIM              = Var_Exist_MAC_UIM
                              ,CPE_Distinta_Marca           = Var_CPE_Misma_Marca
                              ,CPE_Distinto_Modelo          = Var_CPE_Mismo_Modelo
                              ,Codi_Localidad               = Var_Localidad
                              ,Desc_Direccion               = Var_Direccion
                              ,Indica_Serv_EnSiebel         = Cur_x_Ocs_SubClase
                              ,CPE_EnOtro_RUT               = Var_CPE_EnOtroRut
                              ,CPE_OtroRutServ_UIM          = Var_CPE_OtroRutServ_UIM
                              ,CPE_DistEstado_SiebUIM       = Var_CPE_DistEstado_SiebUIM
                              ,CPE_NoExiste_SiebUIM         = 0
                              ,CPE_Distinta_Tecnologia      = 0 --Var_Flag_CPETechnology
                              ,CPE_Distinto_TipoMaterial    = Var_Flag_CPEType
                              ,CPE_Vacia                    = 0
                              ,CPE_Duplicada_Siebel         = Var_CPE_Duplicada_Siebel
                              ,CPE_Distinto_RoutingMode     = Var_Flag_RoutingMode
                              ,CPE_NoExisteIncognito        = Var_CPE_NoExisteIncognito
                              ,CPE_DuplicadaIncognito       = Var_CPE_DuplicadaIncognito
                              ,CPE_RutDistinIncognito       = Var_CPE_RutDistinIncognito
                              ,CPE_EstadoDistinIncognito    = Var_CPE_EstadoDistinIncognito
                              ,CPE_LocaDistinIncognito      = Var_CPE_LocaDistinIncognito
                              ,CPE_MarcaDistinIncognito     = Var_CPE_MarcaDistinIncognito
                              ,CPE_ModeloDistinIncognito    = Var_CPE_ModeloDistinIncognito
                              ,CPE_RoutingModeIncognito     = Var_CPE_RoutingModeIncognito
                              ,CPE_DistinVeloSiebUIM        = Var_CPE_DistinVeloSiebUIM
                              ,CPE_DistinVeloSiebInc        = Var_CPE_DistinVeloSiebIncog
                              ,CPE_ErrorDocsis              = Var_CPE_ErrorDocsis
                              ,CPE_ErrorModeloDocsis        = Var_ErrorModeloDocsis
                              ,CPE_ErrorDocsisUIM           = Var_Flag_DocsisSieUIM
                              ,CPE_ErrorFlagRetorno         = Var_CPE_ErrorRetorno
                              ,CPE_Con_Error                = Var_CPE_Con_Error
                              ,CPE_ErrorEquiPromo           = Var_ErrorEquiPromo
                              ,Cuenta_Serv                  = Cur_Name
                              ,Integration_ID               = Cur_Integration
                              ,Serv_Acct_ID                 = Cur_Serv_Acct_ID
                              ,PromoInetSinEquipo           = Var_PromoInetSinEquipo
                              ,PromoInetEquInact            = Var_PromoInetEquInact
                              ,PromoInetIgualEquInact       = Var_PromoInetIgualEquInact
                              ,CPE_ErrorNodo                = Var_ErrorNodo
                              ,CPE_ErrorSubNodo             = Var_ErrorSubNodo
                              ,CPE_ErrorMacAddress          = Var_ErrorMacAddress
                              ,Ciclo_Inicio                 = Var_Ciclo_Inicio
                              ,Rut_Distinto                 = 0
                              ,CPE_ExistEBS                 = Var_CPE_ExistEBS
                              ,CPE_MACVaciaEquipo           = Var_CPE_MACVaciaEquipo
                              ,CPE_MACVaciaPromo            = Var_CPE_MACVaciaPromo
                              ,CPE_Vacio_RoutingMode        = Var_CPE_Vacio_RoutingMode
                         Where CPE         = Cur_MAC
                           And rut_persona = Cur_Rut;
                        If Sql%RowCount > 0 Then
                            Commit;
                        End If;
                        Exception When Others Then
                            Rollback;
                    End;
                End If;
                Exception When No_Data_Found Then
                    Begin
                        Insert Into Cuadra.Cut_Siebel_ResultInet
                        ( CPE
                         ,Row_Id
                         ,Unit_Addres
                         ,Rut_Persona
                         ,Codi_Localidad
                         ,Desc_Direccion
                         ,Indica_Serv_EnSiebel
                         ,Cuenta_Serv
                         ,Integration_ID
                         ,Serv_Acct_ID
                         ,CPE_Vacia
                         ,CPE_NoExist_UIM
                         ,CPE_Distinta_Marca
                         ,CPE_Distinto_Modelo
                         ,CPE_EnOtro_RUT
                         ,CPE_DistEstado_SiebUIM
                         ,CPE_NoExiste_SiebUIM
                         ,CPE_OtroRutServ_UIM
                         ,CPE_Distinta_Tecnologia
                         ,CPE_Distinto_TipoMaterial
                         ,CPE_Duplicada_Siebel
                         ,Nmro_Duplicadas
                         --,CPE_Duplicada_MismoRut
                         ,CPE_Duplicada_OtroRut
                         ,CPE_Duplicada_CtaServ
                         ,CPE_Servicio_DistEstd
                         ,CPE_Noexist_Brm
                         ,CPE_SinProdPrin
                         ,CPE_Distinto_RoutingMode
                         ,CPE_NoExisteIncognito
                         ,CPE_DuplicadaIncognito
                         ,CPE_RutDistinIncognito
                         ,CPE_EstadoDistinIncognito
                         ,CPE_LocaDistinIncognito
                         ,CPE_MarcaDistinIncognito
                         ,CPE_ModeloDistinIncognito
                         ,CPE_RoutingModeIncognito
                         ,CPE_DistinVeloSiebUIM
                         ,CPE_DistinVeloSiebInc
                         ,CPE_ErrorDocsis
                         ,CPE_ErrorModeloDocsis
                         ,CPE_ErrorDocsisUIM
                         ,CPE_ErrorFlagRetorno
                         ,CPE_ErrorEquiPromo
                         ,PromoInetIgualEquInact
                         ,PromoInetSinEquipo
                         ,PromoInetEquInact
                         ,CPE_ErrorNodo
                         ,CPE_ErrorSubNodo
                         ,CPE_ErrorMacAddress
                         ,Ciclo_Inicio
                         ,Rut_Distinto
                         ,CPE_ExistEBS
                         ,CPE_MACVaciaEquipo
                         ,CPE_MACVaciaPromo
                         ,CPE_Vacio_RoutingMode
                         ,CPE_Con_Error )
                        Values
                        ( Cur_MAC
                         ,Cur_Row_Id
                         ,Var_UnitAddr
                         ,Trim(Cur_Rut)
                         ,Trim(Var_Localidad)
                         ,Trim(Var_Direccion)
                         ,Cur_x_Ocs_SubClase
                         ,Cur_Name
                         ,Cur_Integration
                         ,Cur_Serv_Acct_ID
                         ,0
                         ,Var_Exist_MAC_UIM
                         ,Var_CPE_Misma_Marca
                         ,Var_CPE_Mismo_Modelo
                         ,Var_CPE_EnOtroRut
                         ,Var_CPE_DistEstado_SiebUIM
                         ,0
                         ,Var_CPE_OtroRutServ_UIM
                         ,0  --Var_Flag_CPETechnology
                         ,Var_Flag_CPEType
                         ,Var_CPE_Duplicada_Siebel
                         ,0
                         --,0
                         ,0
                         ,0
                         ,0
                         ,0
                         ,0
                         ,Var_Flag_RoutingMode
                         ,Var_CPE_NoExisteIncognito
                         ,Var_CPE_DuplicadaIncognito
                         ,Var_CPE_RutDistinIncognito
                         ,Var_CPE_EstadoDistinIncognito
                         ,Var_CPE_LocaDistinIncognito
                         ,Var_CPE_MarcaDistinIncognito
                         ,Var_CPE_ModeloDistinIncognito
                         ,Var_CPE_RoutingModeIncognito
                         ,Var_CPE_DistinVeloSiebUIM
                         ,Var_CPE_DistinVeloSiebIncog
                         ,Var_CPE_ErrorDocsis
                         ,Var_ErrorModeloDocsis
                         ,Var_Flag_DocsisSieUIM
                         ,Var_CPE_ErrorRetorno
                         ,Var_ErrorEquiPromo
                         ,Var_PromoInetIgualEquInact
                         ,Var_PromoInetSinEquipo
                         ,Var_PromoInetEquInact
                         ,Var_ErrorNodo
                         ,Var_ErrorSubNodo
                         ,Var_ErrorMacAddress
                         ,Var_Ciclo_Inicio
                         ,0
                         ,Var_CPE_ExistEBS
                         ,Var_CPE_MACVaciaEquipo
                         ,Var_CPE_MACVaciaPromo
                         ,Var_CPE_Vacio_RoutingMode
                         ,Var_CPE_Con_Error );
                        Commit;
                        Exception When Others Then
                            Rollback;
                    End;
                When Others Then
                    Rollback;
            End;
            --
            --
            Exception When Others Then
                Null;
        End;
        End Loop;
        Close Cur_Siebel_Inet;
--      Raise_Application_error(-20001,'Termino Forzado del Proceso');
--
--
        Open Cur_Inet_SinMaterial;
        Loop
        Fetch Cur_Inet_SinMaterial
         Into Cur_Rut
             ,Cur_Integration_ID
             ,Cur_Asset_Integration_ID
             ,Cur_MAC

             ,Cur_Serv_Acct_ID
             ,Cur_Name;
        Exit When Cur_Inet_SinMaterial%NotFound;
        Begin
            Begin
                Insert Into Cuadra.Cut_Siebel_ResultInet
                ( CPE
                 ,Row_Id
                 ,Unit_Addres
                 ,Rut_Persona
                 ,Codi_Localidad
                 ,Desc_Direccion
                 ,Indica_Serv_EnSiebel
                 ,Cuenta_Serv
                 ,Integration_ID
                 ,Serv_Acct_ID
                 ,CPE_Vacia
                 ,CPE_NoExist_UIM
                 ,CPE_Distinta_Marca
                 ,CPE_Distinto_Modelo
                 ,CPE_EnOtro_RUT
                 ,CPE_DistEstado_SiebUIM
                 ,CPE_NoExiste_SiebUIM
                 ,CPE_OtroRutServ_UIM
                 ,CPE_Distinta_Tecnologia
                 ,CPE_Distinto_TipoMaterial
                 ,CPE_Duplicada_Siebel
                 ,Nmro_Duplicadas
                 --,CPE_Duplicada_MismoRut
                 ,CPE_Duplicada_OtroRut
                 ,CPE_Duplicada_CtaServ
                 ,CPE_Servicio_DistEstd
                 ,CPE_Noexist_Brm
                 ,CPE_SinProdPrin
                 ,CPE_Distinto_RoutingMode
                 ,CPE_NoExisteIncognito
                 ,CPE_DuplicadaIncognito
                 ,CPE_RutDistinIncognito
                 ,CPE_EstadoDistinIncognito
                 ,CPE_LocaDistinIncognito
                 ,CPE_MarcaDistinIncognito
                 ,CPE_ModeloDistinIncognito
                 ,CPE_RoutingModeIncognito
                 ,CPE_DistinVeloSiebUIM
                 ,CPE_DistinVeloSiebInc
                 ,CPE_ErrorDocsis
                 ,CPE_ErrorModeloDocsis
                 ,CPE_ErrorFlagRetorno
                 ,CPE_Con_Error )
                Values
                ( '999999'
                 ,Null
                 ,Null
                 ,Cur_Rut
                 ,Null
                 ,Null
                 ,0
                 ,Cur_Name
                 ,Cur_Integration_ID
                 ,Cur_Serv_Acct_ID
                 ,1
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 --,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,0
                 ,1 );
                Commit;
                Exception When Others Then
                    Rollback;
            End;
        End;
        End Loop;
        Close Cur_Inet_SinMaterial;
    End If;
    --
    --
    Open Cur_Update;
    Loop
    Fetch Cur_Update
     Into Cur_MAC,
          Cur_CPE_MarcaDistinIncognito,
          Cur_CPE_DuplicadaIncognito,
          Cur_CPE_LocaDistinIncognito,
          Cur_CPE_RutDistinIncognito,
          Cur_Cpe_RoutingModeIncognito,
          Cur_CPE_DistinVeloSiebIncog,
          Cur_Cpe_Modelodistintincognito,
          Cur_Cpe_Noexisteincognito;
    Exit When Cur_Update%NotFound;
    Begin
        Begin    
            If Cur_Cpe_Noexisteincognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set Cpe_Noexisteincognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_CPE_DuplicadaIncognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set CPE_DuplicadaIncognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_CPE_LocaDistinIncognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set CPE_LocaDistinIncognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_CPE_RutDistinIncognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set CPE_RutDistinIncognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_CPE_DistinVeloSiebIncog = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set CPE_DISTINVELOSIEBINC = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_CPE_MarcaDistinIncognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set CPE_MarcaDistinIncognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_Cpe_Modelodistintincognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set Cpe_Modelodistinincognito = 1
                 Where CPE = Cur_MAC;
            ElsIf Cur_Cpe_RoutingModeIncognito = 1 Then
                Update Cuadra.Cut_Siebel_ResultInet
                   Set Cpe_RoutingModeIncognito = 1
                 Where CPE = Cur_MAC;
            End If;
            If Sql%Rowcount > 0 Then
                Commit;
            Else
                Rollback;
            End If;
            Exception When Others Then
                Rollback;
        End;
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Update;
    --
    --
/*    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set CPE_MarcaDistinIncognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where CPE_MarcaDistinIncognito = 1);
                                                                      --Where Marca != Marca_Incog);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    --
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set CPE_DuplicadaIncognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where CPE_DuplicadaIncognito = 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    --
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set CPE_LocaDistinIncognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where CPE_LocaDistinIncognito = 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    --
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set CPE_RutDistinIncognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where CPE_RutDistinIncognito = 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    --
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set CPE_RoutingModeIncognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where RoutingMode != RoutingMode_Incog  and RoutingMode!='*' and Cpe_RoutingModeIncognito = 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;

    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set  CPE_DISTINVELOSIEBINC = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where CPE_DistinVeloSiebIncog = 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    
   /* Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set  Cpe_Modelodistinincognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where Cpe_Modelodistintincognito= 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set   Cpe_Noexisteincognito = 1
         Where CPE in (Select CPE From Cuadra.Cut_Siebel_ResultDetaInet Where Cpe_Noexisteincognito= 1);
        If Sql%RowCount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;   
    
    */

--    Begin
--        Update Cuadra.Cut_Siebel_ResultInet
--        set CPE_DuplicadaIncognito=0
--        Where CPE_DuplicadaIncognito is null;
--        If Sql%RowCount > 0 Then
--            Commit;
--        Else
--            Rollback;
--        End If;
--        Exception When Others Then
--            Rollback;
--    End;

--    Begin
--        Update Cuadra.Cut_Siebel_ResultInet
--        set cpe_rutdistinincognito=0
--        Where cpe_rutdistinincognito is null;
--        If Sql%RowCount > 0 Then
--            Commit;
--        Else
--            Rollback;
--        End If;
--        Exception When Others Then
--            Rollback;
--    End;
--    Begin
--        Update Cuadra.Cut_Siebel_ResultInet
--        set cpe_distinvelosiebinc=0
--        Where cpe_distinvelosiebinc is null;
--        If Sql%RowCount > 0 Then
--            Commit;
--        Else
--            Rollback;
--        End If;
--        Exception When Others Then
--            Rollback;
--    End;
--    Begin
--        Update Cuadra.Cut_Siebel_ResultInet
--        set cpe_noexisteincognito=0
--        Where cpe_noexisteincognito is null;
--        If Sql%RowCount > 0 Then
--            Commit;
--        Else
--            Rollback;
--        End If;
--        Exception When Others Then
--            Rollback;
--    End;

--    Begin
--        Update Cuadra.Cut_Siebel_ResultInet
--        set cpe_locadistinincognito=0
--        where cpe_locadistinincognito is null;
--        If Sql%RowCount > 0 Then
--            Commit;
--        Else
--            Rollback;
--        End If;
--        Exception When Others Then
--            Rollback;
--    End;
    Exception When Others Then
        Null;
End;