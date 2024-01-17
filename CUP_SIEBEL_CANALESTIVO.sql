CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_CANALESTIVO  
IS
--
Var_CPE_NoExist_ProductoP        Number(1); 
Var_CPE_Dupli_ProductoP          Number(1);
Var_Flag_Retorno                 VarChar2(1);
Var_RutTivo                     VarChar2(20);
Var_Vivienda                    VarChar2(100);

--
Var_Row_id                       VarChar2(15);
Var_GridType                     VarChar2(20);
Var_Integration_Id               VarChar2(30);
--
Cur_MAC                          VarChar2(100);
Cur_UnitAddr                     VarChar2(250);
Cur_Name                         VarCHar2(100); 
Cur_Rut                          VarChar2(30);
Cur_Nombre_Paquete               VarChar2(100);
Cur_Root_Asset_Id                VarChar2(15);
Cur_Row_Id                       VarChar2(15);
Cur_Status_CD                    VarChar2(30);
Cur_Tipo_dBox                    VarChar2(255);
Cur_Tipo_Tecno_dBox              VarChar2(255);
Cur_Codigo_Canal                 VarChar2(100);
Cur_Nombre_Canal                 VarChar2(100);
Cur_Tipo                         VarChar2(50);
Cur_Flag_Retorno                 VarChar2(1);
Cur_RutTivo                     VarChar2(100);
Cur_Vivienda                    VarChar2(100);
--
Cur_Codi_Paquete                 Number(10);
--
Cursor Cur_Siebel_dBox
Is
    Select a.x_Ocs_Attrib_59
          ,a.x_Ocs_Attrib_61
          ,a.Name
          ,a.Ou_Num_1
          ,a.Root_Asset_Id
          ,a.Row_Id
          ,a.Status_CD
          ,a.desc_text
          ,a.sp_num
     From Cuadra.Cut_Siebel_dBox a
     Where a.x_Ocs_Attrib_59     Is Not Null
       And a.Status_CD           In ('Activo');
       
Cursor Cur_Siebel_Producto
Is
    Select a.x_Ocs_Attrib_59
          ,a.x_Ocs_Attrib_61
          ,a.Cuenta_Serv
          ,a.Ou_Num_1
          ,a.Root_Asset_Id
          ,a.Row_Id
          ,a.Status_CD
          ,Lpad(Replace(a.Ou_Num_1, '-', ''), 11, 0) || '_' || a.Addr_Name 
          ,x_OCS_Flag_Retorno
          ,a.Addr_Name
     From cut_siebel_productoP a
     left join cut_siebel_dbox b on b.name=a.cuenta_serv and b.root_asset_id=a.root_asset_id  and b.x_ocs_attrib_59 is not null and b.Status_CD='Activo'
     --left join cut_siebel_dbox b on b.ou_num_1=a.ou_num_1 and b.x_ocs_attrib_59 is not null and b.Status_CD='Activo'
     Where a.x_ocs_Categoria_detallada = 'Producto Principal' and a.permitted_type='/service/cable' and a.status_cd='Activo' and b.ou_num_1 is null;
--
Cursor Cur_Siebel_Canales
Is
       
        Select b.Rec_Codigo 
              ,b.Prd_Tag_Value
              ,b.Trd_Tag_Name
      From Cuadra.Cut_Siebel_Canales a, Cuadra.GIAP_TRADUCTOR b
     Where a.Rut_Cte         = Cur_Rut
       And a.Cuenta_Servicio = Cur_Name
       And a.Part_Num        = b.Prd_Tag_Value(+)
       And b.Pla_Codigo   = 'TIVO';
--
Cursor Cur_Grilla
Is
    Select /*+ INDEX(Cuadra.GIAP_TRADUCTOR cui_traductor02) */
           Rec_Codigo,
           Prd_Tag_Value,
           Trd_Tag_Name
      From Cuadra.GIAP_TRADUCTOR
     Where Trd_Tag_Name = 'GRIDTYPE'
       And Pla_Codigo   = 'TIVO'
       And Prd_Tag_Value = Upper(Trim(Var_GridType))
       And Rec_Codigo is not null; 
--
--
Begin
    Begin
        Delete from Cuadra.Cut_Siebel_CanalesTivo_aux;--Cuadra.Cut_Siebel_CanalesDac;
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
         ,Cur_Root_Asset_Id
         ,Cur_Row_Id
         ,Cur_Status_CD
         ,Cur_Tipo_dBox
         ,Cur_Tipo_Tecno_dBox;
    Exit When Cur_Siebel_dBox%NotFound;
    Begin
        Var_CPE_NoExist_ProductoP :=0;
        Var_CPE_Dupli_ProductoP   :=0;
        Begin
            Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP cui_siebel_prod_04) */
                   Row_id
                  ,Integration_Id
                  ,x_OCS_Flag_Retorno
                  ,Lpad(Replace(Ou_Num_1, '-', ''), 11, 0) || '_' || Addr_Name 
                  ,Addr_Name
              Into Var_Row_id
                  ,Var_Integration_Id
                  ,Var_Flag_Retorno
                  ,Var_RutTivo
                  ,Var_Vivienda
              From Cuadra.Cut_Siebel_ProductoP
             Where Permitted_type            = '/service/cable'
               And Cuenta_Serv               = Cur_Name
               And Root_Asset_Id             = Cur_Root_Asset_Id
               And x_ocs_Categoria_detallada = 'Producto Principal'
               And RowNum                    = 1;
            If Sql%Found Then
                Begin
  --============= Canal Replay
                   If Var_Flag_Retorno='Y' Then
                             Begin
                                    Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Var_Vivienda)
                                     ,Trim(Var_RutTivo)
                                     ,Cur_Name
                                     ,'100229'
                                     ,'Replay'
                                     ,'Replay'
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                            End;
                            --
          
                    End If;
                    Select /*+ INDEX(Cuadra.S_Asset_XA s_asset_xa_01) */
                           Trim(Char_Val)
                      Into Var_GridType
                      From Cuadra.S_Asset_XA
                     Where Attr_Name = 'GridType'
                       And Asset_Id  = Var_Row_Id;
                    If Sql%Found Then
    --=========Canales HD
                   /*     If Upper(Var_GridType) = 'NANO+MEDIO+FULL+HD' Or Upper(Var_GridType) = 'NANO+MEDIO+HD' Or Upper(Var_GridType) = 'NANO+MEDIO' Then
                            --
                            --
                            Begin
                                       Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Var_Vivienda)
                                     ,Trim(Var_RutTivo)
                                     ,Cur_Name
                                     ,'100106'
                                     ,'ChannelPacks'
                                     ,'PACK_HD'
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                            End;
                        End If;*/
    --=========Canales Grilla
                        Open Cur_Grilla;
                        Loop
                        Fetch Cur_Grilla
                         Into Cur_Codi_Paquete,
                              Cur_nombre_paquete,
                              Cur_Tipo;
                        Exit When Cur_Grilla%NotFound;
                        Begin
                            Begin
                               If Cur_Codi_Paquete Not In ('164062','164063') Then
                                  Begin
                                       Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Var_Vivienda)
                                     ,Trim(Var_RutTivo)
                                     ,Cur_Name
                                     ,Cur_Codi_Paquete
                                     ,Cur_Tipo
                                     ,Cur_nombre_paquete
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                                 End;
                               End If;                                                                                     
                            End;
                            Exception When Others Then
                            null;

                        End;
                        End Loop;
                        Close Cur_Grilla;
                        --
                        --
                    End If;
                    Exception When Others Then 
                      null;
                End;
            End If;
            Exception When Too_Many_Rows Then
                Var_CPE_Dupli_ProductoP  := 0; ---OJO DUPLICADO SIEBEL
            When Others Then
                Var_CPE_NoExist_ProductoP := 0;-- OJO EXISTE EN LA DBOX PERO NO EN LA PRODUCTOP
    End;

                Begin
    --=========Canales Pack
                    Open Cur_Siebel_Canales;
                    Loop
                    Fetch Cur_Siebel_Canales 
                     Into Cur_Codigo_Canal
                         ,Cur_Nombre_Canal
                         ,Cur_Tipo;
                    Exit When Cur_Siebel_Canales%NotFound;
                    Begin
                        Begin
                                      Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Var_Vivienda)
                                     ,Trim(Var_RutTivo)
                                     ,Cur_Name
                                     ,Cur_Codigo_Canal
                                     ,Cur_Tipo
                                     ,Cur_Nombre_Canal
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                        End;
                    End;
                    End Loop;
                    Close Cur_Siebel_Canales;
                End;

    
    End;
    End Loop;
    Close Cur_Siebel_dBox;

--PRODUCTOP
    Open Cur_Siebel_Producto;
    Loop
    Fetch Cur_Siebel_Producto
     Into Cur_MAC
         ,Cur_UnitAddr
         ,Cur_Name
         ,Cur_Rut
         ,Cur_Root_Asset_Id
         ,Cur_Row_Id
         ,Cur_Status_CD
         ,Cur_RutTivo
         ,Cur_Flag_Retorno
         ,Cur_Vivienda;
    Exit When Cur_Siebel_Producto%NotFound;
    Begin
        Var_CPE_NoExist_ProductoP :=0;
        Var_CPE_Dupli_ProductoP   :=0;
        Begin

                   If trim(Cur_Flag_Retorno)='Y' Then 
                             Begin
                                    Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Cur_Vivienda)
                                     ,Trim(Cur_RutTivo)
                                     ,Cur_Name
                                     ,'100229'
                                     ,'Replay'
                                     ,'Replay'
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                            End;
                            --
                    End If;
                    Select /*+ INDEX(Cuadra.S_Asset_XA s_asset_xa_01) */
                           Trim(Char_Val)
                      Into Var_GridType
                      From Cuadra.S_Asset_XA
                     Where Attr_Name = 'GridType'
                       And Asset_Id  = Cur_Row_Id;
                    If Sql%Found Then
    --=========Canales HD
                        If Upper(Var_GridType) = 'NANO+MEDIO+FULL+HD' Or Upper(Var_GridType) = 'NANO+MEDIO+HD' Or Upper(Var_GridType) = 'NANO+MEDIO' Then
                            --
                            --
                            Begin
                                       Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Cur_Vivienda)
                                     ,Trim(Cur_RutTivo)
                                     ,Cur_Name
                                     ,'100106'
                                     ,'ChannelPacks'
                                     ,'PACK_HD'
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                            End;
                        End If;
    --=========Canales Grilla
                        Open Cur_Grilla;
                        Loop
                        Fetch Cur_Grilla
                         Into Cur_Codi_Paquete,
                              Cur_nombre_paquete,
                              Cur_Tipo;
                        Exit When Cur_Grilla%NotFound;
                        Begin
                            Begin
                               If Cur_Codi_Paquete Not In ('164062','164063') Then
                                  Begin
                                       Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Cur_Vivienda)
                                     ,Trim(Cur_RutTivo)
                                     ,Cur_Name
                                     ,Cur_Codi_Paquete
                                     ,Cur_Tipo
                                     ,Cur_nombre_paquete
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then
                                        Rollback;
                                 End;
                               End If;                                                                                     
                            End;
                            Exception When Others Then
                            null;

                        End;
                        End Loop;
                        Close Cur_Grilla;
                        --
                        --
                    End If;
                    Exception When Others Then 
                      null;
               -- End;
            --End If;
            --Exception When Too_Many_Rows Then
               -- Var_CPE_Dupli_ProductoP  := 0; ---OJO DUPLICADO SIEBEL
            --When Others Then
                --Var_CPE_NoExist_ProductoP := 0;-- OJO EXISTE EN LA DBOX PERO NO EN LA PRODUCTOP


                Begin
    --=========Canales Pack
                    Open Cur_Siebel_Canales;
                    Loop
                    Fetch Cur_Siebel_Canales 
                     Into Cur_Codigo_Canal
                         ,Cur_Nombre_Canal
                         ,Cur_Tipo;
                    Exit When Cur_Siebel_Canales%NotFound;
                    Begin
                        Begin
                                      Insert Into Cuadra.Cut_Siebel_CanalesTivo_aux
                                    ( CPE
                                     ,Row_Id
                                     ,Root_Asset_Id
                                     ,Rut_Persona
                                     ,Vivienda
                                     ,Rut_Tivo
                                     ,Nmro_Cuenta_Serv
                                     ,Codigo_Canal
                                     ,Tipo
                                     ,Nombre_Canal
                                     ,Fecha )
                                    Values
                                    ( Cur_MAC
                                     ,Cur_Row_Id
                                     ,Cur_Root_Asset_Id
                                     ,Trim(Cur_Rut)
                                     ,Trim(Cur_Vivienda)
                                     ,Trim(Cur_RutTivo)
                                     ,Cur_Name
                                     ,Cur_Codigo_Canal
                                     ,Cur_Tipo
                                     ,Cur_Nombre_Canal
                                     ,Sysdate
                                      );
                                    Commit;
                                    Exception When Others Then 
                                        Rollback;
                        End;
                    End;
                    End Loop;
                    Close Cur_Siebel_Canales;
                End;

      End;  
    End;
    End Loop;
    Close Cur_Siebel_Producto;
    Exception When Others Then
        Null;
End;