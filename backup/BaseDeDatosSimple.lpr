program BaseDeDatosSimple;

uses ucomando, sysutils;

const
      (*Lista de comandos en String*)
      COMANDO_NUEVO_TEXTO= 'NUEVO';
      COMANDO_MODIFICAR_TEXTO= 'MODIFICAR';
      COMANDO_ELIMINAR_TEXTO= 'ELIMINAR';
      COMANDO_BUSCAR_TEXTO= 'BUSCAR';
      COMANDO_OPTIMIZAR_TEXTO= 'OPTIMIZAR';
      COMANDO_ESTADOSIS_TEXTO= 'ESTADOSIS';
      COMANDO_SALIR_TEXTO= 'SALIR';
      PARAMETRO_ELIMINAR_DOC= '-D';
      PARAMETRO_ELIMINAR_TODO= '-T';

      (*Formatos para imprimir datos de salida como una tabla*)
      FORMAT_ID= '%6s';
      FORMAT_DOCUMENTO= '%11s';
      FORMAT_NOMBRE_APELLIDO= '%21s';
      FORMAT_EDAD_PESO= '%6s';
      COLUMNA_ID= 'ID';
      COLUMNA_DOCUMENTO= 'DOCUMENTO';
      COLUMNA_NOMBRE= 'NOMBRE';
      COLUMNA_APELLIDO= 'APELLIDO';
      COLUMNA_EDAD= 'EDAD';
      COLUMNA_PESO= 'PESO';

      (*Simplemente el prompt de entrada en la consola*)
      PROMPT= '>> ';

      (*Nombre de archivo de la base de datos.*)
      BASEDEDATOS_NOMBRE_REAL= 'BaseTom.dat';
      (*Nombre de archivo temporal de la base de datos*)
      BASEDEDATOS_NOMBRE_TEMPORAL= 'tempDataBase_ka.tmpka';

type
  {Identifica a los comandos admitidos por el sistema.
   * NUEVO: Permitirá crear nuevos registros.
   * MODIFICAR: Permitirá modificar registros existentes.
   * ELIMINAR: Permitirá eliminar registros existentes.
   * BUSCAR: Permitirá buscar y mostrar registros exitentes.
   * ESTADOSIS: Muestra información de la base de datos.
   * OPTIMIZAR: Limpiará la base de datos de registros eliminados.
   * SALIR: Cierra el programa.
   * INDEF: Comando indefinido. Se utiliza para indicar errores.}
  TComandosSistema= (NUEVO,MODIFICAR,ELIMINAR,BUSCAR,ESTADOSIS,OPTIMIZAR,SALIR,INDEF);

  {Representa el registro de una persona en el sistema.}
  TRegistroPersona= packed record
     Id: int64;
     Nombre, Apellido: String[20];
     Documento: String[10];
     Edad, Peso: byte;
     Eliminado: boolean;
  end;

  {El archivo en el que se guardarán los datos.}
  TBaseDeDatos= file of TRegistroPersona;


var entradaEstandar, documentoAux: String;
    sysCom: TComandosSistema;
    objCom: TComando;
    archivoDataBase, archivoTempBase: TBaseDeDatos;
    registroPersona, registroPersonaAux, personaLeida: TRegistroPersona;
    i, cantidadRegActivos, cantidadRegEliminados: int64;
    pruebaParametros, pruebaEdad, pruebaPeso, pruebaDocumento, pruebaEliminado,D: boolean;

  {Recibe un comando c de tipo TComando y retorna su equivalente en
  TComandoSistema. Esta operación simplemente verifica que el nombre
  del comando c sea igual a alguna de las constantes COMANDO definidas
  en este archivo. Concretamente si:

  * El nombre de c es igual a COMANDO_NUEVO_TEXTO retorna TComandosSistema.NUEVO
  * El nombre de c es igual a COMANDO_MODIFICAR_TEXTO retorna TComandosSistema.MODIFICAR
  * El nombre de c es igual a COMANDO_ELIMINAR_TEXTO retorna TComandosSistema.ELIMINAR
  * El nombre de c es igual a COMANDO_BUSCAR_TEXTO retorna TComandosSistema.BUSCAR                              registroPersona
  * El nombre de c es igual a COMANDO_ESTADOSIS_TEXTO retorna TComandosSistema.ESTADOSIS
  * El nombre de c es igual a COMANDO_OPTIMIZAR_TEXTO retorna TComandosSistema.OPTIMIZAR
  * El nombre de c es igual a COMANDO_SALIR_TEXTO retorna TComandosSistema.SALIR

  En cualquier otro caso retorna TComandosSistema.INDEF.}


  function comprobarRegEliminados(var persona:TRegistroPersona): boolean; forward;



  function comandoSistema(const c: TComando): TComandosSistema;
  begin
      if CompareText(nombreComando(c),COMANDO_NUEVO_TEXTO)=0 then
         result:= TComandosSistema.NUEVO
      else if CompareText(nombreComando(c),COMANDO_MODIFICAR_TEXTO)=0 then
         result:= TComandosSistema.MODIFICAR
      else if CompareText(nombreComando(c),COMANDO_ELIMINAR_TEXTO)=0 then
         result:= TComandosSistema.ELIMINAR
      else if CompareText(nombreComando(c),COMANDO_BUSCAR_TEXTO)=0 then
         result:= TComandosSistema.BUSCAR
      else if CompareText(nombreComando(c),COMANDO_ESTADOSIS_TEXTO)=0 then
         result:= TComandosSistema.ESTADOSIS
      else if CompareText(nombreComando(c),COMANDO_OPTIMIZAR_TEXTO)=0 then
         result:= TComandosSistema.OPTIMIZAR
      else if CompareText(nombreComando(c),COMANDO_SALIR_TEXTO)=0 then
         result:= TComandosSistema.SALIR
      else
         result:= TComandosSistema.INDEF;
  end;

  {Busca en el arhivo, un registro con el documento indicado y lo asigna a reg
  retornando TRUE. Si no existe en el archivo un registro con el documento indicado
  entonces retorna FALSE.}
  function buscarRegistro(documento: String; var reg: TRegistroPersona; var archivo: TBaseDeDatos): boolean;
  begin

  end;

  {Retorna una línea de texto formada por 78 guiones}
  function stringSeparadorHorizontal(): String;
  var i: byte;
  begin
      result:= '';
      for i:=1 to 78 do
          result+= '-';
  end;

  {Retorna una línea de texto que forma el encabezado de la salida al imprimir
  los registros.}
  function stringEncabezado(): String;
  begin
      result:= {Format(FORMAT_ID,[COLUMNA_ID])+'|'+}Format(FORMAT_DOCUMENTO,[COLUMNA_DOCUMENTO])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_NOMBRE])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_APELLIDO])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_EDAD])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_PESO]);
  end;

  {Retorna una línea de texto formada por los datos del registro reg para que
  queden vistos en formato de columnas}
  function stringFilaRegistro(const reg: TRegistroPersona): String;
  begin
      result:= //Format(FORMAT_ID,[IntToStr(reg.Id)])+'|'+
               Format(FORMAT_DOCUMENTO,[reg.Documento])+'|'+
               Format(FORMAT_NOMBRE_APELLIDO,[reg.Nombre])+'|'+
               Format(FORMAT_NOMBRE_APELLIDO,[reg.Apellido])+'|'+
               Format(FORMAT_EDAD_PESO,[Inttostr(reg.Edad)])+'|'+
               Format(FORMAT_EDAD_PESO,[Inttostr(reg.Peso)]);
  end;

procedure EntradaPrompt();
begin

    write (PROMPT);
    readln (entradaEstandar);
    objCom:=crearComando(entradaEstandar);
    sysCom:=comandoSistema(objCom);

end;


{Comprueba que la cantidad de parámetros introducidos sean 5}
function NumeroParametros (var parametroEntrada:TComando):boolean;
var validacionParametros:boolean;

begin

    if (parametroEntrada.listaParametros.cantidad <> 5) then begin
        writeln ('ERROR: Cantidad de parametros incorrecta: [DOCUMENTO, NOMBRE, APELLIDO, EDAD, PESO]');
        validacionParametros:=false;
        writeln;
        EntradaPrompt();
        registroPersona.documento:=objCom.listaParametros.argumentos[1].datoString;
        registroPersona.Nombre:=objCom.listaParametros.argumentos[2].datoString;
        registroPersona.Apellido:=objCom.listaParametros.argumentos[3].datoString;
        registroPersona.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
        registroPersona.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;

    end else begin
        validacionParametros:=true;
    end;

end;

function EdadNumero (edadPersona:byte):boolean;
var validacionEdad:boolean;

begin

    if not (esParametroNumerico (objCom.listaParametros.argumentos[4])) then begin
        writeln ('El parametro EDAD debe ser un valor numerico');
        writeln;
        validacionEdad:=false;
        EntradaPrompt();
    end;
        validacionEdad:=true;

end;

function existeDocumento (personaAcomprobar:TRegistroPersona; controlParametros: boolean):boolean;

begin


      reset (archivoDataBase);
      while not eof (archivoDataBase) do begin
            read(archivoDataBase, personaAcomprobar);
            {compara el documento existente en la BD con el documento que introduce el usuario para modificar el registro
            Si coinciden, pruebaParametros lanza TRUE}
            controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;
      end;


      if (controlParametros=false) then begin //validación OK
          writeln ('No existe este documento');
          writeln;
          EntradaPrompt();
      end;
      result:= true
      CloseFile(archivoDataBase);
end;

function PesoNumero (pesoPersona:byte):boolean;
var validacionPeso:boolean;

begin

    if not (esParametroNumerico (objCom.listaParametros.argumentos[5])) then begin
        writeln ('El parametro PESO debe ser un valor numerico');
        writeln;
        validacionPeso:=false;
        EntradaPrompt();
    end;
        validacionPeso:=true;

end;

function DocumentoRepetido (documentoPersona:string; personaActual:TRegistroPersona):boolean;
var validacionDocumento:boolean;
begin

    reset (archivoDataBase);

    {if (comprobarRegEliminados(personaActual)=true) then begin
       writeln('PASA POR AQUI');
    end;}

    {writeln (stringEncabezado()); }
    while not eof (archivoDataBase) do begin
      read (archivoDataBase, personaActual);
      //writeln (stringFilaRegistro(personaActual));
      writeln;
      if (compareStr (personaActual.Documento, ObjCom.listaParametros.argumentos[1].datoString)=0) and (comprobarRegEliminados(personaActual)=true) then begin
        writeln ('Ya existe este numero de documento >> [',personaActual.Documento,' ',personaActual.Nombre,' ',personaActual.Apellido,']');
        validacionDocumento:=false;
        writeln;
        EntradaPrompt();
      end;//if

    end; //while

    validacionDocumento:=true;

    CloseFile (archivoDataBase);

end;


function comprobarRegEliminados(var persona:TRegistroPersona): boolean;

var validacionEliminado:boolean;

begin

  reset (archivoDataBase);

  if (registroPersona.Eliminado=true) then begin
    while not eof (archivoDataBase) do begin
      read (archivoDataBase,registroPersona);

      writeln ('++++ COMPROBACION ELIMINADOS ++++');
      writeln ('DOCUMENTO ',registroPersona.Documento);
      writeln ('NOMBRE ',registroPersona.Nombre);
      writeln ('APELLIDO ',registroPersona.Apellido);
      writeln ('EDAD ',registroPersona.Edad);
      writeln ('PESO ',registroPersona.Peso);
      writeln ('ELIMINADO ',registroPersona.Eliminado);
      writeln;

      if (DocumentoRepetido(ObjCom.listaParametros.argumentos[1].datoString,registroPersona)) then begin
         validacionEliminado:=true ;
      end;
    end;
  end;


  validacionEliminado:= false;
end;


function NuevoReg (documentoPersona, nombrePersona, apellidoPersona:string; idPersona, edadPersona, PesoPersona:byte; ELIMINADOPERSONA:BOOLEAN): TRegistroPersona;

begin


  pruebaParametros:=numeroParametros(objCom);
  pruebaEdad:=EdadNumero(objCom.listaParametros.argumentos[5].datoNumerico);
  pruebaPeso:=PesoNumero (objCom.listaParametros.argumentos[6].datoNumerico);
  pruebaDocumento:=documentoRepetido(objCom.listaParametros.argumentos[2].datoString, registroPersonaAux);

  registroPersona.Documento:=registroPersonaAux.Documento;
  registroPersona.Nombre:=registroPersonaAux.Nombre;
  registroPersona.Apellido:=registroPersonaAux.Apellido;
  registroPersona.Edad:=registroPersonaAux.Edad;
  registroPersona.Peso:=registroPersonaAux.Peso;

  IF ELIMINADOPERSONA=FALSE THEN BEGIN


    if ((pruebaParametros=true) and (pruebaEdad=true)) and ((pruebaPeso=true) and (pruebaDocumento=true)) then begin
      reset (archivoDataBase);
      seek (archivoDataBase, FileSize(archivoDataBase));
      write (archivoDataBase, registroPersona);
      WRITELN ('ELIMINADO ', registroPersona.Eliminado);
      writeln ('Registro agregado correctamente');
      writeln;
    end;

  end;


  CloseFile (archivoDataBase);

end;

function ModificarReg (personaAmodificar:TREgistroPersona; var baseDatos:TBaseDeDatos): boolean;
var nuevoRegistro:TRegistroPersona;

begin

        seek (baseDatos, 0);

        nuevoregistro.documento:=personaAmodificar.Documento;
        nuevoRegistro.Nombre:=personaAmodificar.Nombre;
        nuevoRegistro.Apellido:=personaAmodificar.Apellido;
        nuevoRegistro.Edad:=personaAmodificar.edad;
        nuevoRegistro.Peso:=personaAmodificar.Peso;


        write (baseDatos,nuevoRegistro);
        writeln ('Registro ',nuevoregistro.Documento,' modificado');
        writeln;


end;

{
 >> eliminarTodo Procedimiento para eliminar todos los registros del Archivo.
No elimina como tal, marca el atributo Eliminado como True
}
function eliminarTodo(): TRegistroPersona;
  var personaEliminada: TRegistroPersona;
begin

  reset (archivoDataBase);
  writeln (stringEncabezado());

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaEliminada);

    personaEliminada.Eliminado:=true;

    // stringFilaRegistro da el formato de columnas para imprimir por pantalla.
    writeln (stringFilaRegistro(personaEliminada));
    writeln ('REGISTRO ',personaEliminada.Nombre,' ', 'ELIMINADO ',personaEliminada.Eliminado);
    writeln;
    result:= personaEliminada;
  end;
end;


{>> buscarTodo: Procedimiento para realizar una busqueda de todos los registros
en Base de Datos y mostrarlos por pantalla.}
procedure buscarTodo();

begin

  reset (archivoDataBase);

  writeln (stringEncabezado()); // Encabezado de la tabla de datos.
  writeln (stringSeparadorHorizontal());


  {Se recorre todo el archivo y se imprimer por pantalla cada uno de
  los registros.}
  while not eof (archivoDataBase) do begin
    read (archivoDataBase, registroPersona);
    writeln (stringFilaRegistro(registroPersona));
   // writeln ('REGISTRO ',registroPersona.Nombre,' ', 'ELIMINADO ',registroPersona.ELIMINADO);
   // writeln;
  end;
  writeln;

end;


(*============================================================================*)
(****************************** BLOQUE PRINCIPAL ******************************)
(*============================================================================*)
begin


  {----Asignamos y creamos el archivo o lo abrimos si ya está creado----}
  AssignFile (archivoDataBase, BASEDEDATOS_NOMBRE_REAL);

  if FileExists (BASEDEDATOS_NOMBRE_REAL) then begin
    reset (archivoDataBase);
  end else begin
    rewrite (archivoDataBase);
  end;
  {------------------------------------------------------------------------}


repeat

  registroPersona.Documento:='';
  registroPersona.Nombre:='';
  registroPersona.Apellido:='';
  registroPersona.Edad:=0;
  registroPersona.Peso:=0;


  {PROMPT + Lectura comando + lectura datos}
  entradaPrompt();
  {------------------------------------------------------------------------}



  registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
  registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
  registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
  registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
  registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;

  {------------------------INICIO CASE PRINCIPAL-----------------------------}

  case sysCom of



    NUEVO:begin
      NuevoReg (registroPersona.Documento, registroPersona.Nombre, registroPersona.Apellido, registroPersona.Id, registroPersona.edad, registroPersona.Peso,REGISTROPERSONA.ELIMINADO);
    end;{FIN CASE "NUEVO"}




    MODIFICAR:begin
      reset (archivoDataBase);


      {Si los parametros NO son diferente a 5 (es decir, es igual a 5) y prueba parametros no es false
      (es decir, es true) entonces llama a ModificarReg}
      if ((NumeroParametros(objCom)) and (existeDocumento(registroPersonaAux, pruebaParametros))) then begin
         ModificarReg(registroPersonaAux, archivoDataBase);
      end;


    end; {FIN CASE MODIFICAR}







    {ELIMINAR: ingresar comando "-T" o -"D documento".
     -Si ingresa "-T" --> se borra todo el archivo (sólo parametro -T
     -Si se ingresa "D documento se "oculta un registro en concreto,
         no se podrá buscar ni modificar. Si no se ingresan los 2 parametros vuelca error. Si todo es correcto, mensaje ok}


     ELIMINAR:begin
     {VErificar si está eliminado y se pueda sustituir por el mismo nº de documento}

       registroPersona:= eliminarTodo();

     end;{FIN CASE ELIMINAR}






     BUSCAR: begin
        buscarTodo();
     end; {FIN CASE BUSCAR}






  end; {FIN CASE PRINCIPAL}


until syscom=SALIR;


readln;
end.

