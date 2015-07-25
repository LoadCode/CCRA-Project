//          PROGRAMA PRINCIPAL DEL CCRA-P  (Computer Controlled Robotic ARM Project)

/**
* Este archivo contiene el código fuente principal (estilo firmware) en Arduino para comunicarse con el software de la computaodra principal, realizar las labores de imitación y ejecutar el entrenamiento.
* Este sketch se basa en los avances logrados con los programas AlgoritmoImitacionBrazoVirtual   y   EntrenamientoProgramado
*/

#include <Servo.h>

Servo servoPunta;
Servo servoBase;
Servo servoSoporte;

void setup()
{
  Serial.begin(9600);
  servoBase.attach(10,700,2560); //Este es el servo que controla el brazo princial, está ajustado a esos valores específicos
  servoPunta.attach(9,530,2400); //este es el servo de la parte seuperior
  servoSoporte.attach(11);
}


int Pasos(uint8_t thetaA, uint8_t thetaB)
{
    //Esta función retorna el número de elementos que debe haber en un vector entre un valor y otro
    if(thetaA == thetaB)
        return abs(thetaA-thetaB);
    else
        return abs(thetaA-thetaB)+1;
}

int DistMax(uint8_t a, uint8_t b, uint8_t c)
{
    //Retorna el mayor número entre los 3 argumentos
    if(a>=b && a>= c)
            return a;
    else if(b>=a && b>=c)
        return b;
    else
        return c;
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
  //retorna un entero con el tamanio de la cadena leida sin contar el caracter de final de linea (solo caracteres imprimibles)
  int i = 0, Ndata;
  char *inChar;
  while(1)
  {
    if(Serial.available() > 0)
    {
      Ndata = Serial.available();
      Serial.readBytes(inChar,Ndata);
      cad[i] = *inChar;
      if(cad[i] == '\0') //Se cambió el caracter '\n'->10 por el caracter nulo y poder usar la función strcmp( ) de C
        return i;
      i++;
    }
  }
}

void Entrenamiento()
{
  char strNVertices[4];
  char strServoVert[4]; //Contiene cada valor que llega por el puerto serial en forma de cadena (valores de los vertices)
  int tam;
  int nVertices;
  int nDist;//nDist = nVertices-1;
  int servoA[8];
  int servoB[8];
  int servoC[8];
  int lastIndexA = 0, lastIndexB = 0, lastIndexC = 0;
  int DistanMax, i, tamTotalVec = 0;
  uint8_t servoTrainA[500];  //No se pueden los 3 vectores con longitudes mayores a 500-600
  uint8_t servoTrainB[500];
  uint8_t servoTrainC[500];

  while(!(Serial.available()>0));//Espera por el valor que indica el número de vertices
  tam = leer(strNVertices);
  nVertices = str2int(strNVertices,tam); //Se obtiene el número de vertices con el que se realizará el entrenamiento
  nDist = nVertices - 1;

  //Se obtienen los valores de los puntos/coordenadas de los vertices del entrenamiento
  for(i = 0; i < nVertices; i++)
  {
  	while(!(Serial.available()>0));
  	tam = leer(strServoVert);
  	servoA[i] = str2int(strServoVert,tam);
  }

  for(i = 0; i < nVertices; i++)
  {
  	while(!(Serial.available()>0));
  	tam = leer(strServoVert);
  	servoB[i] = str2int(strServoVert,tam);
  }

  for(i = 0; i < nVertices; i++)
  {
  	while(!(Serial.available()>0));
  	tam = leer(strServoVert);
  	servoC[i] = str2int(strServoVert,tam);
  }

  for(i = 0; i<nDist; i++)
  {
    DistanMax = DistMax(Pasos(servoA[i],servoA[i+1]),Pasos(servoB[i],servoB[i+1]),Pasos(servoC[i],servoC[i+1]));
    tamTotalVec += DistanMax;
    lastIndexA = linspace2(servoTrainA,servoA[i],servoA[i+1],DistanMax,lastIndexA);
    lastIndexB = linspace2(servoTrainB,servoB[i],servoB[i+1],DistanMax,lastIndexB);
    lastIndexC = linspace2(servoTrainC,servoC[i],servoC[i+1],DistanMax,lastIndexC);
  }

  Movimiento(servoTrainA,servoTrainB,servoTrainC,tamTotalVec);
}

void loop()
{
  char strAnguloBase[5], strAnguloBrazo[5], strAnguloSoporte[5];

  while(1)
  {
    if(Serial.available() > 0)
    {
      int tam = leer(strAnguloBase);
      if(!(strcmp(strAnguloBase,"Ent") == 0))
	  {
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
	  else if(strcmp(strAnguloBase,"Ent") == 0)
	  {
	  	//Si lo que llegó fue la cadena que indica el entramiento, se ejecuta el siguiente código
	  	Entrenamiento();
	  	//Dentro de la función Entrenamiento() se llama a la rutina Movimiento() para que el movimiento se ejecute continuamente
	  	//Si se desea dar nuevas indicaciones/entrenamiento al brazo robótico se debe reiniciar el sistema
	  }
    }
  }
}

int linspace2(uint8_t *vec, float mini, float maxi, int nPasos,int index)
{
    //Esta función llena un vector de enteros con valores entre Mínimo y Máximo linealmente espaciados desde un indice especificado previamente

        if(nPasos == 1)
            nPasos = 2;

        float paso = (maxi-mini)/(nPasos-1), acu = mini;  //Se obtiene el valor del paso adecuado para cumplir con los requisitos del vector
        Serial.println(paso);
        int i = 0;
        for(; i< nPasos; i++,acu+=paso)
            vec[index+i] = (uint8_t)round(acu);
        return index+i;
}


void Movimiento(uint8_t *servoTrainA,uint8_t *servoTrainB,uint8_t *servoTrainC,int tam)
{
  while(1)
  {
    for(int i = 0;i < tam; i++)
    {
      servoPunta.write(map((int)servoTrainA[i],0,180,180,0));
      servoBase.write((int)servoTrainB[i]);
      servoSoporte.write((int)servoTrainC[i]);
      delay(11);
    }
    for(int i = tam-1; i>=0; i--)
    {
      servoPunta.write(map((int)servoTrainA[i],0,180,180,0));
      servoBase.write((int)servoTrainB[i]);
      servoSoporte.write((int)servoTrainC[i]);
      delay(11);
    }
  }
}

int DistMax2(int a, int b)
{
    //Retorna el mayor número entre los 2 argumentos
    if(a>b)
      return a;
    else
      return b;
}
*/
