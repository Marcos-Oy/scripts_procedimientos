CREATE OR REPLACE PROCEDURE CUADRA.Cup_Siebel_Analiza_TV_DAC
IS
--
Var_CPE_NoExist_DAC              Number(1);
Var_Error_VCMLab                 Number(1);
Var_CPE_Activated                Number(1);
Var_CPE_OnPlant                  Number(1);
Var_CPE_Handles                  Number(1);
Var_Error_Programac              VarChar2(250);
Var_Error_Canal_Programac        VarChar2(250);
--
Var_Exist_Dac                    Number(1);
Var_ExisteMacDac                 Number(1);
Var_Onplant                      Number(1);
Var_activated                    Number(1);
Var_Handles                      Number(1);
Var_MacSiebelInactivoDac         Number(1);
Var_MacSiebelSinPlanDac          Number(1);
Var_MacSiebelConHandlesVacio     Number(1);
Var_Vcm_Lab                      Number(1);
Var_Channelpack                  Number(1);
Var_MacSiebelSinPackHD           Number(1);
Var_MacSiebelNoTieneHDdac        Number(1);

Var_Row_id                       VarChar2(15);
Var_GridType                     VarChar2(20);
Var_Integration_Id               VarChar2(30);
Var_MacSiebelNombrepack          VarChar2(100);
Var_MacSiebelCodigopack          VarChar2(100);
Var_Con_OrdenPend                Number(1);
Var_Con_OrdenPend01              Number(6);
Var_Con_OrdenPend02              Number(6);
--
Var_Falta_Prog                   Number(1);
Var_Falta_Prog_Grilla            Number(1);
Var_Paqu_Faltante_Grilla         VarChar2(250);
--
Var_CPE_Nmro_Error               Number(4);
Var_CPE_Con_Error                Number(1);
------------------------------------------------------
Cur_MAC                          VarChar2(100);
Cur_UnitAddr                     VarChar2(250);
Cur_Name                         VarCHar2(100);
Cur_Rut                          VarChar2(30);
Cur_Marca                        VarChar2(100);
Cur_Modelo                       VarChar2(100);
Cur_Root_Asset_Id                VarChar2(15);
Cur_x_Ocs_SubClase               VarChar2(30);
Cur_Row_Id                       VarChar2(15);
Cur_Status_CD                    VarChar2(30);
Cur_Tipo_dBox                    VarChar2(255);
Cur_Tipo_Tecno_dBox              VarChar2(255);
Cur_Codigo_Canal                 VarChar2(100);
Cur_Nombre_Canal                 VarChar2(100);
--
Cur_Codi_Paquete                 Number(10);
--
Cursor Cur_Siebel_dBox
Is
    Select a.x_Ocs_Attrib_59
          ,a.x_Ocs_Attrib_61
          ,a.Name
          ,a.Ou_Num_1
          ,a.Attrib_44
          ,a.Attrib_45
          ,a.Root_Asset_Id
          ,a.x_Ocs_SubClase
          ,a.Row_Id
          ,a.Status_CD
          ,a.desc_text
          ,a.sp_num
     From Cuadra.Cut_Siebel_dBox a
     Where a.x_Ocs_Attrib_59     Is Not Null
       And a.Status_CD           In ('Activo')
       And a.x_Ocs_Cod_Tipo_Item Not In ('DBOXEOS','DBOXIPTV')
       And Not Exists (Select * From Rut_Excluidos b Where b.Rut_Persona = a.ou_num_1);
--     And a.x_Ocs_Attrib_59 in ('M11107TD8868');
--
Cursor Cur_Siebel_Canales
Is
    Select b.Paquete
          ,b.ChannelPacks
      From Cuadra.Cut_Siebel_Canales a, Cut_GrillaCanales b
     Where a.Rut_Cte         = Cur_Rut
       And a.Cuenta_Servicio = Cur_Name
       And a.Part_Num        = b.ChannelPacks(+)
       And b.plataforma      = 'DAC'
       And  b.Paquete not in ('50060','50038','50037','50277','333346','100225');
--
Cursor Cur_Grilla
Is
    Select /*+ INDEX(Cuadra.GIAP_TRADUCTOR cui_traductor02) */
           Rec_Codigo
      From Cuadra.GIAP_TRADUCTOR
     Where Trd_Tag_Name = 'GRIDTYPE'
       And Pla_Codigo   = 'DAC'
       And Prd_Tag_Value = Upper(Trim(Var_GridType))
       And Rec_Codigo is not null; 
--
--
Begin
    Begin
        Delete from Cuadra.Cut_Siebel_ResultTVDac; -- where cpe in ('M11107TD8868');
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Open Cur_Siebel_dBox;
    Loop
    Fetch Cur_Siebel_dBox
     Into Cur_MAC
         ,Cur_UnitAddr
         ,Cur_Name
         ,Cur_Rut
         ,Cur_Marca
         ,Cur_Modelo
         ,Cur_Root_Asset_Id
         ,Cur_x_Ocs_SubClase
         ,Cur_Row_Id
         ,Cur_Status_CD
         ,Cur_Tipo_dBox
         ,Cur_Tipo_Tecno_dBox;
    Exit When Cur_Siebel_dBox%NotFound;
    Begin
        Var_Error_Programac          := Null;
        Var_Error_Canal_Programac    := Null;
        Var_Error_VCMLab             := 0;
        Var_CPE_Activated            := 0;
        Var_CPE_OnPlant              := 0;
        Var_CPE_Handles              := 0;
        Var_Exist_Dac                := 0;
        Var_Con_OrdenPend            := 0;
        Var_MacSiebelNoTieneHDdac    := 0;
        Var_MacSiebelInactivoDac     := 0;
        Var_MacSiebelSinPlanDac      := 0;
        Var_MacSiebelConHandlesVacio := 0;
        Var_MacSiebelSinPackHD       := 0;
        Var_MacSiebelNombrepack      := null;
        Var_MacSiebelCodigopack      := null;
        Begin
            Var_CPE_NoExist_DAC := 0;
            Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP cui_siebel_prod_04) */
                   Row_id
                  ,Integration_Id
              Into Var_Row_id
                  ,Var_Integration_Id
              From Cuadra.Cut_Siebel_ProductoP
             Where Permitted_type            = '/service/cable'
               And Cuenta_Serv               = Cur_Name
               And Root_Asset_Id             = Cur_Root_Asset_Id
               And x_ocs_Categoria_detallada = 'Producto Principal'
               And RowNum                    = 1;
            If Sql%Found Then
                Begin
                    Select /*+ INDEX(Cuadra.S_Asset_XA s_asset_xa_01) */
                           Trim(Char_Val)
                      Into Var_GridType
                      From Cuadra.S_Asset_XA
                     Where Attr_Name = 'GridType'
                       And Asset_Id  = Var_Row_Id;
                    If Sql%Found Then
                        If Upper(Var_GridType) = 'NANO+MEDIO+FULL+HD' Or Upper(Var_GridType) = 'NANO+MEDIO+HD' Or Upper(Var_GridType) = 'NANO+MEDIO' Then
                            Begin
                                Select /*+ INDEX(Cuadra.DAC suk_dac) */
                                       Count(1)
                                  Into Var_Exist_Dac
                                  From Cuadra.DAC
                                 Where Serial_Number = Cur_MAC
                                   And (Handles like '%100105%' or Handles like '%100106%');
                                If Sql%Found Then
                                    Begin
                                        If Var_Exist_Dac = 0 Then
                                            Var_MacSiebelSinPackHD := 1; -- Material Sibel No Tiene Pack HD En Dac
                                        End If;
                                    End;
                                End If;
                                Exception When Others Then
                                    Var_MacSiebelSinPackHD := 1; -- Material Sibel No Tiene Pack HD En Dac
                            End;
                        End If;
                        --
                        --
                        Var_Falta_Prog_Grilla    := 0;
                        Var_Paqu_Faltante_Grilla := Null;
                        Open Cur_Grilla;
                        Loop
                        Fetch Cur_Grilla
                         Into Cur_Codi_Paquete;
                        Exit When Cur_Grilla%NotFound;
                        Begin
                         -- If Cur_Codi_Paquete is not null Then
                            Begin
                            
                                Select /*+ INDEX(Cuadra.DAC suk_dac) */
                                       0
                                  Into Var_Falta_Prog
                                  From Cuadra.DAC
                                 Where Serial_Number = Cur_MAC
                                   And Handles like '%'||Trim(To_Char(Cur_Codi_Paquete))||'%';
                                If Sql%Found Then
                                    Null;
                                End If;
                                Exception When Others Then
                                    If Cur_Codi_Paquete Not In ('164062','164063') Then
                                        Var_Falta_Prog_Grilla    := 1;
                                        Var_Paqu_Faltante_Grilla := Trim(Var_Paqu_Faltante_Grilla)||'-'||Cur_Codi_Paquete;
                                    End If;                              
                           
                             
                            End;
                         --    End If;
                            Exception When Others Then
                            null;
                             --Begin
                               -- Var_Falta_Prog_Grilla    := 0;
                               -- Var_Paqu_Faltante_Grilla := Null;
                            --End;
                        End;
                        End Loop;
                        Close Cur_Grilla;
                        --
                        --
                    End If;
                    Exception When Others Then
                        Begin
                            Var_MacSiebelSinPackHD   := 0;
                            Var_Falta_Prog_Grilla    := 0;
                            Var_Paqu_Faltante_Grilla := Null;
                        End;
                End;
            End If;
            Exception When Too_Many_Rows Then
                Var_CPE_NoExist_DAC := 0;
            When Others Then
                Var_CPE_NoExist_DAC := 0;
    End;
        If Var_CPE_NoExist_DAC = 0 Then
            Begin
                Var_ExisteMacDac := 0;
                Select /*+ INDEX(Cuadra.DAC suk_dac) */
                       Count(1)
                  Into Var_ExisteMacDac
                  From Cuadra.DAC
                 Where Serial_Number = Cur_MAC;
                If Sql%RowCount > 0 And Var_ExisteMacDac > 0 Then
                    Var_CPE_NoExist_DAC := 0;
                Else
                    Var_CPE_NoExist_DAC := 1;
                End If;
                Exception When Others Then
                    Var_CPE_NoExist_DAC := 1;
            End;
            If Var_CPE_NoExist_DAC = 0 Then
                Begin
                    Var_Vcm_Lab      := 0;
                    Var_Error_VCMLab := 1;
                    Select /*+ INDEX(Cuadra.DAC suk_dac) */
                           Count(1)
                      Into Var_Vcm_Lab
                      From Cuadra.DAC
                     Where Serial_Number = Cur_MAC
                       And Vcm_Name     != 'VCM_LAB';
                    If Sql%RowCount > 0 And Var_Vcm_Lab > 0 Then
                        Var_Error_VCMLab := 0;
                    Else
                        Var_Error_VCMLab := 1;
                    End If;
                    Exception When Others Then
                        Var_Error_VCMLab := 1;
                End;
                Begin
                    Var_Activated     := 0;
                    Var_CPE_Activated := 1;
                    Select /*+ INDEX(Cuadra.DAC suk_dac) */
                           Count(1)
                      Into Var_Activated
                      From Cuadra.DAC
                     Where Serial_Number = Cur_MAC
               and Activated    != 0;
                    If Sql%RowCount > 0 And Var_Activated > 0 Then
                        Var_CPE_Activated := 0;
                    Else
                        Var_CPE_Activated := 1;
                    End If;
                    Exception When Others Then
                        Var_CPE_Activated := 1;
                End;
                Begin
                    Var_OnPlant     := 0;
                    Var_CPE_OnPlant := 1;
                    Select /*+ INDEX(Cuadra.DAC suk_dac) */
                           Count(1)
                      Into Var_OnPlant
                      From Cuadra.DAC
                     Where Serial_Number = Cur_MAC
                       And OnPlant      != 0;
                    If Sql%RowCount > 0 And Var_OnPlant > 0 Then
                        Var_CPE_OnPlant := 0;
                    Else
                        Var_CPE_OnPlant := 1;
                    End If;
                    Exception When Others Then
                        Var_CPE_OnPlant := 1;
                End;
                Begin
                    Var_Handles     := 0;
                    Var_CPE_Handles := 1;
                    Select /*+ INDEX(Cuadra.DAC suk_dac) */
                           Count(1)
                      Into Var_Handles
                      From Cuadra.DAC
                     Where Serial_Number  = Cur_MAC
                       And Trim(Handles) != '-';
                    If Sql%RowCount > 0 And Var_Handles > 0 Then
                        Var_CPE_Handles := 0;
                    Else
                        Var_CPE_Handles := 1;
                    End If;
                    Exception When Others Then
                        Var_CPE_Handles := 1;
                End;
                Var_Con_OrdenPend01 := 0;
                Var_Con_OrdenPend02 := 0;
                Var_Con_OrdenPend   := 0;
/*
                Begin
                    Select Nvl(Count(1),0)
                      Into Var_Con_OrdenPend01
                      From Cuadra.Sut_Ordenes_Siebel_Flujo
                     Where Ou_Num_1   = Cur_Rut
                       And Categoria != 'OK';
                    If Sql%RowCount > 0 Then
                        Null;
                    Else
                        Var_Con_OrdenPend01 := 0;
                    End If;
                    Exception When Others Then
                        Var_Con_OrdenPend01 := 0;
                End;
                Begin
                    Select Nvl(Count(1),0)
                      Into Var_Con_OrdenPend02
                      From Cuadra.Sut_Ordenes_Siebel
                     Where Ou_Num_1   = Cur_Rut
                       And Categoria != 'OK';
                    If Sql%RowCount > 0 Then
                        Null;
                    Else
                        Var_Con_OrdenPend02 := 0;
                    End If;
                    Exception When Others Then
                        Var_Con_OrdenPend02 := 0;
                End;
                If Var_Con_OrdenPend01 > 0 Or Var_Con_OrdenPend02 > 0 Then
                    Var_Con_OrdenPend := 1;
                End If;
*/
                Begin
                    Select /*+ INDEX(Cuadra.Sut_Ordenes_Siebel_Flujo SUI_ORDENES_FLUJO_01) */
                           Nvl(Count(1),0)
                      Into Var_Con_OrdenPend01
                      From Cuadra.Sut_Ordenes_Siebel_Flujo
                     Where Ou_Num_1   = Cur_Rut
                       And Upper(Estado_Pedido) Not In ('COMPLETADA','CANCELADA','CANCELADO','TEMPORAL');
                    If Var_Con_OrdenPend01 > 0 Then
                        Var_Con_OrdenPend := 1;
                    Else
                        Var_Con_OrdenPend := 0;
                    End If;
                    Exception When Others Then
                        Var_Con_OrdenPend := 0;
                End;
                Begin
                    Var_Error_Programac       := Null;
                    Var_Error_Canal_Programac := Null;
                    Open Cur_Siebel_Canales;
                    Loop
                    Fetch Cur_Siebel_Canales 
                     Into Cur_Codigo_Canal
                         ,Cur_Nombre_Canal;
                    Exit When Cur_Siebel_Canales%NotFound;
                    Begin
                        Var_ChannelPack := 0;
                        Select /*+ INDEX(Cuadra.DAC suk_dac) */
                               Count(1)
                          Into Var_ChannelPack
                          From Cuadra.Dac
                         Where Serial_Number = Cur_MAC
                           And Handles Like '%'||Trim(Cur_Codigo_Canal)||'%';
                        If Sql%RowCount > 0 And Var_ChannelPack > 0 Then
                            Null;
                        Else
                            Var_Error_Programac       := Var_Error_Programac ||' - '||Trim(Cur_Codigo_Canal);
                            Var_Error_Canal_Programac := Var_Error_Canal_Programac ||' - '||Trim(Cur_Nombre_Canal);
                        End If;
                        Exception When Others Then
                            Null;
                    End;
                    End Loop;
                    Close Cur_Siebel_Canales;
                End;
            End If;
        End If;
        Var_CPE_Nmro_Error := Var_CPE_NoExist_DAC + Var_MacSiebelSinPackHD + Var_Falta_Prog_Grilla;
        If Var_CPE_Nmro_Error > 0 Then
            Var_CPE_Con_Error := 1;
        Else
            Var_CPE_Con_Error := 0;
        End If;
        Begin
            Insert Into Cuadra.Cut_Siebel_ResultTVDac
            ( CPE
             ,Row_Id
             ,Root_Asset_Id
             ,Unit_Addres
             ,Rut_Persona
             ,Nmro_Cuenta_Serv
             ,CPE_Marca
             ,CPE_Modelo
             ,Tipo_dBox
             ,Tipo_Tecno_dBox
             ,CPE_NoExist_DAC
             ,CPE_ChannelPack
             ,CPE_Activated
             ,CPE_Onplant
             ,CPE_Handles
             ,CPE_SiebelSinPackHD
             ,Error_Programac
             ,Error_Canal_Programac
             ,Falta_Prog_Grilla
             ,Paqu_Faltante_Grilla
             ,Con_Orden_Pend
             ,CPE_Con_Error )
            Values
            ( Cur_MAC
             ,Cur_Row_Id
             ,Cur_Root_Asset_Id
             ,Cur_UnitAddr
             ,Trim(Cur_Rut)
             ,Cur_Name
             ,Cur_Marca
             ,Cur_Modelo
             ,Cur_Tipo_dBox
             ,Cur_Tipo_Tecno_dBox
             ,Var_CPE_NoExist_DAC
             ,Var_Error_VCMLab
             ,Var_CPE_Activated
             ,Var_CPE_OnPlant
             ,Var_CPE_Handles
             ,Var_MacSiebelSinPackHD
             ,Var_Error_Programac
             ,Var_Error_Canal_Programac
             ,Var_Falta_Prog_Grilla
             ,Var_Paqu_Faltante_Grilla
             ,Var_Con_OrdenPend
             ,Var_CPE_Con_Error );
            Commit;
            Exception When Others Then
                Rollback;
        End;
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Siebel_dBox;
    Exception When Others Then
        Null;
End;