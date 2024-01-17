CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_DAC_CRM
Is
--
Cur_Serial_Number           VarChar2(50);
Cur_Handles                 VarChar2(4000);
--
Var_i                       Number(9);
Var_Val                     Number(9);
Var_Last_Delim              Number(9);
Var_This_Delim              Number(9);
Var_ExistPaquete            Number(1);
Var_NoExistCanal            Number(1);
Var_Cuenta_Serv             VarChar2(100);
Var_Rut_Persona             VarChar2(30);
Var_Paquete                 VarChar2(100);
Var_Root_Asset_Id           VarChar2(15);
Var_Row_id                  VarChar2(15);
Var_Integration_Id          VarChar2(30);
Var_GridType                VarChar2(20);
Var_Canal_AltaCRMBaja       Number(1);
Var_Paquete_AltaCRMBaja     VarChar2(1000);
Var_Existe                  Char(1);
Var_CPE_ActivoDAC_NOCRM     Number(1);
--
--
Cursor Cur_Internet_dBox
Is
    Select Serial_Number
          ,Handles
      From Cuadra.DAC
     Where Length(Trim(Handles))      > 3
       And Substr(Serial_Number,1,2) != 'GI'
       And Activated                  = '1'
       And OnPlant                    = 1;
--
--
Begin
    Begin
        Delete Cuadra.Cut_DAC_CRM;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Open Cur_Internet_dBox;
    Loop
    Fetch Cur_Internet_dBox
     Into Cur_Serial_Number
         ,Cur_Handles;
    Exit When Cur_Internet_dBox%NotFound;
    Begin
        Select /*+ INDEX(Cuadra.Cut_Siebel_dBox cui_siebel_dbox_01) */
               a.Name
              ,a.Ou_num_1
              ,Root_Asset_Id
          Into Var_Cuenta_Serv
              ,Var_Rut_Persona
              ,Var_Root_Asset_Id
          From Cut_Siebel_dBox a
         Where a.x_Ocs_Attrib_59 = Cur_Serial_Number
           And a.Status_Cd       = 'Activo';
        If Sql%Found Then
            Begin
                Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP cui_siebel_prod_04) */
                       Row_id
                      ,Integration_Id
                  Into Var_Row_id
                      ,Var_Integration_Id
                  From Cuadra.Cut_Siebel_ProductoP
                 Where Permitted_type = '/service/cable'
                   And Cuenta_Serv    = Var_Cuenta_Serv
                   And Root_Asset_Id  = Var_Root_Asset_Id
                   And RowNum         = 1;
                If Sql%Found Then
                    Begin
                        Select /*+ INDEX(Cuadra.S_Asset_XA s_asset_xa_01) */
                               Upper(Trim(Char_Val))
                          Into Var_GridType
                          From Cuadra.S_Asset_XA
                         Where Attr_Name = 'GridType'
                           And Asset_Id  = Var_Row_Id;
                        If Sql%Found Then
                            Null;
                        End If;
                        Exception When Others Then
                            Var_GridType := '*';
                    End;
                End If;
                Exception When Others Then
                    Var_Row_id         := '0';
                    Var_Integration_Id := '0';
            End;
            Begin
                Var_i          := 1;
                Var_Val        := length(replace(Cur_Handles, ';', ';' || ' '));
                Var_Val        := Var_Val - length(Cur_Handles);
                Var_Last_Delim := 0;
                While Var_i <= Var_Val
                Loop
                    Var_This_Delim := Instr(Cur_Handles, ';', 1, Var_i);
                    Var_Paquete    := SubStr(Cur_Handles, Var_Last_Delim + 1, Var_This_Delim - Var_Last_Delim -1);
                    If Var_i = 1 Then
                        Var_Paquete := SubStr(Var_Paquete,2,Length(Trim(Var_Paquete)));
                    End If;
                    Var_i          := Var_i + 1;
                    Var_Last_Delim := Var_This_Delim;
                    Begin
                        Select /*+ INDEX(Cuadra.Cut_Siebel_Canales cui_canal_ruts) */
                               0
                          Into Var_ExistPaquete
                          From Cuadra.Cut_Siebel_Canales a, Cut_GrillaCanales b
                         Where a.Rut_Cte         = Var_Rut_Persona
                           And a.Cuenta_Servicio = Var_Cuenta_Serv
                           And b.ChannelPacks    = a.Part_Num
		                       And b.Plataforma      = 'DAC'
                           And b.Paquete         = Var_Paquete
                           And RowNum            = 1;
						If Sql%Found Then
						    Var_NoExistCanal := 0;
						End If;
                        Exception When Others Then
                            Begin
                                Select /*+ INDEX(Cuadra.GIAP_TRADUCTOR cui_traductor02) */
                                       0
                                  Into Var_NoExistCanal
                                  From Cuadra.GIAP_TRADUCTOR
                                 Where Trd_Tag_Name  = 'GRIDTYPE'
                                   And Pla_Codigo    = 'DAC'
                                   And Rec_Codigo    = Var_Paquete
                                   And Prd_Tag_Value = Upper(Trim(Var_GridType));
                                If Sql%Found Then
                                    Null;
                                End If;
                                Exception When Others Then
                                    If Var_Paquete = '100229' Or Var_Paquete = '1016' Then
                                        Var_NoExistCanal := 0;
                                    Else
                                        Var_NoExistCanal := 1;
                                    End If;
						    End;
                    End;
                    Var_Canal_AltaCRMBaja   := 0;
                    Var_Paquete_AltaCRMBaja := Null;
                    Begin
                        Select /*+ INDEX(Cuadra.Cut_Siebel_Canales cui_canal_ruts) */
                               0
                          Into Var_ExistPaquete
                          From Cuadra.Cut_Siebel_Canales a, Cut_GrillaCanales b
                         Where a.Rut_Cte         = Var_Rut_Persona
                           And a.Cuenta_Servicio = Var_Cuenta_Serv
                           And b.ChannelPacks    = a.Part_Num
--                         And b.Plataforma      = 'DAC'
                           And b.Paquete         = Var_Paquete
                           And RowNum            = 1;
                        If Sql%Found Then
                            Var_Canal_AltaCRMBaja := 0;
                        End If;
                        Exception When Others Then
                            Var_Canal_AltaCRMBaja   := 1;
                            Var_Paquete_AltaCRMBaja := Var_Paquete_AltaCRMBaja||';'||Var_Paquete;
                    End;
                End Loop;
                Begin
                    Insert Into Cuadra.Cut_DAC_CRM
                    (Serial_Number,
                     Handles,
                     Cuenta_Serv,
                     Rut_Persona,
                     Root_Asset_Id,
                     Row_id,
                     Integration_Id,
                     GridType,
                     Paquete,
                     NoExistCanal,
                     Canal_AltaCRMBaja,
                     Paquete_AltaCRMBaja)
                    Values
                    (Cur_Serial_Number,
                     Cur_Handles,
                     Var_Cuenta_Serv,
                     Var_Rut_Persona,
                     Var_Root_Asset_Id,
                     Var_Row_id,
                     Var_Integration_Id,
                     Var_GridType,
                     Var_Paquete,
                     Var_NoExistCanal,
                     Var_Canal_AltaCRMBaja,
                     Var_Paquete_AltaCRMBaja);
                    Commit;
                    Exception When Others Then
                        Rollback;
                End;
            End;
        End If;
        Exception When Others Then
            Begin
                Select /*+ INDEX(Cuadra.Cut_DAC_CRM cui_dac_cmr_01) */
                       'S'
                  Into Var_Existe
                  From Cuadra.Cut_DAC_CRM
                 Where Serial_Number = Cur_Serial_Number
                   And RowNum        = 1;
                If Sql%Found Then
                    Var_CPE_ActivoDAC_NOCRM := 1;
                    Begin
                        Update /*+ INDEX(Cuadra.Cut_DAC_CRM cui_dac_cmr_01) */
                               Cuadra.Cut_DAC_CRM
                           Set CPE_DACNoExistSiebel = 0
                              ,CPE_ActivoDAC_NOCRM  = Var_CPE_ActivoDAC_NOCRM
                         Where Serial_Number = Cur_Serial_Number;
                        If Sql%RowCount > 0 Then
                            Commit;
                        Else
                            Rollback;
                        End If;
                        Exception When Others Then
                            Rollback;
                    End;
                End If;
                Exception When Others Then
                    Begin
                        Insert Into Cuadra.Cut_DAC_CRM
                        (Serial_Number
                        ,CPE_DACNoExistSiebel)
                        Values
                        (Cur_Serial_Number
                        ,1);
                        If Sql%RowCount > 0 Then
                            Commit;
                        Else
                            Rollback;
                        End If;
                        Exception When Others Then
                            Rollback;
                    End;
            End;
    End;
    End Loop;
    Close Cur_Internet_dBox;
    Exception When Others Then
        Raise_Application_Error(-20001,SqlErrM);
End;
