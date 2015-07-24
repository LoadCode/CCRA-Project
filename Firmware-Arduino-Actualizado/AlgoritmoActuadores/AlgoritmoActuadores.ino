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

int DistMax2(int a, int b)
{
    //Retorna el mayor número entre los 3 argumentos
    if(a>b)
      return a;
    else
      return b;
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

void loop() {
  int nVertices = 6;
  int nDist = nVertices-1;//1

  int servoA[]   = {90,180,120,120,180,90};
  int servoB[]   = {160,160,100,100,160,160};
  int servoC[]   = {10,10,10,110,110,110};
  
  int lastIndexA = 0, lastIndexB = 0, lastIndexC = 0;
  int DistanMax, i, tamTotalVec = 0;
  
  uint8_t servoTrainA[500];  //No se pueden los 3 vectores con longitudes mayores a 500-600
  uint8_t servoTrainB[500]; 
  uint8_t servoTrainC[500];
  
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

int linspace2(uint8_t *vec, float mini, float maxi, int nPasos,int index)
{
    //Esta función llena un vector de enteros con valores entre Mínimo y Máximo linealmente espaciados desde un indice especificado previamente

        if(nPasos == 1)
            nPasos = 2;

        float paso = (maxi-mini)/(nPasos-1), acu = mini;  //Se obtiene el valor del paso adecuado para cumplir con los requisitos del vector
        Serial.println(paso);
        int i = 0;
        for(; i< nPasos; i++,acu+=paso)
        {
            vec[index+i] = (uint8_t)round(acu);
            //Serial.println(vec[index+i]);
        }
        return index+i;
}


void Movimiento(uint8_t *servoTrainA,uint8_t *servoTrainB,uint8_t *servoTrainC,int tam)
{
  while(1)
  {
    for(int i = 0;i < tam; i++)
    {
      servoPunta.write((int)servoTrainA[i]);
      servoBase.write((int)servoTrainB[i]);
      servoSoporte.write((int)servoTrainC[i]);
      delay(11);
    }
    for(int i = tam-1; i>=0; i--)
    {
      servoPunta.write((int)servoTrainA[i]);
      servoBase.write((int)servoTrainB[i]);
      servoSoporte.write((int)servoTrainC[i]);
      delay(11);
    }
  }
}

