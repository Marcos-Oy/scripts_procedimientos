CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_PLATA_TEOS 
AS 

Var_Flag_ProductoTeos            Number(1);
Var_Clusters                     VarChar2(50);
Var_Rut_Incog                    VarChar2(50);
Var_Estado_Incog                 VarChar2(50);
Var_Loca_Incog                   VarChar2(50);
Var_Veloc_Incog                  VarChar2(100);
Var_Class                        VarChar2(100);
Var_Device_Type                  VarChar2(50);
Var_Cpe                          VarChar2(100);



Cur_MAC                          VarChar2(100);
Cur_CuentaServ                   VarCHar2(100);
Cur_Rut                          VarChar2(30);
Cur_Localidad                    VarChar2(30);
Cur_Vivienda                     VarChar2(100);

Cursor Cur_Siebel_Inet
Is
    Select a.x_Ocs_Attrib_59
          ,a.Cuenta_Serv
          ,a.Ou_Num_1
          ,a.x_Ocs_Codigo_Localidad
          ,a.addr_name
      From Cuadra.Cut_Siebel_ProductoP a
      Inner join Xvtr_Siebel_Info_Series_t b on b.cod_serie=a.x_ocs_attrib_59  and b.tipocpe !='ONT'
     Where a.Permitted_Type = '/service/broadband'
       And a.Status_Cd      = 'Activo'
       And a.x_ocs_attrib_59 Not In (select mac from Cuadra.Cut_Correccion_Ing )
       And a.x_ocs_categoria_detallada   = 'Producto Principal'
       And Exists (  select distinct mac  from sut_internet where mac=a.x_Ocs_Attrib_59 and loca=a.x_Ocs_Codigo_Localidad and ltrim(rut,'0')=a.Ou_Num_1);
      -- And a.x_Ocs_Attrib_59='C005C2A07913';
       
       
Begin       
    Begin
        Delete Cut_Valida_Teos_IncAux Where Fecha = Trunc(Sysdate);
        Commit;
        Exception When Others Then
            Rollback;
    End;

        Open Cur_Siebel_Inet;
        Loop
        Fetch Cur_Siebel_Inet
         Into Cur_Mac
             ,Cur_CuentaServ
             ,Cur_Rut
             ,Cur_Localidad
             ,Cur_Vivienda;
        Exit When Cur_Siebel_Inet%NotFound;
        Begin
           Var_Flag_ProductoTeos :=0;
           Var_Class             :=Null;
            Begin
                Select Count(1)
                  Into Var_Flag_ProductoTeos
                  From Cuadra.Cut_Siebel_ProductoP c
                  inner join Xvtr_Siebel_Info_Series_t d on d.cod_serie=c.x_ocs_attrib_59 and d.Tecnologia = 'IPTV'
                 Where c.Cuenta_Serv   = Cur_CuentaServ;
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Null;
            End;
            --
               
            Begin
                  Select Rut
                        ,Device_Type
                        ,Loca
                        ,Plan2
                        ,Cpe
                        ,Class
                        ,clusters
                    Into Var_Rut_Incog
                        ,Var_Device_Type
                        ,Var_Loca_Incog
                        ,Var_Veloc_Incog
                        ,Var_Cpe
                        ,Var_Class
                        ,Var_Clusters
                    From Cuadra.Sut_Internet
                   Where Mac  = Upper(Cur_Mac)
                     And Instr(class,'TEOS') =0
                     And Device_Type='CABLE MODEM'
                     And Loca=Cur_Localidad
                     And Clusters not in (146);
                If Sql%Found Then
                    Null;
                End If;
                Exception When Others Then
                    Null;
            End;

             
            --If Var_Flag_ProductoTeos > 0 And Var_Class  is not null Then
               Begin
                --DBMS_OUTPUT.put_line('vv');
                    Insert Into Cut_Valida_Teos_IncAux
                    (
                      OU_NUM_1,
                      CUENTA_SERV,
                      X_OCS_CODIGO_LOCALIDAD,
                      X_OCS_ATTRIB_59,
                      CLUSTERS,
                      RUT,
                      DEVICE_TYPE,
                      LOCA,
                      PLAN2,
                      CLASS,
                      CPE,
                      Q_IPTV,
                      FECHA,
                      Addr_Name
                    )
                    Values 
                    (
                     Cur_Rut
                     ,Cur_CuentaServ
                     ,Cur_Localidad
                     ,Cur_Mac
                     ,Var_Clusters
                     ,Var_Rut_Incog
                     ,Var_Device_Type
                     ,Var_Loca_Incog
                     ,Var_Veloc_Incog
                     ,Var_Class
                     ,Var_Cpe
                     ,Var_Flag_ProductoTeos
                     ,Trunc(Sysdate)
                     ,Cur_Vivienda
                    );
                    Commit;
                    Exception When Others Then
                        Rollback;
              End;
            --End If;
        End;
        End Loop;
        Close Cur_Siebel_Inet;
        
    Begin
      Delete from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null and plan2  in ('BLOCK','TSSI') and Fecha = Trunc(Sysdate) and x_ocs_attrib_59 in(
          select distinct x_ocs_attrib_59   from (
            select distinct count(1) as cant ,  x_ocs_attrib_59      
            From Cut_Valida_Teos_Incaux
            where q_iptv > 0 and class is not null and plan2 is not null  and Fecha = Trunc(Sysdate)
            group by x_ocs_attrib_59
          ) where cant > 1 
      );
      Commit;
    End;
    
    Begin           
        delete from Cut_Valida_Teos_Incaux where q_iptv=0 and Fecha = Trunc(Sysdate)
        and   x_Ocs_Attrib_59 in (select distinct  x_Ocs_Attrib_59      from Cut_Valida_Teos_Incaux where q_iptv > 0 and Fecha = Trunc(Sysdate));
      Commit;
    End;
    
    Begin
      Delete from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null and plan2  in ('BLOCK','TSSI') and Fecha = Trunc(Sysdate);
        Commit;  
    End;
/*
Select 
  x_ocs_attrib_59 as mac 
  ,lpad(ou_num_1,12,'0') as rut_crm
  ,rut as rut_plataforma
  ,x_ocs_codigo_localidad as localidad_crm
  ,loca as localidad_plataforma
  ,clusters as clusters_crm
  ,clusters as clusters_plataforma
  ,plan2 as velocidad_crm
  ,plan2 as velocidad_plataforma
  ,Device_Type
  ,cpe
  ,'MODELO' as Tipo_Correccion
  ,'SIEBEL' as Plataforma
  ,case instr(class,',') when 0 then class else Substr(class,1,instr(class,',')-1)  end Class
  ,'TEOS' as Class2
  ,case REGEXP_COUNT(class,',',1) when 1 then   (substr(class,instr(class,',')+1,length(class))) else (substr(substr(class,instr(class,',')+1,length(class)),1,instr(substr(class,instr(class,',')+1,length(class)),',')-1))  end Class3
        
From Cut_Valida_Teos_Incaux


select count(distinct  x_Ocs_Attrib_59)      from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null 
and Fecha = Trunc(Sysdate);--28431

duplicadas siebel
1835D1DFC423
1835D11B7CB3


select count(distinct  x_Ocs_Attrib_59)      from Cut_Valida_Teos_Incaux
select count(distinct  x_Ocs_Attrib_59)     from Cut_Valida_Teos_Incaux where q_iptv=0
select count(distinct  x_Ocs_Attrib_59)      from Cut_Valida_Teos_Incaux where q_iptv > 0
select count(distinct  x_Ocs_Attrib_59)      from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null
select count(distinct  x_Ocs_Attrib_59)    from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null and Plan2 in ('BLOCK','TSSI') 
select count(distinct  x_Ocs_Attrib_59)    from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null and Plan2 Not in ('BLOCK','TSSI') 
--select count(distinct  x_Ocs_Attrib_59)      from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is not null and Plan2 is null
select count(distinct  x_Ocs_Attrib_59)     from Cut_Valida_Teos_Incaux where q_iptv > 0 and class is null


*/
END;