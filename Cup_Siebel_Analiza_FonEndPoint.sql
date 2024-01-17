CREATE OR REPLACE PROCEDURE CUADRA.Cup_Siebel_Analiza_FonEndPoint
Is
--
Cur_Rut                          VarChar2(30);
Cur_MAC                          VarChar2(100);
Cur_Codi_Localidad               VarChar2(30);
Cur_Nmro_Nodo                    VarChar2(50);
Cur_Nmro_SubNodo                 VarChar2(50);
Cur_Row_Id                       VarChar2(15);
Cur_Integration_ID               VarChar2(30);
Cur_Asset_Integration_ID         VarChar2(30);
Cur_Cuenta_Serv                  VarCHar2(100);
Cur_Root_Asset_Id                VarChar2(15);
--
Var_FQDN_Siebel                  VarChar2(200);
Var_FQDN_PlataIncog              VarChar2(200);
Var_FQDN_PlataTelef              VarChar2(250);
Var_Nmro_Fono                    VarChar2(50);
Var_Mac_Fono                     VarChar2(100);
Var_Mac_Inet                     VarChar2(100);
Var_MAC_PlataTelef               VarChar2(12);
--
Var_Con_OrdenPend01         Number(6);
Var_Con_Orden_Pend          Number(1);
Var_Con_BIPend01            Number(6);
Var_Con_Bi_Pend             Number(1);
Var_NmroRegErrores          Number(6);
--
Cursor Cur_Siebel_Fono
Is
    Select b.Ou_Num_1
          ,b.x_Ocs_Attrib_59
          ,b.x_Ocs_Codigo_Localidad
          ,b.x_Ocs_Nodo
          ,b.x_Ocs_SubNodo
          ,b.Row_Id
          ,b.Integration_ID
          ,b.x_Ocs_Attrib_57
          ,b.Cuenta_Serv
          ,b.Root_Asset_Id
      From Cuadra.Cut_Siebel_ProductoP b
     Where b.Permitted_Type            = '/service/telephony'
       And b.x_ocs_attrib_59           Is Not Null
       And b.Status_Cd                 = 'Activo'
       And b.x_ocs_categoria_detallada = 'Producto Principal';
Cursor Cur_Errores
Is 
    Select Rut,
           Integration_Id
      From Cuadra.Cut_FonoEndPoint_SiebelPlataf;
Begin
    Begin
        Delete Cuadra.Cut_FonoEndPoint_SiebelPlataf;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Open Cur_Siebel_Fono;
    Loop
    Fetch Cur_Siebel_Fono
     Into Cur_Rut,
          Cur_MAC,
          Cur_Codi_Localidad,
          Cur_Nmro_Nodo,
          Cur_Nmro_SubNodo,
          Cur_Row_Id,
          Cur_Integration_ID,
          Cur_Asset_Integration_ID,
          Cur_Cuenta_Serv,
          Cur_Root_Asset_Id;
    Exit When Cur_Siebel_Fono%NotFound;
    Begin
        Begin
            Select Lpad(Trim(a.Serial_Num),10,'0')
              Into Var_Nmro_Fono
              From Cuadra.S_Asset a
                  ,Cuadra.S_Prod_Int b
             Where a.Root_Asset_Id            = Cur_Root_Asset_Id
               --And a.status_cd                = 'Activo'
               And b.row_id                   = a.prod_id
               And x_ocs_categoria_detallada  = 'Producto Customizable'
               And a.Serial_Num               Is Not Null
               And b.name                     = 'Telefonia Fija'
               And b.status_cd                = 'Activo'
               And rownum                     = 1;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_Nmro_Fono := Null;
        End;
        If Var_Nmro_Fono Is Null Then
        Begin
            Select Lpad(Trim(a.X_OCS_NUMERO_TELEFONO),10,'0')
              Into Var_Nmro_Fono
              From Cuadra.S_Asset a
                  ,Cuadra.S_Prod_Int b
             Where a.Root_Asset_Id            = Cur_Root_Asset_Id
               --And a.status_cd                = 'Activo'
               And b.row_id                   = a.prod_id
               And x_ocs_categoria_detallada  = 'Producto Customizable'
               And X_OCS_NUMERO_TELEFONO      Is Not Null
               And b.name                     = 'Telefonia Fija'
               And b.status_cd                = 'Activo'
               And rownum                     = 1;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_Nmro_Fono := Null;
        End;
        End If;
        If Var_Nmro_Fono Is Null Then
        Begin
            Select Lpad(Trim(a.Serial_Num),10,'0')
              Into Var_Nmro_Fono
              From Cuadra.S_Asset a
                  ,Cuadra.S_Prod_Int b
             Where a.Root_Asset_Id            = Cur_Root_Asset_Id
               And a.status_cd                = 'Activo'
               And b.row_id                   = a.prod_id
               And x_ocs_categoria_detallada  = 'Otros Fijos'
               And a.Serial_Num               Is Not Null
               And b.name                     = 'Numero Comun'
               And b.status_cd                = 'Activo'
               And rownum                     = 1;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_Nmro_Fono := Null;
        End;
        End If;
        Begin
            Select /*+ INDEX(Cuadra.S_Asset_X Cui_Asset_X_01) */
                   Attrib_42,
                   Attrib_46
              Into Var_Mac_Inet,
                   Var_Mac_Fono
              From Cuadra.S_Asset_X
             Where Row_ID = Cur_Row_Id;
            If Sql%Found Then
                If Substr(Cur_Nmro_Nodo,1,1) = '0' Then
                    Var_FQDN_Siebel := Trim(Var_Mac_Inet)||
                                      '-'||Trim(Cur_Codi_Localidad)||
                                      '-N'||SubStr(Trim(Cur_Nmro_Nodo),2,2)||
                                      'Q'||SubStr(Trim(Cur_Nmro_SubNodo),2,2)||
                                      '.'||Trim(Cur_Codi_Localidad)||'.VTR.NET';
                ElsIf Substr(Cur_Nmro_Nodo,1,1) != '0' Then
                    Var_FQDN_Siebel := Trim(Var_Mac_Inet)||
                                      '-'||Trim(Cur_Codi_Localidad)||
                                      '-N'||SubStr(Trim(Cur_Nmro_Nodo),1,3)||
                                      'Q'||SubStr(Trim(Cur_Nmro_SubNodo),2,2)||
                                      '.'||Trim(Cur_Codi_Localidad)||'.VTR.NET';
                End If;
            End If;
            Exception When Others Then
                Var_FQDN_Siebel := Null;
        End;
        Begin
            Select /*+ INDEX(Cuadra.Sut_Internet Suk_Internet_MAC) */
                   FQDN
              Into Var_FQDN_PlataIncog
              From Cuadra.Sut_Internet
             Where MAC    = Var_Mac_Fono
               And RUT    = LPAD(Cur_Rut,12,'0')
               And LOCA   = Cur_Codi_Localidad
               And Clusters not in (146);
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_FQDN_PlataIncog := Null;
        End;
        Begin
            Select /*+ INDEX(Cuadra.ValidLines Cui_ValidLines_01) */
                   GW_Name,
                   SubStr(GW_Name,1,12)
              Into Var_FQDN_PlataTelef,
                   Var_MAC_PlataTelef
              From Cuadra.ValidLines
             Where DN = Var_Nmro_Fono
               And RowNum = 1;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_FQDN_PlataTelef := Null;
                Var_MAC_PlataTelef  := Null;
        End;
        Begin
            Insert Into Cuadra.Cut_FonoEndPoint_SiebelPlataf
            (Rut,
             MAC,
             Nmro_Fono,
             Codi_Localidad,
             Nmro_Nodo,
             Nmro_SubNodo,
             Row_Id_Promo,
             Integration_ID,
             Asset_Integration_ID,
             Cuenta_Serv,
             FQDN_Siebel,
             FQDN_PlataIncog,
             FQDN_PlataTelef,
             MAC_PlataTelef)
            Values
            (Cur_Rut,
             Var_Mac_Inet,
             Var_Nmro_Fono,
             Cur_Codi_Localidad,
             Cur_Nmro_Nodo,
             Cur_Nmro_SubNodo,
             Cur_Row_Id,
             Cur_Integration_ID,
             Cur_Asset_Integration_ID,
             Cur_Cuenta_Serv,
             Var_FQDN_Siebel,
             Var_FQDN_PlataIncog,
             Var_FQDN_PlataTelef,
             Var_MAC_PlataTelef);
            If Sql%RowCount > 0 Then
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
    Close Cur_Siebel_Fono;
    --
    Begin
        Select Count(Rut)
          Into Var_NmroRegErrores
          From Cuadra.Cut_FonoEndPoint_SiebelPlataf;
        Exception When Others Then
            Var_NmroRegErrores := 5001;
    End;
    --
    Open Cur_Errores;
    Loop
    Fetch Cur_Errores
     Into Cur_Rut,
          Cur_Integration_Id;
    Exit When Cur_Errores%NotFound;
    Begin
        If Var_NmroRegErrores > 5000 Then
            Begin
                Var_Con_OrdenPend01 := 0;
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend01
                  From Cuadra.S_Order a ,
                       Cuadra.S_Org_Ext e
                 Where e.ou_num_1          = Cur_Rut
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend01 > 0 Then
                    Var_Con_Orden_Pend := 1;
                Else
                    Var_Con_Orden_Pend := 0;
                End If;
                Exception When Others Then
                    Var_Con_Orden_Pend := 0;
            End;
        Else
            Begin
                Var_Con_OrdenPend01 := 0;
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend01
                  From siebel.S_Order@sblprd.world a ,
                       siebel.S_Org_Ext@sblprd.world e
                 Where e.ou_num_1          = Cur_Rut
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend01 > 0 Then
                    Var_Con_Orden_Pend := 1;
                Else
                    Var_Con_Orden_Pend := 0;
                End If;
                Exception When Others Then
                    Var_Con_Orden_Pend := 0;
            End;
        End If;
        Begin
            Var_Con_BIPend01 := 0;
            Select /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
                   Nvl(Count(1),0)
              Into Var_Con_BIPend01
              From Cuadra.Businessiinteraction
             Where Externalobjectid = Cur_Integration_Id
               And Adminstate Not In ('CANCELLED','COMPLETED');
            If Var_Con_BIPend01 > 0 Then
                Var_Con_BI_Pend := 1;
            Else
                Var_Con_BI_Pend := 0;
            End If;
            Exception When Others Then
                Var_Con_BI_Pend := 0;
        End;  
        Begin
            Update /*+ INDEX(Cuadra.Cut_FonoEndPoint_SiebelPlataf CUI_FonoEndPoint_01) */
                   Cuadra.Cut_FonoEndPoint_SiebelPlataf
               Set Con_Orden_Pend = Var_Con_Orden_Pend,
                   Con_BI_Pend    = Var_Con_BI_Pend
             Where Rut            = Cur_Rut
               And Integration_Id = Cur_Integration_Id;
            If Sql%RowCount > 0 Then
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
    Close Cur_Errores;
    --
    Exception When Others Then
        Null;
End;
