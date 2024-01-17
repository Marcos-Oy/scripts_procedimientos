CREATE OR REPLACE PROCEDURE CUADRA.Cup_Siebel_Analiza_dBox_DAC
IS
Var_Exist_Dac                    Number(1);
Var_ExisteMacDac                 Number(1);
Var_MacSiebelNoTieneHDdac        Number(1);
Var_Onplant                      Number(1);
Var_activated                    Number(1);
Var_Handles                      Number(1);
Var_MacSiebelInactivoDac         Number(1);
Var_MacSiebelSinPlanDac          Number(1);
Var_MacSiebelConHandlesVacio     Number(1);
Var_Vcm_Lab                      Number(1);
Var_DoboxHD                      Number(1);
Var_Channelpack                  Number(1);
Var_MacSiebelConChannelpack      Number(1);
Var_Row_id                       VarChar2(15);
Var_GridType                     VarChar2(20);
Var_Integration_Id               VarChar2(30);
Var_MacSiebelNombrepack          VarChar2(100);
Var_MacSiebelCodigopack          VarChar2(100);

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
Cur_Tipo_Tecnologia              VarChar2(30);
Cur_Tipo_Tecnologia1             VarChar2(30);
Cur_Tipo_Tecnologia2             VarChar2(30);
Cur_Part_Num                     VarChar2(50);
Cur_Codigo_Canal                 VarChar2(100);

Cursor Cur_Siebel_dBox
Is
    Select /*+ INDEX(Cuadra.Cut_Siebel_dBox CUI_SIEBEL_DBOX_02) */
           a.x_Ocs_Attrib_59
          ,a.x_Ocs_Attrib_61
          ,a.Name
          ,a.Ou_Num_1
          ,a.Attrib_44
          ,a.Attrib_45
          ,a.Root_Asset_Id
          ,a.x_Ocs_SubClase
          ,a.Row_Id
          ,a.Status_CD
          ,a.x_Ocs_Cod_Tipo_Item
          ,a.sp_num
          ,a.desc_text
     From Cuadra.Cut_Siebel_dBox a
     Where a.x_Ocs_Attrib_59     Is Not Null
     And   a.Status_CD           In ('Activo')
     And   Not Exists (Select * From Rut_Excluidos b Where b.Rut_Persona = a.ou_num_1);
--   And   a.x_ocs_attrib_59 = 'M91840ER6123';
--
Cursor Cur_Siebel_Canales
Is
   Select /*+ INDEX(Cuadra.Cut_UIM_RFS CUI_UIM_RFS_01) */
          Distinct
          Part_Num,
          Case Part_Num
               When 'CDF_SD'      Then '100006'
               When 'CDF_HD'      Then '100029'
               When 'FOX_SPORT'   Then '100040'
               When 'FOX_SPORTSD' Then '100008'
               Else
              'NC'
               End as Codi_canal_Dac
     From Cuadra.Cut_Siebel_Canales a ,Cuadra.Cut_UIM_RFS b
     Where a.part_num = b.value
     And   a.Rut_Cte          = Cur_Rut
     And   a.cuenta_servicio  = Cur_Name
     And   b.externalobjectid = Var_Integration_Id
     And   b.Caracteristica   = 'CP_Code';

/*
    Select Distinct Nombre_Producto
          ,Part_Num
          ,Case Part_Num
               When 'CDF_SD'      Then '100006'
               When 'CDF_HD'      Then '100029'
               When 'FOX_SPORT'   Then '100040'
               When 'FOX_SPORTSD' Then '100008'
               Else
                    'NC'
               End as Codi_canal_Dac
     From Cuadra.Cut_Siebel_Canales
     Where
           Rut_Cte         = Cur_Rut
     And   Cuenta_Servicio = Cur_Name;

*/
Begin
    Begin
        Delete from Cuadra.Cut_Siebel_ResultdBoxDac_Prog;
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
             ,Cur_Tipo_Tecnologia
             ,Cur_Tipo_Tecnologia1
             ,Cur_Tipo_Tecnologia2;
        Exit When Cur_Siebel_dBox%NotFound;
        Begin
          Var_Exist_Dac             :=0;
          Var_MacSiebelNoTieneHDdac :=0;
          Var_MacSiebelInactivoDac  :=0;
          Var_MacSiebelSinPlanDac   :=0;
          Var_MacSiebelConHandlesVacio :=0;
          Var_MacSiebelConChannelpack :=0;
          Var_MacSiebelNombrepack:=null;
          Var_MacSiebelCodigopack:=null;
          Begin
             Select /*+ INDEX(Cuadra.Cut_siebel_productoP CUI_SIEBEL_PROD_04) */
                   Row_id
                  ,Integration_Id
             Into Var_Row_id
                 ,Var_Integration_Id
             From Cut_siebel_productoP
             Where Permitted_type = '/service/cable'
               And Cuenta_Serv    = Cur_Name--'12268227-7-S-001'
               And Root_Asset_Id  = Cur_Root_Asset_Id
               And x_Ocs_Categoria_Detallada = 'Producto Principal';--'1-2TYN-1957'
           If Sql%Found Then
             Begin
             Select /*+ INDEX(Cuadra.S_Asset_XA S_ASSET_XA_01) */
                    Char_val
               Into Var_GridType
               From Cuadra.S_Asset_XA
               Where Asset_ID  = Var_Row_ID
                 And Attr_Name = 'GridType';
                 If Sql%Found Then

                  Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                         count(1)
                  Into Var_ExisteMacDac
                  From Cuadra.DAC
                  Where serial_number = Cur_MAC;-- Existencia de Material
                  If Sql%Found Then
                    If Var_ExisteMacDac > 0 Then
                     Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                             count(1)
                        Into Var_Vcm_Lab
                        From Cuadra.DAC
                        Where Serial_number = Cur_MAC And
                              Vcm_name <> 'VCM_LAB';
                        If Sql%Found Then
                           If Var_Vcm_Lab > 0 Then
                              Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                                   count(1)
                              Into Var_activated
                              From Cuadra.DAC
                              Where serial_number = Cur_MAC and
                                    activated =0;
                              If Sql%Found Then
                                If Var_activated > 0 Then
                                   Var_MacSiebelInactivoDac:=1; -- Material Sibel Inactivo En Dac
                                Else
                                    Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                                         count(1)
                                    Into Var_Onplant
                                    From Cuadra.DAC
                                    Where serial_number = Cur_MAC and
                                         Onplant=0;
                                    If Sql%Found Then
                                       If Var_Onplant > 0 Then
                                          Var_MacSiebelSinPlanDac:=1; -- Material Sibel Sin Plan En Dac
                                       Else
                                          Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                                               count(1)
                                          Into Var_Handles
                                          From Cuadra.DAC
                                          Where Serial_number = Cur_MAC and
                                          trim(Handles)='-';
                                          If Sql%Found Then
                                            Begin
                                               If Var_Handles > 0 then
                                                  Var_MacSiebelConHandlesVacio:=1; -- Material Sibel Sin Canales En Dac
                                               Else
                                                  Begin
                                                  ---
                                                  Open Cur_Siebel_Canales;
                                                  Loop
                                                  Fetch Cur_Siebel_Canales
                                                  Into Cur_Part_Num
                                                      ,Cur_Codigo_Canal;
                                                  Exit When Cur_Siebel_Canales%NotFound;
                                                    Begin
                                                        Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                                                             count(1)
                                                        Into Var_Channelpack
                                                        From dac where serial_number=Cur_MAC And handles like '%'||Cur_Codigo_Canal||'%';
                                                        If Sql%Found Then
                                                          If Var_Channelpack = 0 Then
                                                            Begin
                                                               Var_MacSiebelConChannelpack:=1;
                                                               Var_MacSiebelNombrepack:= Cur_Part_Num;
                                                               Var_MacSiebelCodigopack:= Cur_Codigo_Canal;
                                                            End;
                                                          End If;
                                                        End If;
                                                    End;
                                                  End Loop;
                                                 Close Cur_Siebel_Canales;
                                                 ---

                                                     Select /*+ INDEX(Cuadra.Cut_Siebel_dBox CUI_SIEBEL_DBOX_01) */
                                                          count(1)
                                                     Into Var_DoboxHD
                                                     From Cuadra.Cut_Siebel_dBox a
                                                     Where a.x_Ocs_Attrib_59=Cur_Mac
                                                     And   a.desc_text='d-BOX HD';
                                                     If Sql%Found Then
                                                        Begin
                                                           If Var_DoboxHD > 0 Then

                                                              If Upper(Var_GridType)='NANO+MEDIO+FULL+HD' Or Upper(Var_GridType)='NANO+MEDIO+HD' Or Upper(Var_GridType)='NANO+MEDIO' Then
                                                                Begin
                                                                  Select /*+ INDEX(Cuadra.DAC SUK_DAC) */
                                                                       count(1)
                                                                  Into Var_Exist_Dac
                                                                  From Cuadra.DAC
                                                                  Where Serial_number = Cur_MAC
                                                                  And (Handles like '%100105%' or Handles like '%100106%');
                                                                  If Sql%Found Then
                                                                    Begin
                                                                       If Var_Exist_Dac =0 Then
                                                                             Var_MacSiebelNoTieneHDdac:=1; -- Material Sibel No Tiene Pack HD En Dac
                                                                       End If;
                                                                    End;
                                                                  End If;
                                                                End;
                                                              End If;
                                                            End If;
                                                         End;
                                                     End If;
                                                   End;
                                               End If;
                                             End;
                                          End If;
                                       End If;
                                    End If;
                                End If;
                              End If;
                           End If;
                        End If;
                     End If;
                  End If;
                 End If;
              End;
            End If;
                Exception When Others Then
                    Var_MacSiebelNoTieneHDdac:=0;
        End;
        Begin

                        Insert Into Cuadra.Cut_Siebel_ResultdBoxDac_Prog
                        ( CPE
                         ,Row_Id
                         ,Unit_Addres
                         ,Rut_Persona
                         ,Descrip_ChannelPack
                         ,Codigo_ChannelPack
                         ,CPE_ChannelPack
                         ,CPE_NoExist_DAC
                         ,CPE_Activated
                         ,CPE_Onplant
                         ,CPE_Handles)
                        Values
                        ( Cur_MAC
                         ,Cur_Row_Id
                         ,Cur_UnitAddr
                         ,Trim(Cur_Rut)
                         ,Var_MacSiebelNombrepack
                         ,Var_MacSiebelCodigopack
                         ,Var_MacSiebelConChannelpack
                         ,Var_MacSiebelNoTieneHDdac
                         ,Var_MacSiebelInactivoDac
                         ,Var_MacSiebelSinPlanDac
                         ,Var_MacSiebelConHandlesVacio);
                        Commit;
                        Exception When Others Then
                            Rollback;
          End;
        End;
        End Loop;
        Close Cur_Siebel_dBox;

End;
