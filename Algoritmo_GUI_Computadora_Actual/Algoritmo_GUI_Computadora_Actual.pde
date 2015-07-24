class Base
{
  /**
            CLASE  BASE
            Esta clase hace referencia a un objeto de tipo Base del brazo robótico
            realiza los cálculos y la renderización apropiada para la base del brazo
            
            FORMATO DEL CONSTRUCTOR:       Base(int xPivote,int yPivote,int distanciaPivoteMin,int distanciaPivoteMax,float thetaInit)
            
            MÉTODOS:       void CalcularBase(mouseX, mouseY)     void DibujarBase()
            
            CONDICIÓN DE USO:
                              if(mousePressed    &&   dist(mouseX,mouseY,servoBase.pivoteX,servoBase.pivoteY) >= servoBase.distPivoteMin     &&    dist(mouseX,mouseY,servoBase.pivoteX,servoBase.pivoteY) <= servoBase.distPivoteMax)
    servoBase.CalcularAngulo(mouseX,mouseY);
  servoBase.DibujarBase();
            
  */
  
  int pivoteX;   //Coordenadas del centro del arco
  int pivoteY;
  float xRelativo; //Posición del mouse relativa al punto de pivote
  float yRelativo; 
  float distPivoteMin;  //Distancia mínima a la que puede estar el cursor
  float distPivoteMax;  //Distancia máxima a la que puede estar el cursor
  float theta;          //Ángulo del mouse con respecto a la horizontal
  float thetaServo;
  int ancho;            //Ancho del Arco
  
  Base(int xPivote,int yPivote,float distanciaPivoteMin,float distanciaPivoteMax,int thetaInit)
  {
    pivoteX = xPivote;
    pivoteY = yPivote;
    distPivoteMin = distanciaPivoteMin;
    distPivoteMax = distanciaPivoteMax;
    theta = radians(thetaInit);
    ancho = 30;
    DibujarBase(); 
  }
  
  void CalcularAngulo(int xPosicion,int yPosicion)
  {
    //se obtiene la posicion del mouse con respecto al centro del arco
    xRelativo = xPosicion - pivoteX;
    yRelativo = pivoteY   - yPosicion;
    
    //Se aplica una restricción en caso de que el mouse esté por debajo del arco
    if(yRelativo < 0)
      yRelativo = 0;
      
      
    //Se determina el ángulo correcto, y se evitan los posibles errores inducidos por la tangente
    if(xRelativo == 0)
      theta = HALF_PI;  // 90°   
    else if(yRelativo == 0 && xRelativo >= 0)
      theta = 0; //0°
    else if(yRelativo == 0 && xRelativo < 0)
      theta = PI; //180°
    else if(xRelativo > 0)
      theta = atan(yRelativo/xRelativo);
    else
      theta = PI + atan(yRelativo/xRelativo);
    thetaServo = degrees(theta);
    //En este punto ya se obtuvo el theta con respecto al semieje positivo de X   
  }
  
  void DibujarBase()
  {
    strokeCap(SQUARE);
    noFill();
    stroke(#00AACC);
    strokeWeight(ancho);
    arc(pivoteX,pivoteY,210,210,PI,TWO_PI); //Arco básico
    stroke(0xFFCC0000);
    arc(pivoteX,pivoteY,210,210,TWO_PI-theta,TWO_PI);  //Se grafica un arco rojo desde 0° hasta donde esté el mouse
    stroke(0xFF00AACC);
    strokeCap(ROUND);
  }
}









class Brazo
{
        float THETA_MIN; //Variables para saber donde se encuentra el valor mínimo y máximo del servo en cada momento con respecto a al horizontal de cada brazo (estas variables están en grados)
        float THETA_MAX;
        int SERVO_MIN;   //Valor mínimo del servo (normalmente 0°)
        int SERVO_MAX;   //Valor máximo del servo (normalmente 180°)
        int   pivoteX;   //Punto de referencia del brazo
        int   pivoteY;
        int   longBrazo; //Longitud en pixeles del brazo (hace las veces de hipotenusa para los cálculos)
        float xActual;   //variable auxiliar para saber donde está el mouse con respecto al punto de pivote
        float yActual;   //variable auxiliar para saber donde está el mouse con respecto al punto de pivote
        int   xExtremo;  //Coordenadas del punto Extremo del objeto Brazo 
        int   yExtremo;  //estas coordenadas son correspecto al origen de la pantalla, es decir, se usan para graficar directamente
        float theta;     //Ángulo del brazo con respecto a la horizontal definida por el punto de pivote (RADIANES)
        float thetaAnt;  //Valor inmediatamente anterior del ángulo con respecto a la horizontal
        float thetaDeg;  //Ángulo del brazo con respecto a la horizontal definida por el punto de pivote (GRADOS)
        float thetaServo;//valor del servomotor
        
        
        
        
  Brazo(int pivotX, int pivotY,int longBrazo,float thetaMin, float thetaMax, float anguloInicial)
  {
    this.pivoteX   = pivotX;
    this.pivoteY   = pivotY;
    this.longBrazo = longBrazo;
    this.THETA_MIN = thetaMin;
    this.THETA_MAX = thetaMax;
    this.theta     = radians(anguloInicial);
    this.thetaAnt  = radians(anguloInicial);
    CalcularPosicionInicial(anguloInicial);    
  }
  
  void CalcularPosicionInicial(float anguloInicial)
  {
    //Esta función es llamada en el constructor de la clase Brazo con ya que al crear el brazo, se indica el ángulo inicial con el que aparecerá ene l sistema
    //Aquí se calcular xExtremo y yExtremo, y luego se llama al método CalcularSistema(xExtremo, yExtremo) para que aplique las restricciones pertinentes en caso de ser necesario, e inicializar las variables correspondientes
    
    float extremoX = this.pivoteX + longBrazo*cos(radians(anguloInicial));
    float extremoY = this.pivoteY - longBrazo*sin(radians(anguloInicial));
    CalcularSistema(int(extremoX),int(extremoY));    
  }
  
  
  
  //Corregir esta
  void CalcularSistemaRelativo(int posicionX, int posicionY,float thetaPrelim,float thetaPrelimAnt)
  {
    //Esta función realiza el cálculo de todas las variables necesarias en el sistema, como el ángulo de rotación
    //las nuevas coordenadas de los extremos, etc.
    //En caso de que el movimeinto se considere absoluto (movimientoAbsoluto->true) entonces posicionX y posicionY indican las coordenadas del mouseX,Y
    //En caso de que el movimiento sea con respecto al movimiento producido por el desplazamiento de otro brazo más básico entonces posicionX y posicionY indican 
    //las coordenadas del nuevo punto de pivote (el extremo de aquel brazo que se movio y del cual se encuentra el brazo actual conectado) y entonces el cálculo de las variables será diferente
    
    this.thetaAnt = theta; //lo primero que hay que hacer, es salvar el último valor de theta
    
    float delta;    
     
      //delta = degrees(thetaPrelim) - degrees(thetaPrelimAnt); //se obtiene el desplazamiento del brazo al que nos encontramos conectados
      delta = thetaPrelim - thetaPrelimAnt;
      this.THETA_MIN += delta;
      this.THETA_MAX += delta;
      
      //print("theta_Antes = "+degrees(theta));      
      //A continuación se tienen en cuenta las restricciones de movimiento con respecto a los nuevos valores THETA_MIN y THETA_MAX
      //Que han cambiado debido al movimiento relativo con respecto al brazo que nos encontramos conectados y las limitaciones uqe presentan los servos
      //por lo tanto en cierto momento, los servos llegarán a su angulo límite y el this.theta tendra que cambiar
      if(degrees(theta) > THETA_MAX || degrees(theta) < THETA_MIN)
          AlgoritmoAnguloRestriccion();
      //println("    theta_Despues = "+degrees(theta)+"  Theta_Min = "+THETA_MIN+"  Theta_Max = "+THETA_MAX+ "  delta = "+delta);    
      //valor en grados para el servomotor
      this.thetaServo = int(degrees(theta) - THETA_MIN);
      
      this.pivoteX  = posicionX;
      this.pivoteY  = posicionY;
      this.xExtremo = pivoteX + int(longBrazo*cos(theta));
      this.yExtremo = pivoteY - int(longBrazo*sin(theta));
  }
  
  
  
  
  void CalcularSistema(int posicionX, int posicionY)
  {
    //Esta función realiza el cálculo de todas las variables necesarias en el sistema, como el ángulo de rotación
    //las nuevas coordenadas de los extremos, etc.
    //En caso de que el movimeinto se considere absoluto (movimientoAbsoluto->true) entonces posicionX y posicionY indican las coordenadas del mouseX,Y
    //En caso de que el movimiento sea con respecto al movimiento producido por el desplazamiento de otro brazo más básico entonces posicionX y posicionY indican 
    //las coordenadas del nuevo punto de pivote (el extremo de aquel brazo que se movio y del cual se encuentra el brazo actual conectado) y entonces el cálculo de las variables será diferente
    
      //Se obtienen las coordenadas del mouse con respecto al punto de pivote
      this.xActual = posicionX - pivoteX;
      this.yActual = pivoteY   - posicionY;
      
      this.thetaAnt = theta; //lo primero que hay que hacer, es salvar el último valor de theta
      
      //Solución del error de indeterminación en la tangente
      
      //para X = 0
      if(xActual == 0 && yActual > 0)
        this.theta = HALF_PI; //90°
      else if(xActual == 0 && yActual < 0)
        this.theta = PI + HALF_PI; //270°
      else if(yActual == 0 && xActual > 0)    //para Y = 0
         this.theta = 0;//0°
      else if(yActual == 0 && xActual < 0)
         this.theta = PI; //180°
      else
         CalcularAnguloActual();  //Almacena en this.theta el ángulo actual sin problemas de indeterminaciones
      
      //A este punto ya se tiene el ángulo donde se encuentra el mouse con respecto a la horizontal impuesta por el punto de pivote
             
      
      //A continuación se tienen en cuenta las restricciones de movimiento
      if(degrees(theta) > THETA_MAX || degrees(theta) < THETA_MIN)
          AlgoritmoAnguloRestriccion();
     
     
      //Teniendo el ángulo theta correctamente calculado y acotado a las restricciones reales.
      //Se calculan las coordenadas con respecto al origen de la ventana del extremo del brazo (con estos valores se grafica)
      this.xExtremo = pivoteX + int(longBrazo*cos(theta));
      this.yExtremo = pivoteY - int(longBrazo*sin(theta));
      this.thetaDeg = degrees(theta);
      
      //valor en grados para el servomotor
      this.thetaServo = int(degrees(theta) - THETA_MIN);    
  }
  
  
  void CalcularAnguloActual()
  {
    //Esta función es llamada para obtener el ángulo en el cual se encuentra el puntero del mouse con respecto a la horizontal impuesta por el punto de pivote
    //Hay que tener en cuenta que esta función solo se usa si no hay problema de posibles indeterminaciones tal vez con X = 0 en la tangente por ejemplo
      if(xActual < 0 && yActual >0 )      //si el puntero se encuentra en el segundo cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI     
        theta = PI+atan(yActual/xActual); 
      else if(xActual < 0 && yActual < 0)         //si el puntero se encuentra en el tercer cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI
        theta = PI+atan(yActual/xActual);
      else if(xActual > 0 && yActual< 0)          //si el puntero se encuentra en el cuarto cuadrante => el ángulo real (con respecto al semi-eje positivo de X) será theta+PI+PI/2 (es decir +270°)
          theta = TWO_PI + atan(yActual/xActual);
      else                                        //Aquí se encuentra en el primer cuadrante (cálculo normal)
          theta = atan(yActual/xActual);
  }
  
  
  
  void AlgoritmoAnguloRestriccion()
  {
    //Esta función es llamada para verificar que los limites del modelo físico sean iguales a los del modelo virtual
    //es decir, esta función verifica que el máximo ángulo que se obtenga en el modelo virtual sea consistente con el máximo ángulo que pueden entregar los servomotores en el brazo real
    
    float distAngularMin; //Angulo entre el theta actual y el ángulo mínimo (grados)
    float distAngularMax; //Angulo entre el theta actual y el ángulo máximo (grados)
    
    
    distAngularMin = MenorAngulo(THETA_MIN,degrees(this.theta));
    distAngularMax = MenorAngulo(THETA_MAX,degrees(this.theta));
    if(distAngularMin < distAngularMax)
      this.theta = radians(THETA_MIN);
    else
      this.theta = radians(THETA_MAX);
  }
  
  
  
  
  float MenorAngulo(float angRef,float angMouse)
  {
    //Esta función calcula el menor ángulo entre dos líneas imaginarias, definidas por un ángulo referencia normalmente THETA_MAX o THETA_MIN
    //y el ángulo Actual this.theta en el cual se encuentra el puntero del mouse (los ángulos deben pasarse en grados)
    
    angRef   = angRef;
    angMouse = floor(angMouse);
    float angMouseOpuesto;
    angMouseOpuesto = angMouse+180;
    if(angMouseOpuesto > 360)
      angMouseOpuesto -= 360;
      
    if(angRef > angMouseOpuesto && angRef < angMouse)
      return (angMouse - angRef);
    else if((angRef > angMouseOpuesto)  && (angMouse > 180)) //&& (angRef > angMouse) era condicion hasta que se encontré el caso angRef = 270° y angMouse = 271 (no entraba), sol retornar el abs()
      return abs(angRef - angMouse);
    else if((angRef > angMouseOpuesto) && (angRef > angMouse))
      return (360 - angRef + angMouse);
    else if((angRef < angMouseOpuesto) && (angRef > angMouse))
      return (angRef - angMouse);
    else if ((angRef < angMouseOpuesto) && (angRef < angMouse) && (angMouseOpuesto > 180))
      return (angMouse - angRef);
    else if ((angRef < angMouseOpuesto) && (angRef < angMouse))
      return (360 - angMouse + angRef);
      
    return 0;
  }
  
  void DibujarRangoAngular()
  {
    //Esta función traza una linea indicando el rango de operación desde THETA_MIN a THETA_MAX en cada momento
    float x1, y1, x2, y2;
    x1 = pivoteX + 60*cos(radians(THETA_MIN));
    x2 = pivoteX + 60*cos(radians(THETA_MAX));
    y1 = pivoteY - 60*sin(radians(THETA_MIN));
    y2 = pivoteY - 60*sin(radians(THETA_MAX));
    line(pivoteX,pivoteY,x1,y1);
    line(pivoteX,pivoteY,x2,y2);
  }
  
  void DibujarBrazo()
  {
    strokeWeight(20);
    stroke(0xFF00AACC);
    ellipse(pivoteX,pivoteY,15,15);
    line(pivoteX,pivoteY,xExtremo,yExtremo);
    fill(255);
    strokeWeight(4);
    ellipse(pivoteX,pivoteY,16,16);
    strokeWeight(1);
    stroke(#ff0000);
    DibujarRangoAngular();
    stroke(#000000);
  }
}  //END BRAZO


























//Inicio Interfaz para un solo grado de libertad

final int ANCHO_VENTANA   = 1200;
final int ALTO_VENTANA    = 630;
final int POSICION_BASE_Y = 610;
final int POSICION_BASE_X = 500;
final int RANGO_DISTANCIA = 40; //el mouse es válido si se encuentra a menos de 50 pixeles del objeto


//Comunicacion Serial
import processing.serial.*;

Serial miPuerto = new Serial(this,Serial.list()[0],9600);

                    //   Brazo(POSICION_BASE_X,POSICION_BASE_Y-180,180,0,180,100)                 
                    
                    //Constructor:
                    //        Brazo(  Xpivote,   Ypivote,   Longitud_Brazo,   THETA_MIN,   THETA_MAX,   Angulo_Inicial)
Brazo brazoUno   = new Brazo(POSICION_BASE_X,POSICION_BASE_Y-180,180, 16,170,90); //0°-160° init 90°
Brazo brazoDos   = new Brazo(brazoUno.xExtremo,brazoUno.yExtremo,180, 90,270,90);//90°-270° init 90°......90,180,100);
Base servoBase;

void setup()
{
  size(ANCHO_VENTANA,ALTO_VENTANA);
  strokeWeight(20);
  servoBase   = new Base(700,600,90,120,0);
  smooth();
  frameRate(30);
  println(Serial.list());
  DibujarBrazoSoporte();
  brazoUno.DibujarBrazo();
}

int periodo = 0; //cuenta las vecesque se ejecuta la función draw()

void draw()
{
  background(0);
  if(mousePressed && (dist(brazoUno.xExtremo,brazoUno.yExtremo,mouseX,mouseY) <= RANGO_DISTANCIA))
  {
    brazoUno.CalcularSistema(mouseX,mouseY);
    brazoDos.CalcularSistemaRelativo(brazoUno.xExtremo,brazoUno.yExtremo,int(degrees(brazoUno.theta)),int(degrees(brazoUno.thetaAnt)));
  } 
  if(mousePressed && (dist(brazoDos.xExtremo,brazoDos.yExtremo,mouseX,mouseY) <= RANGO_DISTANCIA))
  {
    brazoDos.CalcularSistema(mouseX,mouseY);
  } 
  if(mousePressed    &&   dist(mouseX,mouseY,servoBase.pivoteX,servoBase.pivoteY) >= servoBase.distPivoteMin     &&    dist(mouseX,mouseY,servoBase.pivoteX,servoBase.pivoteY) <= servoBase.distPivoteMax)
    servoBase.CalcularAngulo(mouseX,mouseY);
    
  periodo++;
  if(periodo == 2)
  {
    periodo = 0;
    EscribirSerial(int(brazoUno.thetaServo));
    EscribirSerial(int(brazoDos.thetaServo));
    EscribirSerial(int(servoBase.thetaServo));
    //println(servoBase.thetaServo);
  }
  
  brazoUno.DibujarBrazo();
  brazoDos.DibujarBrazo();
  servoBase.DibujarBase();
  DibujarBrazoSoporte();
}

void EscribirSerial(int angulo)
{ 
  String anguloCadena;
  anguloCadena = Integer.toString(angulo);
  miPuerto.write(anguloCadena);
  miPuerto.write(0);//miPuerto.write(10); //El 10 es caracter '\n' y el 0 es el caracter nulo. para poder usar la función strcmp() de C
}

void DibujarBrazoSoporte()
{
  strokeWeight(20);
  stroke(0xff00AACC);
  line(brazoUno.pivoteX,brazoUno.pivoteY,brazoUno.pivoteX,POSICION_BASE_Y);
  fill(255);
  strokeWeight(4);
  ellipse(brazoUno.pivoteX,brazoUno.pivoteY,16,16);
}







