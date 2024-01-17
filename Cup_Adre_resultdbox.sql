CREATE OR REPLACE PROCEDURE CUADRA.Cup_Adre_resultdbox
IS
--
--
Var_Existe_DboxSiebel           Number(10);
Var_ExisteCustomerID            Number(1);
Var_Con_OrdenPend               Number(6);
Var_ExisteCustomerNulos         Number(6);
Var_ExisteDispositivosNulos     Number(6);
Var_NoRetorno                   Number(6);
Var_Rut                         VarChar2(30);
Var_Vivienda                    VarChar2(30);
Var_CustomerID                  VarChar2(100);
Var_Cpe                         VarChar2(100); 
Var_Dispositivo                 VarChar2(50);
Var_TipoDbox                    VarChar2(250);
Var_Retorno                     VarChar2(1);

--
Cur_Rut_Persona                  VarChar2(12);
Cur_Iden_Vivienda                Number(8);
Cur_CustomerID                   VarChar2(100);
Cur_Unitaddr                     VarChar2(50);
--

--

Cursor Cur_PlataformaAdre_dbox
Is  
   Select a.Rut_persona,
           a.Iden_Vivienda,
           a.Rut_vivienda,
           b.Dispositivo 
    From Sut_Adrenalin_Aux a, Cuadra.Sut_Dispositivoadrenalin b
    Where a.Rut_vivienda=b.Rut_Vivienda and b.Dispositivo is not null
         and a.Rut_vivienda not in (select distinct rut_vivienda from cut_exclusiones_adre where Responsable is not null and Rut_vivienda=a.Rut_vivienda )
         and b.dispositivo not in (select distinct dispositivo from cut_exclusiones_adre where Responsable is  null and dispositivo=b.dispositivo)
         and a.Rut_persona not in (select distinct Rut from Cut_Siebel_Adrenalin where length(trim(rut_vivienda))>30 and Rut=a.Rut_persona );

--
--
Begin
   Begin
        Cup_Siebel_Adrenalin;
        Exception When Others Then
            Null;
    End;
    Begin
        Delete from Cuadra.Cut_Result_Adre; 
        Commit;
        Exception When Others Then
            Rollback;
    End;

    Open  Cur_PlataformaAdre_dbox;
    Loop
    Fetch  Cur_PlataformaAdre_dbox
     Into  Cur_Rut_Persona,
           Cur_Iden_Vivienda,
           Cur_CustomerID,
           Cur_Unitaddr;
    Exit When  Cur_PlataformaAdre_dbox%NotFound;
    Begin
          Var_ExisteCustomerID        :=0;
          Var_Existe_DboxSiebel       :=0;
          Var_Con_OrdenPend           :=0;
          Var_ExisteCustomerNulos     :=0;
          Var_NoRetorno               :=0;
          Var_ExisteDispositivosNulos :=0;
          Var_CustomerID              :=null;
          Var_Cpe                     :=null;
          Var_Dispositivo             :=null; 
          Var_TipoDbox                :=null;
          Var_Retorno                 :=null;
           -- DBMS_OUTPUT.put_line('**'||Cur_CustomerID||'**');
          Begin                   
               Select Distinct NVL(x_ocs_attrib_59,'0')
               Into Var_Cpe
               From Cuadra.Cut_Siebel_Adrenalin
               Where Rut_vivienda=Trim(Cur_CustomerID)
                 and Nvl(Sp_num,'0') !='DBOXIPTV'
                 and Nvl(Sp_num,'0') !='DBOXEOS'
                 and dispositivo is not null
                 and Rownum=1;
               If Sql%Found Then
                  If Var_Cpe !='0'   Then 
                    Begin
                      Var_ExisteCustomerID := 0;
                      Select Distinct(x_ocs_attrib_59)
                      Into Var_Cpe
                      From Cuadra.Cut_Siebel_Adrenalin
                      Where Rut_vivienda = Trim(Cur_CustomerID)
                        and Dispositivo = Trim(Cur_Unitaddr);
                      If Sql%Found Then
                        Var_Existe_DboxSiebel:=0;
                      End If;
                      Exception When Too_Many_Rows Then
                        Var_Existe_DboxSiebel:=0;
                      When No_Data_Found Then
                         Var_Existe_DboxSiebel:=1;
                    End;
                  Else
                   -- If Var_Cpe ='0' then
                       Var_ExisteCustomerNulos:=1;
                   -- End If;
                    --
                   -- If Var_Dispositivo ='0' and  Var_Cpe !='0' then
                    --  Var_ExisteDispositivosNulos:=1;
                    --End If;  
                    --
                    --If Var_Retorno ='N' then
                      -- Var_NoRetorno:=1;
                    --End If;
                    
                  End If;
                End If;
                Exception When Others Then
                    Var_ExisteCustomerID:=1;
                   -- DBMS_OUTPUT.put_line('*'||Cur_CustomerID||'*');

            End;
            
            Begin
                Var_Rut:=Ltrim(Cur_Rut_Persona,'0');
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend
                  From Cuadra.S_Order a ,
                       Cuadra.s_org_ext e
                 Where e.ou_num_1          = Var_Rut
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend > 0 Then
                    Var_Con_OrdenPend := 1;
                Else
                    Var_Con_OrdenPend:= 0;
                End If;
                Exception When Others Then
                    Var_Con_OrdenPend := 0;
            End;

           Begin
                   Begin
                     Insert Into Cuadra.Cut_Result_Adre
                     (
                     Rut,
                     Vivienda,
                     Dispositivo,
                     CustomerId,
                     CustomerId_NoExiste,
                     Dispositivo_NoExiste,
                     Orden_Pend,
                     CustomerId_ExisteNulos
                     )
                     Values
                     (
                      Var_Rut,
                      Cur_Iden_Vivienda,
                      Cur_Unitaddr,
                      Cur_CustomerID,
                      Var_ExisteCustomerID,
                      Var_Existe_DboxSiebel,
                      Var_Con_OrdenPend,
                      Var_ExisteCustomerNulos
                     );
                    If Sql%RowCount > 0 Then
                        Commit;
                    Else
                        Rollback;
                    End If;
                    Exception When Others Then
                      Rollback;
                   End;  
           End;
           Exception When Others Then
               Null;

    End;
    End Loop;
    Close  Cur_PlataformaAdre_dbox;
    Exception When Others Then
        Null;
        
    Begin
        CUP_ADRE_RESULTDBOX_RE;
        Exception When Others Then
            Null;
    End;
  


END;