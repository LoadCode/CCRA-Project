/**    Primer algoritmo para el brazo robótico con programación orientada a objetos, sirve para demostrar el movimiento de brazos de multiples secciones.
*      Este codigo no realiza comunicación con hardware externo a la computadora y solo sirve para demostración, ya que no tiene incluidas las restricciones de los modelos reales
*      es por esta razón que es útil, para mostrar posibles áreas de trabajo posteriores y retos por cumplir.
*/


class Brazo
{
        float THETA_MIN; //Ángulos de restricción
        float THETA_MAX;
        int   pivoteX;   //Punto de referencia del brazo
        int   pivoteY;
        int   longBrazo; //Longitud en pixeles del brazo (hace las veces de hipotenusa para los cálculos)
        float xActual;   //variable auxiliar para saber donde está el mouse con respecto al punto de pivote
        float yActual;   //variable auxiliar para saber donde está el mouse con respecto al punto de pivote
        int   xExtremo;  //Coordenadas del punto Extremo del objeto Brazo 
        int   yExtremo;  //estas coordenadas son correspecto al origen de la pantalla, es decir, se usan para graficar directamente
        float theta;     //Ángulo del brazo con respecto a la horizontal definida por el punto de pivote (RADIANES)
        float thetaDeg;  //Ángulo del brazo con respecto a la horizontal definida por el punto de pivote (GRADOS)
        
  Brazo(int pivotX, int pivotY,int longBrazo,int xInicial,int yInicial)
  {
    this.pivoteX   = pivotX;
    this.pivoteY   = pivotY;
    this.longBrazo = longBrazo;
    this.xExtremo  = xInicial;
    this.yExtremo  = yInicial;
  }
  
  void CalcularSistema(int posicionX, int posicionY,boolean movimientoAbsoluto)
  {
    //Esta función realiza el cálculo de todas las variables necesarias en el sistema, como el ángulo de rotación
    //las nuevas coordenadas de los extremos, etc.
    //En caso de que el movimeinto se considere absoluto (movimientoAbsoluto->true) entonces posicionX y posicionY indican las coordenadas del mouseX,Y
    //En caso de que el movimiento sea con respecto al movimiento producido por el desplazamiento de otro brazo más básico entonces posicionX y posicionY indican 
    //las coordenadas del nuevo punto de pivote (el extremo de aquel brazo que se movio y del cual se encuentra el brazo actual conectado) y entonces el cálculo de las variables será diferente
    
    if(movimientoAbsoluto)
    {
      //Se obtienen las coordenadas del mouse con respecto al punto de pivote
      this.xActual = posicionX - pivoteX;
      this.yActual = pivoteY   - posicionY;
      
      if(xActual < 0 && yActual >0 )              //si el puntero se encuentra en el segundo cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI     
          theta = PI+atan(yActual/xActual); 
      else if(xActual < 0 && yActual < 0)         //si el puntero se encuentra en el tercer cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI
          theta = PI+atan(yActual/xActual);
      else if(xActual > 0 && yActual< 0)          //si el puntero se encuentra en el cuarto cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI+PI/2 (es decir +270°)
          theta = TWO_PI + atan(yActual/xActual);
      else                                        //Aquí se encuentra en el primer cuadrante (cálculo normal)
          theta = atan(yActual/xActual);
      
      //A continuación se tienen en cuenta las restricciones de movimiento
      
      
      //Clacula las coordenadas con respecto al origen de la ventana del extremo del brazo (con estos valores se grafica)
      this.xExtremo = pivoteX + int(longBrazo*cos(theta));
      this.yExtremo = pivoteY - int(longBrazo*sin(theta));
      this.thetaDeg = degrees(theta);
    }
    else  //El movimiento es relativo unicamente a un cambio de pivote y no a una orden del mouse
    {
      this.pivoteX  = posicionX;
      this.pivoteY  = posicionY;
      this.xExtremo = pivoteX + int(longBrazo*cos(theta));
      this.yExtremo = pivoteY - int(longBrazo*sin(theta));
    }
  }
  
  void DibujarBrazo()
  {
    line(pivoteX,pivoteY,xExtremo,yExtremo);
  }
}  //END BRAZO






//Inicio Interfaz para 3 grados de libertad

final int ANCHO_VENTANA   = 1200;
final int ALTO_VENTANA    = 630;
final int POSICION_BASE_Y = 610;
final int POSICION_BASE_X = 500;
final int RANGO_DISTANCIA = 80; //el mouse es válido si se encuentra a menos de 50 pixeles del objeto

                    // Brazo(int pivotX, int pivotY,int longBrazo,int xInicial,int yInicial)
Brazo brazoUno  = new Brazo(POSICION_BASE_X,POSICION_BASE_Y-180,180,180+POSICION_BASE_X,POSICION_BASE_Y-180);
Brazo brazoDos  = new Brazo(brazoUno.xExtremo,brazoUno.yExtremo,180,180+brazoUno.xExtremo,brazoUno.yExtremo);
Brazo brazoTres = new Brazo(brazoDos.xExtremo,brazoDos.yExtremo,180,180+brazoDos.xExtremo,brazoDos.yExtremo);

void setup()
{
  size(ANCHO_VENTANA,ALTO_VENTANA);
  strokeWeight(20);
  //smooth();
  frameRate(30);
  DibujarBase();
  brazoUno.DibujarBrazo();
}

void draw()
{
  background(200);
  
  if(mousePressed && (dist(brazoUno.xExtremo,brazoUno.yExtremo,mouseX,mouseY) <= RANGO_DISTANCIA))
  {
    brazoUno.CalcularSistema(mouseX,mouseY,true);
    brazoDos.CalcularSistema(brazoUno.xExtremo,brazoUno.yExtremo,false);
    brazoTres.CalcularSistema(brazoDos.xExtremo,brazoDos.yExtremo,false);
  }
  if(mousePressed && (dist(brazoDos.xExtremo,brazoDos.yExtremo,mouseX,mouseY) <= RANGO_DISTANCIA))
  {
    brazoDos.CalcularSistema(mouseX,mouseY,true);
    brazoTres.CalcularSistema(brazoDos.xExtremo,brazoDos.yExtremo,false);
  }
  if(mousePressed && (dist(brazoTres.xExtremo,brazoTres.yExtremo,mouseX,mouseY) <= RANGO_DISTANCIA))
  {
    brazoTres.CalcularSistema(mouseX,mouseY,true);
  }
  
  
  brazoUno.DibujarBrazo();
  brazoDos.DibujarBrazo();
  brazoTres.DibujarBrazo();
  DibujarBase();
}

void DibujarBase()
{
  line(brazoUno.pivoteX,brazoUno.pivoteY,brazoUno.pivoteX,POSICION_BASE_Y);
}


/*
//Inicio Interfaz para un solo grado de libertad

final int ANCHO_VENTANA   = 1200;
final int ALTO_VENTANA    = 630;
final int POSICION_BASE_Y = 610;
final int POSICION_BASE_X = 500;
final int RANGO_DISTANCIA = 80; //el mouse es válido si se encuentra a menos de 50 pixeles del objeto

                    // Brazo(int pivotX, int pivotY,int longBrazo,int xInicial,int yInicial)
Brazo brazoUno  = new Brazo(POSICION_BASE_X,POSICION_BASE_Y-180,180,180+POSICION_BASE_X,POSICION_BASE_Y-180);

void setup()
{
  size(ANCHO_VENTANA,ALTO_VENTANA);
  strokeWeight(20);
  //smooth();
  frameRate(30);
  DibujarBase();
  brazoUno.DibujarBrazo();
}

void draw()
{
  background(200);
  
  
  if(mousePressed)
   {
     brazoUno.CalcularSistema(mouseX,mouseY,true);
    println("xActual = "+brazoUno.xActual+"  yActual = "+brazoUno.yActual+"   ThetaRads = "+brazoUno.theta+"   "+"ThetaDegs = "+brazoUno.thetaDeg);
   } 
  brazoUno.DibujarBrazo();
  DibujarBase();
}

void DibujarBase()
{
  line(brazoUno.pivoteX,brazoUno.pivoteY,brazoUno.pivoteX,POSICION_BASE_Y);
}
*/


