CREATE OR REPLACE PROCEDURE CUADRA.Cup_Adre_Separa_UnitAddr
Is
--
val                              int;
i                                int;
this_delim                       int;
last_delim                       int;
var_UnitAddr                     VarChar2(30);
Var_Sw_Ejecuta                   Char(1);
--
Cur_Id_Dispositivo               Varchar2(1000);
Cur_Rut_persona                  VarChar2(12);
Cur_Rut_Vivienda                 VarChar2(30);
--
Cursor Cur_Adre_IdDispo
Is
    Select a.Rut_Persona
          ,a.Id_Dispositivo
          ,a.Rut_Vivienda
      From Cuadra.Sut_Adrenalin_Aux a
     Where a.Id_Dispositivo Is Not Null;
--
Begin
    Begin
        Var_Sw_Ejecuta := 'N';
        Delete Cuadra.Cut_Adre_UnitAddres;
        Commit;
        Var_Sw_Ejecuta := 'S';
        Exception When Others Then
            Rollback;
            Var_Sw_Ejecuta := 'N';
    End;
    If Var_Sw_Ejecuta = 'S' Then
        Open Cur_Adre_IdDispo;
        Loop
        Fetch Cur_Adre_IdDispo
         Into Cur_Rut_persona
             ,Cur_Id_Dispositivo
             ,Cur_Rut_Vivienda;
        Exit When Cur_Adre_IdDispo%NotFound;
        Begin
            i          := 1;
            last_delim := 0;
            val        := length(replace(Cur_Id_Dispositivo, ';', ';' || ' '));
            val        := val - length(Cur_Id_Dispositivo);
            While i <= val
            Loop
                this_delim   := instr(Cur_Id_Dispositivo, ';', 1, i);
                var_UnitAddr := substr(Cur_Id_Dispositivo, last_delim + 1, this_delim - last_delim -1);
                i            := i + 1;
                last_delim   := this_delim;
                Begin
                    insert into Cuadra.Cut_Adre_UnitAddres
                    ( Rut_Persona,
                      Id_Dispositivo,
                      Rut_Vivienda )
                    values
                    ( Cur_Rut_persona,
                      Var_UnitAddr,
                      Cur_Rut_Vivienda  );
                    Commit;
                    Exception When Others Then
                        RollBack;
                End;
            End Loop;
        End;
        End Loop;
        Close Cur_Adre_IdDispo;
    End If;
    Exception When Others Then
        Null;
End;