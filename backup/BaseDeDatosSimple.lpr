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


var entradaEstandar, documentoAux, valorEliminarD, valorEliminarT: String;
    sysCom: TComandosSistema;
    objCom: TComando;
    archivoDataBase, archivoTempBase: TBaseDeDatos;
    registroPersona, registroPersonaAux, personaLeida: TRegistroPersona;
    i, cantidadRegActivos, cantidadRegEliminados: int64;
    pruebaParametros, pruebaEdad, pruebaPeso, pruebaDocumento, pruebaEliminado,
      ElDocExiste,pruebaDoc,compareEliminarT, compareEliminarD: boolean;

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
  function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona; var baseDatos: TBaseDeDatos):boolean ; forward;



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
      result:= Format(FORMAT_ID,[COLUMNA_ID])+'|'+Format(FORMAT_DOCUMENTO,[COLUMNA_DOCUMENTO])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_NOMBRE])+'|'+Format(FORMAT_NOMBRE_APELLIDO,[COLUMNA_APELLIDO])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_EDAD])+'|'+Format(FORMAT_EDAD_PESO,[COLUMNA_PESO]);
  end;

  {Retorna una línea de texto formada por los datos del registro reg para que
  queden vistos en formato de columnas}
  function stringFilaRegistro(const reg: TRegistroPersona): String;
  begin
      result:= Format(FORMAT_ID,[IntToStr(reg.Id)])+'|'+
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

begin

    if (parametroEntrada.listaParametros.cantidad <> 5) then begin
       result:=false;
    end else begin
        result:=true;
    end;

end;

function EdadNumero (edadPersona:byte):boolean;

begin

    if not (esParametroNumerico (objCom.listaParametros.argumentos[4])) then begin
        result:=false;
      end else begin
        result:=true;
      end;

end;



function PesoNumero (pesoPersona:byte):boolean;

begin

    if not (esParametroNumerico (objCom.listaParametros.argumentos[5])) then begin
        result:=false;
    end else begin
        result:=true;
    end;


end;


{Recibe un registro de Tipo TPersona que será la persona que vayamos a comprobar (parámetro
MODIFICAR) con los que ya existen en la BD.
Si el documento comparado es igual (es decir, existe) entonces asignamos la variable booleana como true
para devolverla fuera de la función.
Si no existe el documento introducido dentro de la BD, devuelve False.}
function existeDocumento (personaAcomprobar:TRegistroPersona):boolean;

var  controlParametros: boolean;

begin
      reset (archivoDataBase);
      while not eof (archivoDataBase) do begin
            read(archivoDataBase, personaAcomprobar);

            {compara el documento existente en la BD con el documento que introduce el usuario para modificar el registro
            Si coinciden, pruebaParametros lanza TRUE}
            controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;

            if controlParametros=true then begin
                result:=true;
                exit;
            end;
            result:=false;
      end;

end;


function existeDocumentoAEliminar (personaAcomprobar:TRegistroPersona):boolean;

var  controlParametros: boolean;

begin
      reset (archivoDataBase);
      while not eof (archivoDataBase) do begin
            read(archivoDataBase, personaAcomprobar);

            {compara el documento existente en la BD con el documento que introduce el usuario para modificar el registro
            Si coinciden, pruebaParametros lanza TRUE}
            controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[2].datoString)=0;

            if controlParametros=true then begin
              if personaAcomprobar.Eliminado=false then begin
                result:=true;
                exit;
              end;

            end;
            result:=false;
      end;

end;






{Esta función recibe un registro de Tipo TRegisttroPersona y devuelve uno igual.
Lee el archivo hasta el final, comparando el documento introducido (con el comando
MODIFICAR) con los que hay en la BD. Si coincide (es decir, si existe) devuelve
el registro de la persona que ha coincidido.
En caso contrario, no devuelve nada.}
function validDocumento (personaAcomprobar:TRegistroPersona):TRegistroPersona;

var  controlParametros: boolean;

begin
      reset (archivoDataBase);
      while not eof (archivoDataBase) do begin
            read(archivoDataBase, personaAcomprobar);

            {compara el documento existente en la BD con el documento que introduce el usuario para modificar el registro
            Si coinciden, pruebaParametros lanza TRUE}
            controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[1].datoString)=0;

            if controlParametros=true then begin
                result:=personaAcomprobar;
                exit;
            end;

      end;

end;


function validDocumentoEliminar (personaAcomprobar:TRegistroPersona):TRegistroPersona;

var  controlParametros: boolean;

begin
      reset (archivoDataBase);
      while not eof (archivoDataBase) do begin
            read(archivoDataBase, personaAcomprobar);

            {compara el documento existente en la BD con el documento que introduce el usuario para modificar el registro
            Si coinciden, pruebaParametros lanza TRUE}
            controlParametros:=compareStr(personaAcomprobar.Documento, objCom.listaParametros.argumentos[2].datoString)=0;

            if controlParametros=true then begin
                result:=personaAcomprobar;
                exit;
            end;

      end;

end;





{// TODO:  pendiente comprobar dentro del case NUEVO, para verificar que el documento
introducido no exista ya.}
function DocumentoRepetido (documentoPersona:string; personaActual:TRegistroPersona):boolean;
begin

    reset (archivoDataBase);

    while not eof (archivoDataBase) do begin
      read (archivoDataBase, personaActual);
      if (compareStr (personaActual.Documento, ObjCom.listaParametros.argumentos[1].datoString)=0) then begin

        result:=false;
        exit;
      end;//if
    end; //while

    result:=true;

    CloseFile (archivoDataBase);

end;

{// TODO: pendiente comprobación en el case de ELIMINAR }
function comprobarRegEliminados(var persona:TRegistroPersona): boolean;

begin

  reset (archivoDataBase);
  while not eof (archivoDataBase) do begin
      read (archivoDataBase, persona);
       if (persona.Eliminado=true) and (compareStr (persona.Documento, ObjCom.listaParametros.argumentos[1].datoString)=0) then begin
          result:= true;
          exit;
       end;
  end; //while


  result:= false;
end;


{¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡SOLO VALIDO PARA ELIMINAR UN DOCUMENTO!!!!!!!!!!!!!!!!!}
function modificarRegistroEliminar (documentoLeido:string; personaAmodificar:TRegistroPersona; var baseDatos: TBaseDeDatos): boolean;
var nuevoRegistro, registroValidado: TRegistroPersona;

begin
   reset (archivoDataBase); {abrimos el archivo}

     registroValidado:=validDocumentoEliminar(registroPersona);

     seek (baseDatos, (registroValidado.Id) -1);
     nuevoRegistro.Id:=registroValidado.Id;
     nuevoRegistro.Documento:=registroValidado.Documento;
     nuevoRegistro.Nombre:=registroValidado.Nombre;
     nuevoRegistro.Apellido:=registroValidado.Apellido;
     nuevoRegistro.Edad:=registroValidado.Edad;
     nuevoRegistro.Peso:=registroValidado.Peso;
     nuevoRegistro.Eliminado:=registroValidado.Eliminado; //aqui sigue llegando eliminado a false//

      writeln ('++++ COMPROBACION ELIMINADOS ++++');
      writeln ('DOCUMENTO ',nuevoRegistro.Documento);
      writeln ('NOMBRE ',nuevoRegistro.Nombre);
      writeln ('APELLIDO ',nuevoRegistro.Apellido);
      writeln ('EDAD ',nuevoRegistro.Edad);
      writeln ('PESO ',nuevoRegistro.Peso);
      writeln ('ELIMINADO ',nuevoRegistro.Eliminado);
      writeln;

     write (baseDatos, nuevoRegistro);

     writeln ('Registro modificado correctamente');

     CloseFile (archivoDataBase);

end;


{***********************************
A través de Eliminar -D recibe un documento y pasa a la propiedad de Eliminado de ese registro
de false a true
************************************}
function RegFalseATrue (documentoPersona:string; var baseDatos: TBaseDeDatos): boolean;

var personaAEliminar: TRegistroPersona;

begin


  if not existeDocumentoAEliminar (registroPersona) then begin
    result:=false;
    exit;
  end;


  reset (archivoDataBase); {abrimos el archivo}
  seek (archivoDataBase, (personaAEliminar.Id) -1);
  read (baseDatos, personaAEliminar);
  personaAEliminar.eliminado:=true;
  seek (archivoDataBase, (personaAEliminar.Id) -1);
  write (baseDatos, personaAEliminar);


  {if existeDocumentoAEliminar(registroPersona) then begin
    registroPersona.Eliminado:=true;
    modificarRegistroEliminar (objCom.listaParametros.argumentos[2].datoString, registroPersona,archivoDataBase);
    result:=registroPersona
  end; }
end;






{Recibe todos los parámetros del tipo TRegistroPersona y devuelve un registro de este tipo.
Para su funcionamiento usamos las funciones creadas anteriormente donde validamos que edad
y peso sean caracteres numéricos y que el documento introducido no exista ya en la BD.
Primero se guardan en RegistroPersonaAux y luego se pasan a RegistroPersona.
Si cumple todas las validaciones¡, se posiciona en la última posición libre del archivo
y escribe lo que hayamos pasado.
Finalmente, cierra el archivo.}

{// TODO: falta comprobar EliminadoPersona}
function NuevoReg (documentoPersona, nombrePersona, apellidoPersona:string; idPersona, edadPersona, PesoPersona:byte; eliminadoPersona:boolean): TRegistroPersona;

begin


  registroPersona.Documento:=registroPersonaAux.Documento;
  registroPersona.Nombre:=registroPersonaAux.Nombre;
  registroPersona.Apellido:=registroPersonaAux.Apellido;
  registroPersona.Edad:=registroPersonaAux.Edad;
  registroPersona.Peso:=registroPersonaAux.Peso;
  registroPersona.Id:= registroPersona.Id + 1;


        reset (archivoDataBase);
        seek (archivoDataBase, FileSize(archivoDataBase));
        write (archivoDataBase, registroPersona);
        WRITELN ('[[ELIMINADO ', registroPersona.Eliminado,']]');
        writeln ('Registro agregado correctamente');
        writeln;



 CloseFile (archivoDataBase);

end;



{Recibe el documento introducido a través del parámetro MODIFICAR, y la persona a modificar
del tipo TRegistroPersona. Recibe por referencia la base de datos y devuelve TRUE o FALSE.
Como variables: para guardar el nuevoRegistro y para obtener los datos que nos devuelve la función
"ValidDicumento" (que se pasan a RegistroValidado).
Nos posicionamos dentro del archivo en el ID del registro que quieremos modificar, -1 porque las posiciones          (objCom.listaParametros.argumentos[1].datoString, registroPersonaAux,archivoDataBase)
en el archivo empiezan en 0.
nuevoRegistro.Id:=registroValidado.Id; - para dejar el mismo ID del registro que queremos modificar.
El resto es pasar los datos recogidos por la entrada estandar a la variable NuevoRegistro.
Escribimos el NuevoRegistro en el archivo y mostramos mensaje de confirmación al usuario.}
function modificarRegistro (documentoLeido:string; personaAmodificar:TRegistroPersona; var baseDatos: TBaseDeDatos): boolean;
var nuevoRegistro, registroValidado: TRegistroPersona;

begin
   reset (archivoDataBase); {abrimos el archivo}

   registroValidado:=validDocumento(registroPersona);

   seek (baseDatos, (registroValidado.Id) -1);
   nuevoRegistro.Id:=registroValidado.Id;
   nuevoRegistro.Documento:=registroPersonaAux.Documento;
   nuevoRegistro.Nombre:=registroPersonaAux.Nombre;
   nuevoRegistro.Apellido:=registroPersonaAux.Apellido;
   nuevoRegistro.Edad:=registroPersonaAux.Edad;
   nuevoRegistro.Peso:=registroPersonaAux.Peso;


     write (baseDatos, nuevoRegistro);

     writeln ('Registro modificado correctamente');

     CloseFile (archivoDataBase);

end;


function modificarRegistroEliminado (documentoLeido:string; personaAmodificar:TRegistroPersona; var baseDatos: TBaseDeDatos): boolean;
var nuevoRegistro, registroValidado: TRegistroPersona;

begin
   reset (archivoDataBase); {abrimos el archivo}

   registroValidado:=validDocumento(registroPersona);

     seek (baseDatos, (registroValidado.Id) -1);
     nuevoRegistro.Id:=registroValidado.Id;
     nuevoRegistro.Documento:=registroPersona.Documento;
     nuevoRegistro.Nombre:=objCom.listaParametros.argumentos[2].datoString;
     nuevoRegistro.Apellido:=objCom.listaParametros.argumentos[3].datoString;
     nuevoRegistro.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
     nuevoRegistro.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
     nuevoRegistro.Eliminado:= false;


     write (baseDatos, nuevoRegistro);

     writeln ('Registro creado correctamente');

     CloseFile (archivoDataBase);

end;




{>> buscarTodo: Procedimiento para realizar una busqueda de todos los registros
en Base de Datos y mostrarlos por pantalla.
Abre el archivo y muestra los formatos de tabla.
Lee el archivo hasta el final y escribe, dentro del formato de fila, cada registro}
procedure buscarTodo();

begin

  reset (archivoDataBase);

  writeln (stringEncabezado()); // Encabezado de la tabla de datos.
  writeln (stringSeparadorHorizontal());


  {Se recorre todo el archivo y se imprimer por pantalla cada uno de
  los registros.}
  while not eof (archivoDataBase) do begin
    read (archivoDataBase, registroPersona);


      writeln ('++++ COMPROBACION ELIMINADOS ++++');
      writeln ('DOCUMENTO ',registroPersona.Documento);
      writeln ('NOMBRE ',registroPersona.Nombre);
      writeln ('APELLIDO ',registroPersona.Apellido);
      writeln ('EDAD ',registroPersona.Edad);
      writeln ('PESO ',registroPersona.Peso);
      writeln ('ELIMINADO ',registroPersona.Eliminado);
      writeln;


    if not registroPersona.Eliminado then begin;
       writeln (stringFilaRegistro(registroPersona));
    end;
  end;

  writeln;

  if (FileSize(archivoDataBase)=0) then begin
    writeln ('No hay registros encontrados')
  end else if (FileSize(archivoDataBase)<>0) then begin
    writeln ('Registros encontrados: ',FileSize(archivoDataBase));
  end;

end;


procedure buscarPorDocumento (documentoLeido:string; var personaLeida:TRegistroPersona);

var controlDocumento:boolean;

begin

  writeln (stringEncabezado()); // Encabezado de la tabla de datos.
  writeln (stringSeparadorHorizontal());

  reset (archivoDataBase);
  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaLeida);

    controlDocumento:=compareStr(personaLeida.Documento, documentoLeido)=0;

    if controlDocumento=true then begin
      writeln (stringFilaRegistro(personaLeida));
    end;
  end;

end;



{//TODO: pendiente de comprobar}
{>> eliminarTodo Procedimiento para eliminar todos los registros del Archivo.
No elimina como tal, marca el atributo Eliminado como True}
function eliminarTodo(): TRegistroPersona;
  var personaEliminada: TRegistroPersona;
begin

  reset (archivoDataBase);
  writeln (stringEncabezado());

  while not eof (archivoDataBase) do begin
    read (archivoDataBase, personaEliminada);

    personaEliminada.Eliminado:=true;

    {stringFilaRegistro da el formato de columnas para imprimir por pantalla.}
    writeln (stringFilaRegistro(personaEliminada));
    writeln ('REGISTRO ',personaEliminada.Nombre,' ', 'ELIMINADO ',personaEliminada.Eliminado);
    writeln;
    result:= personaEliminada;
  end;

  CloseFile (archivoDataBase);
end;



(*============================================================================*)
(****************************** BLOQUE PRINCIPAL ******************************)
(*============================================================================*)
begin

  registroPersona.Documento:='';
  registroPersona.Nombre:='';
  registroPersona.Apellido:='';
  registroPersona.Edad:=0;
  registroPersona.Peso:=0;
  registroPersona.Id:=0;

  {se asignan las constantes de tipo string a variables ya que no funcionan usando
  directamente las constantes dentro del case ELIMINAR}
  valorEliminarD:=PARAMETRO_ELIMINAR_DOC;
  valorEliminarT:=PARAMETRO_ELIMINAR_TODO;

  {----Asignamos y creamos el archivo o lo abrimos si ya está creado----}
  AssignFile (archivoDataBase, BASEDEDATOS_NOMBRE_REAL);

  if FileExists (BASEDEDATOS_NOMBRE_REAL) then begin
    reset (archivoDataBase);
  end else begin
    rewrite (archivoDataBase);
  end;
  {------------------------------------------------------------------------}


repeat

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

{--------------------------------------------------------------------------------------------------------------------------------------------}


     NUEVO:begin
       reset (archivoDataBase); {abrimos el archivo}


         {Comprueba el nº de parametros. Se asocia la función a la variable booleana pruebaParametros.
         Si esto es false etonces lanza mensaje de error.
         Con el continue sale del bucle}
         pruebaParametros:=NumeroParametros(objCom);
         if (pruebaParametros=false) then begin
          writeln ('******CASE NUEVO ***** ERROR: Cantidad de parametros incorrecta: [DOCUMENTO, NOMBRE, APELLIDO, EDAD, PESO]');
          writeln;
          continue;
          end;

         {Comprueba que edad es un numero. Se asocia la función a la variable booleana pruebaEdad.
         Si esto es false etonces lanza mensaje de error.
         Con el continue sale del bucle}
         pruebaEdad:=EdadNumero(objCom.listaParametros.argumentos[4].datoNumerico);
          if (pruebaEdad=false) then begin
           writeln ('**** ERROR CASE ****** El parametro edad debe ser numerico******');
           writeln;
           continue;
          end;

         {Comprueba que peso es un numero. Se asocia la función a la variable booleana pruebaPeso.
         Si esto es false etonces lanza mensaje de error.
         Con el continue sale del bucle}
         pruebaPeso:=PesoNumero (objCom.listaParametros.argumentos[5].datoNumerico);
          if (pruebaPeso=false) then begin
           writeln ('***ERROR CASE*****El parametro peso debe ser numerico******');
           writeln;
          continue;
         end;

         {Comprueba que el documento introducido no esté ya guardado. . Se asocia la función a la variable booleana pruebaDocumento.
         Si esto es false etonces lanza mensaje de error.
         Con el continue sale del bucle}
         pruebaDocumento:=documentoRepetido(objCom.listaParametros.argumentos[1].datoString, registroPersonaAux);
         if (pruebaDocumento=false) then begin
            if (comprobarRegEliminados(registroPersonaAux)=false) then begin
                 writeln ('Ya existe este numero de documento >> [',registroPersona.Documento,' ',registroPersona.Nombre,' ',registroPersona.Apellido,']');
                 writeln;
                 continue;
            end;
          end;



        {Si todas las validaciones se cumplen entones llama a la función NuevoReg que es la que permitirá guardar el registro.}
        if (pruebaParametros=true) and (pruebaEdad=true) and (PruebaPeso=true) and (pruebaDocumento=true) then begin
          NuevoReg (registroPersona.Documento, registroPersona.Nombre, registroPersona.Apellido, registroPersona.Id, registroPersona.edad, registroPersona.Peso,registroPersona.Eliminado);
          continue;
        end;

        if (pruebaParametros=true) and (pruebaEdad=true) and (PruebaPeso=true) and (pruebaDocumento=false) and (comprobarRegEliminados(registroPersona)) then begin
          modificarRegistroEliminado (objCom.listaParametros.argumentos[1].datoString, registroPersona, archivoDataBase);
        end;

        writeln;


    end;{FIN CASE "NUEVO"}


{--------------------------------------------------------------------------------------------------------------------------------------------}


    {Recibe 0 parámetros (para mostrar todos los registros) o 1 parámetro (documento, para
    mostrar un documento en concreto.
    Validaciones: que reciba 0 o un parámetro.
                  que ingrese un documento que no exista o fue eliminado}
    BUSCAR: begin

            while ObjCom.listaParametros.cantidad >1 do begin
              writeln ('La cantidad de parametros es incorrecta: [] o [DOCUMENTO]');
              writeln;
              EntradaPrompt();
              registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
              registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
              registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
              registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
              registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
              continue;
            end;



           if ObjCom.listaParametros.cantidad = 0 then begin
             buscarTodo();
           end;

          writeln;

           if ObjCom.listaParametros.cantidad =1 then begin
             buscarPorDocumento (objCom.listaParametros.argumentos[1].datoString,registroPersona);
             writeln;

           end;

     end; {FIN CASE BUSCAR}


{--------------------------------------------------------------------------------------------------------------------------------------------}


     MODIFICAR:begin
      reset (archivoDataBase); {abrimos el archivo}

      {Bloque repeat: Comprobaremos que el número de parámetros introducidos a través del comando
      MODIFICAR no sea <>5. Nos apoyamos en el función NumeroParametros.
      Si los parámetros no son exactamente 5 mostrará un mensaje de error y volverá a
      PROMPT + Lectura comando + lectura datos.
      Se repetirá hasta que los parámetros introducidos sean 5, es decir, hasta que
      pruebaParámetros=true}
      repeat
        pruebaParametros:=NumeroParametros(objCom);
       if (pruebaParametros=false) then begin
          writeln ('ERROR: Cantidad de parametros incorrecta: [DOCUMENTO, NOMBRE, APELLIDO, EDAD, PESO]');
          writeln;
          EntradaPrompt();
          registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
          registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
          registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
          registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
          registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
          continue;
        end;
       until pruebaParametros=true;


       if (comprobarRegEliminados(registroPersonaAux) = true)then begin
        writeln ('No existe un registro con documento DOCUMENTO para modificar.');
        writeln;
        continue;
       end;



      {Bloque repeat: si los parámetros introducidos son exactamente 5, comprobará que el documento
      introducido a través del comando MODIFICAR no exista en la BD.
      El if hace las 2 verificaciones.
      Para el documento: nos apoyamos en la función "existeDocumento" y se le pasa a la variable
      "ElDocExiste. Si devuelve un false, devuelve mensaje de error y vuelve a mostrar
      PROMPT + Lectura comando + lectura datos.
      Se repetirá hasta que los parámetros=5, y el documento exista dentro de los que están en la BD.}
      {repeat
       pruebaParametros:=NumeroParametros(objCom);
       ElDocExiste:=existeDocumento(registroPersona);
       if ((pruebaParametros=true) and (ElDocExiste=false)) and ((comprobarRegEliminados(registroPersonaAux) = false)) then begin
            writeln ('El documento no existe');
            writeln;
            EntradaPrompt();
            registroPersonaAux.documento:=objCom.listaParametros.argumentos[1].datoString;
            registroPersonaAux.Nombre:=objCom.listaParametros.argumentos[2].datoString;
            registroPersonaAux.Apellido:=objCom.listaParametros.argumentos[3].datoString;
            registroPersonaAux.Edad:=objCom.listaParametros.argumentos[4].datoNumerico;
            registroPersonaAux.Peso:=objCom.listaParametros.argumentos[5].datoNumerico;
            continue;
         end;
      until (pruebaParametros=true) and (ElDocExiste=true);}

      {if (pruebaParametros=true) and (ElDocExiste=false) and (registroPersonaAux.Eliminado=true) then begin
          writeln ('El documento no ESTA ACTIVO');
            writeln;
            continue;
         end; }




       {Si las validaciones de los parámetros y el documento son correctas, llama a la función
       que realiza la labor principal, "ModificarRegistro".}
       ModificarRegistro(objCom.listaParametros.argumentos[1].datoString, registroPersonaAux,archivoDataBase);
        writeln;


    end; {FIN CASE MODIFICAR}


{--------------------------------------------------------------------------------------------------------------------------------------------}

      {ELIMINAR: ingresar comando "-T" o -"D documento".
       -Si ingresa "-T" --> se borra todo el archivo (sólo parametro -T
       -Si se ingresa "D documento se "oculta un registro en concreto,
       no se podrá buscar ni modificar. Si no se ingresan los 2 parametros vuelca error. Si todo es correcto, mensaje ok
       El comando eliminar recibe como primer valor el parámetro -D o -T, definidos en las constantes
       PARAMETRO_ELIMINAR_DOC y PARAMETRO_ELIMINAR_TODO respectivamente. Puedes usar la
       operación CompareStr para obtener el primer parámetro de este comando y compararlo con estas
       constantes para ver cuál de ambas opciones fue ingresada, o incluso si no se corresponde con ninguna de
       ellas.}

     ELIMINAR:begin

      reset (archivoDataBase); {abrimos el archivo}

     {Comparamos los strings para verificar si coincide con -T o -D y lo asignamos a una variable}
     compareEliminarD:=compareStr (valorEliminarD, objCom.listaParametros.argumentos[1].datoString)=0;  //TRUE SI COINCIDEN
     compareEliminarT:=compareStr (valorEliminarT,objCom.listaParametros.argumentos[1].datoString)=0;


       {Verificamos que si no es ninguna de los 2 parametros obligatorios, salte error}
       if not (compareEliminarT) then begin
         if not (compareEliminarD) then begin
              writeln ('ERROR: Cantidad de parametros incorrecta: [-T] o [-D,DOCUMENTO]');
              writeln;
              continue;
           end;
         end;


       {Si es -D le indicamos que tiene que llevar asociado un numero de documento,
       es decir, tiene que llevar otro parametro mas (2)}
       if (compareEliminarD) then begin
         if (ObjCom.listaParametros.cantidad<>2) then begin
           writeln ('El comando -D debe continuar con un número de documento');
           writeln;
           continue;
         end;
       end;

       {Si es -D y el documento a eliminar ya existe y esta eliminado mostramos mensaje de error}
       if (compareEliminarD) and (existeDocumentoAEliminar(registroPersona)=false) then begin
         writeln ('ERROR: No hay un registro con documento DOCUMENTO para eliminar.');
         writeln;
         continue;
       end;

       {validación ELIMINAR -D: recibe un nº de documento y ese documento existe.}
      if ((ObjCom.listaParametros.cantidad>0) and (ObjCom.listaParametros.cantidad<=2)) and ((compareEliminarD) and (existeDocumentoAEliminar(registroPersona))) then begin
       RegFalseATrue (objCom.listaParametros.argumentos[2].datoString, archivoDataBase);
       writeln('ELIMINACION CORRECTA');
       writeln;
      end;



    end;{FIN CASE ELIMINAR}
{--------------------------------------------------------------------------------------------------------------------------------------------}


  end; {FIN CASE PRINCIPAL}

until syscom=SALIR;



readln;
end.

