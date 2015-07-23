//     PROGRAMA DE IMITACIÓN DE MOVIMIENTO

/**
* El siguiente código hace parte del proyecto de entrenamiento, el programa de este archivo es el encargado de realizar la lectura (cominucación con el software del modelo virtual)
* el siguiente programa solo está pensado para realizar la lecura y escritua de los angulos en los servomotores que hacen las veces de actuadores en el modelo físico del robot.
* este archivo está pensado solo para la comunicación entre modelo físico y computadora principal, para el entrenamiento, se presenta el programa EntrenamientoProgramado.ino
* 
*/

#include <Servo.h>

Servo servoBase;
Servo servoPunta;
Servo servoSoporte;

void setup()
{
  servoBase.attach(10,700,2560); //Este es el servo que controla el brazo princial, está ajustado a esos valores específicos
  servoPunta.attach(9,530,2400); //este es el servo de la parte seuperior
  servoSoporte.attach(11);
  Serial.begin(9600);
}


void loop()
{
  char strAnguloBase[5], strAnguloBrazo[5], strAnguloSoporte[5];
  
  while(1)
  {
    if(Serial.available() > 0)
    {
      int tam = leer(strAnguloBase);
      int angulo = str2int(strAnguloBase,tam);
      servoBase.write(angulo);
      
      while(!(Serial.available() > 0));
      
      tam = leer(strAnguloBrazo);
      angulo = str2int(strAnguloBrazo,tam);
      int maped = map(angulo,0,180,180,0); //Es necesario invertir el valor del angulo, para conpensar el hecho de que el servo quedó al revés (lol)
      servoPunta.write(maped);
      
      while(!(Serial.available() > 0)); //El tercer valor que se recibe es el del soporte
      tam = leer(strAnguloSoporte);
      angulo = str2int(strAnguloSoporte,tam);
      servoSoporte.write(angulo); 
    }
  }
}


int str2int(char *strnum,int tam)
{
    //Esta función convierte en un valor numérico, el valor contenido en la cadena de caracteres 'strnum'

    //Se obtiene un vector donde cada posicion contiene el valor correspondiente en formato numérico
    int vec[6], i, magnitud = 1, numero = 0;                                 //puede contener un número de 6 cifras
    //int tam = str_length(strnum);

    for(i = 0;i < tam; i++)
        vec[i] = strnum[i] - 48; //obtiene numeros reales en el mismo orden de la cadena

    for(i  = 1; i < tam; i++)
        magnitud *= 10;

    for(i = 0; i<tam; i++,magnitud/=10) //Se arma el número correspondiente
        numero += (magnitud*vec[i]);

    return numero;
}


int leer(char *cad)
{
  //Esta función lee los caracteres que se van reciviendo por el puerto serial hasta que aparece el caracter de final de linea '\n'
  //retirna un entero con el tamanio de la cadena leida sin contar el caracter de final de linea (solo caracteres imprimibles)
  int i = 0, Ndata;
  char *inChar;
  while(1)
  {
    if(Serial.available() > 0)
    {
      Ndata = Serial.available();
      Serial.readBytes(inChar,Ndata);
      cad[i] = *inChar;
      if(cad[i] == '\n')
        return i; 
      i++;
    }
  }
}

