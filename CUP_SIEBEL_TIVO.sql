CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_TIVO IS
--
Var_CanTecnologia               Number(10); 
Var_RutTivo                     VarChar2(20);
Var_VivTivo                     VarChar2(100);
Var_Tecnologia_EBS              VarChar2(10):=Null;
Var_NombreCanal                 VARCHAR2(40);
Var_CanalPagado                 VARCHAR2(50);

--
Cur_RutTivo                     VarChar2(20);
Cur_CanalTivo                   VarChar2(30);
--
Var_RutPersona                  VarChar2(30);
Var_Vivienda                    VarChar2(100);
Var_Serie                       VarChar2(100);
Var_Row_id                      VarChar2(15);
Var_Root_Asset_Id               VarChar2(15);
Var_Cuenta                      VarChar2(100);
Var_ExisteSiebel                Char(1);
Var_ExisteRutSiebel             Char(1); 
Var_ExisteVivSiebel             Char(1);
 
--
--
Cursor Cur_Tivo_dBox
Is
    Select distinct 
             pcid,
             lp_id 
    From TEMP_SIEBEL_TIVO;


--
--
Begin
    Begin
        Delete from Cut_Siebel_Tivo --Where Fecha = Trunc(Sysdate);
        Commit;
        Exception When Others Then
            Rollback;
    End;
   Begin
       Delete from TEMP_SIEBEL_TIVO;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Begin
        Insert Into TEMP_SIEBEL_TIVO
         Select distinct pcid,lp_id from Cut_Tivo 
         minus
         Select distinct Rut_Tivo,codigo_canal From Cuadra.Cut_Siebel_CanalesTivo_aux;
         Commit;
          Exception When Others Then
            Rollback;
    End;
   
    Begin
          Open Cur_Tivo_dBox;
          Loop
          Fetch Cur_Tivo_dBox
           Into Cur_RutTivo 
               ,Cur_CanalTivo;
          Exit When Cur_Tivo_dBox%NotFound;
          Begin
                    Var_NombreCanal     := Null;
                    Var_Tecnologia_EBS  := 'N';
                    Var_Serie           := Null;
                    Var_RutPersona      := Null; 
                    Var_Vivienda        := Null;
                    Var_VivTivo         := Null;
                    Var_Row_id          := Null;
                    Var_Root_Asset_Id   := Null; 
                    Var_CanTecnologia   := 0;
                    Var_ExisteSiebel    := 'N';
                    Var_ExisteRutSiebel := 'N';
                    Var_ExisteVivSiebel := 'N';
                    Var_RutTivo         := Null;
                    Var_CanalPagado     := Null;
                    Var_Cuenta          := Null;
        
                      Begin
                          Select
                             Lp_name 
                          Into Var_NombreCanal
                          From Cut_Tivo
                          Where Lp_id   = Cur_CanalTivo
                          And Rownum=1;
                          If Sql%Found Then
                             Null;
                          End If;
                          Exception When Others Then
                            Rollback;
                      End;
                      
                      Begin
                          Select distinct(Trd_Tag_Name) 
                          Into Var_CanalPagado
                          From Cuadra.GIAP_TRADUCTOR 
                          Where Pla_codigo='TIVO' 
                          And Rec_Codigo=Cur_CanalTivo;
                          If Sql%Found Then
                              Null;
                          End If;
                          Exception When Others Then
                            Rollback;
                          
                      End;
      
                      Begin
                          Select
                                 Cpe
                                ,Rut_persona
                                ,Vivienda
                                ,Row_id
                                ,Root_Asset_Id
                                ,Nmro_cuenta_serv
                          Into
                               Var_Serie
                              ,Var_RutPersona 
                              ,Var_Vivienda
                              ,Var_Row_id 
                              ,Var_Root_Asset_Id
                              ,Var_Cuenta
                        From Cuadra.Cut_Siebel_CanalesTivo_aux 
                        Where rut_tivo=Cur_RutTivo
                          And Rownum=1;
                        If Sql%Found Then                     
                          Begin
                   
                               Var_ExisteSiebel    :='S';
                               Var_ExisteVivSiebel :='S';
                               Var_ExisteRutSiebel :='S';
                               Select count(*)
                                Into Var_CanTecnologia
                                From Cuadra.Cut_Siebel_CanalesTivo_aux a
                                Inner join Xvtr_Siebel_Info_Series_T b On b.cod_serie=a.cpe
                                Where rut_tivo=Cur_RutTivo and Upper(b.Tecnologia)='IPTV';
                               If Sql%Found Then
                                 If Var_CanTecnologia > 0 Then
                                    Var_Tecnologia_EBS:='S';
                                 Else
                                  Begin
                                    Select count(*) 
                                    Into Var_CanTecnologia  
                                    From cut_siebel_dbox 
                                    Where Name=Var_Cuenta 
                                      And Root_Asset_Id=Var_Root_Asset_Id;
                                    If Sql%Found Then
                                      If Var_CanTecnologia > 0 Then
                                            Var_Tecnologia_EBS:='N';
                                      Else
                                            Var_Tecnologia_EBS:='D';
                                      End If;
                                    End If;
                                    Exception When Others Then
                                       Var_Tecnologia_EBS:='D';
                                  End;     
                                 End If;
                               End If;
                               Exception When Others Then
                                 Var_Tecnologia_EBS:='N';
                           End;
                        End If;
                        Exception When Others Then
                          Begin
                              Var_RutTivo:=substr(Ltrim(Cur_RutTivo,'0'),1,instr(Ltrim(Cur_RutTivo,'0'),'_')-2)||'-'||substr(substr(Ltrim(Cur_RutTivo,'0'),1,instr(Ltrim(Cur_RutTivo,'0'),'_')-1),-1);
                              Var_VivTivo:=substr(trim(Cur_RutTivo),instr(trim(Cur_RutTivo),'_')+1,length(trim(Cur_RutTivo))) ;
                              Select 'N' 
                              Into Var_ExisteRutSiebel
                              From Cut_Siebel_productoP 
                              Where ou_num_1=Var_RutTivo 
                                 and x_ocs_categoria_detallada='Producto Principal'
                                 and status_cd='Activo' and permitted_type='/service/cable'
                                 and Rownum=1;
                              If Sql%Found Then                                     
                                 Var_ExisteRutSiebel:='S';
                                 Var_ExisteVivSiebel:='N';
                              End If;
                              Exception When Others Then
                                 Begin
                                    Select 'N' 
                                    Into Var_ExisteVivSiebel
                                    From Cut_Siebel_productoP 
                                    Where Addr_Name=Var_RutTivo 
                                       and x_ocs_categoria_detallada='Producto Principal'
                                       and status_cd='Activo' and permitted_type='/service/cable'
                                       and Rownum=1;
                                    If Sql%Found Then
                                       Var_ExisteVivSiebel:='S';
                                       Var_ExisteRutSiebel:='N';
                                    End If;
                                    Exception When Others Then
                                      Null;
                                 End;
                               
                          End;
                      End;
      
                               If Var_RutPersona is null and   Var_RutTivo is not null Then
                                   Var_RutPersona:=Var_RutTivo; 
                               End If;
                               
                               If Var_Vivienda is null and   Var_VivTivo is not null Then
                                   Var_Vivienda:=Var_VivTivo; 
                               End If;
                               Begin
                                        Insert Into Cut_Siebel_Tivo
                                          (Pcid
                                          ,lp_id
                                          ,lp_name
                                          ,Cpe
                                          ,Row_id
                                          ,Root_Asset_Id
                                          ,Rut_Persona
                                          ,Vivienda
                                          ,ExisteSiebel
                                          ,TecnologiaIPTV
                                          ,ExisteCanalDac
                                          ,ExisteRut
                                          ,ExisteVivienda
                                          ,TipoCanalGiap
                                          ,Fecha)
                                        Values
                                          (Cur_RutTivo,
                                           Cur_CanalTivo,
                                           Var_NombreCanal,
                                           Var_Serie,
                                           Var_Row_id,
                                           Var_Root_Asset_Id,
                                           Var_RutPersona,
                                           Var_Vivienda,
                                           Var_ExisteSiebel,
                                           Var_Tecnologia_EBS,
                                           'N',
                                           Var_ExisteRutSiebel,
                                           Var_ExisteVivSiebel,                                    
                                           Var_CanalPagado,
                                           Trunc(Sysdate)
                                          );
                                        If SQL%RowCount > 0 Then
                                           Commit;
                                        Else
                                            Rollback;
                                        End If;
                                        Exception When Others Then
                                          Rollback;
                                  End;
      
      
          
          End;
          End Loop;
          Close Cur_Tivo_dBox;
          Exception When Others Then
              Null;
    End;    
    Begin
       Insert Into Cut_Siebel_Tivo
         select pcid,Lp_id,lp_name,cpe,row_id,root_asset_id,rut_persona,vivienda,'S', 
         Case When cod_serie Is Null Then 'N' Else 'S' End tecnogiaiptv,'S','S','S','',sysdate  
         from
         (select distinct a.pcid,a.Lp_id,a.lp_name,b.cpe,b.row_id,b.root_asset_id,b.rut_persona,b.vivienda,c.cod_serie from cut_tivo a
         Inner join Cuadra.Cut_Siebel_CanalesTivo_aux b on b.rut_tivo=a.pcid and b.codigo_canal=a.lp_id
         Left join Xvtr_Siebel_Info_Series_T c On c.cod_serie=b.cpe and Upper(c.Tecnologia)='IPTV'
         where a.Lp_id not in (select distinct lp_id from Cut_Siebel_Tivo where pcid=a.pcid)  
         );
        Commit;
    End;
    
    Begin
       Update Cut_Siebel_Tivo
       Set existecanaldac ='P'
       Where existecanaldac ='N' and  Fecha = Trunc(Sysdate) and rut_persona  in 
      (select ou_num_1 from cut_siebel_productoP where permitted_type='/service/cable' and status_cd='Suspendido' and ou_num_1 is not null);
       Commit;
    End;
End;