/**
 * Permite hacerle tracking a un marcador activo en processing y enviar
 * esta información por un puerto TCP.
 */
import processing.video.*;
import processing.serial.*;
import processing.net.*;

Capture camara;
Server servidor;
String datosCursor = "";//Guarda la informacion que se enviara por el puerto.
int toleranciaBrillo = 100;//Para led infrarojo con filtro y luz artificial
//int toleranciaBrillo = 200;//Para led rojo sin filtro y en la oscuridad

//Variable para conocer los brillantes ignorados mayores al valor minimo.
//De (1 A 40) aprox dependiendo de las condiciones de luz, no modificar es lo recomendado.
int valorMinimo = 10;
int width = 1136;
int height = 520;

void settings() {
  size(width, height);
}

void setup() {
  // Iniciar servidor en el puerto 5204
  servidor = new Server(this, 5204);
  //30fps
  camara = new Capture(this, width, height, 30);
  camara.start();
}

void draw() {
  if (camara.available()) {
    camara.read();
    image(camara, 0, 0);
    // Buscar el pixel mas brillante.
    camara.loadPixels();

    int brillanteX = 0; // Coordenada X de la imagen capturada del video
    int brillanteY = 0; // Coordenada Y de la imagen capturada del video
    float valorPixelMasBrillante = 0;
    float valorPixelMasBrillanteIgnorado = 0;

    int indice = 0;
    for (int y = 0; y < camara.height; y++) {
      for (int x = 0; x < camara.width; x++) {
        // Leer el color del pixel ubicado en el indice
        int valorPixel = camara.pixels[indice];
        // Determine el brillo del pixel
        float brilloPixel = brightness(valorPixel);
        //Si el brillo del pixel supera la tolerancia
        //se procesara, sino se ignorara
        if (brilloPixel > toleranciaBrillo) {
          // Si el brillo del pixel es mayor que alguno anteriormente almacenado
          // se guardara el nuevo valor del brillo y tambien la posicion (x,y)
          if (brilloPixel > valorPixelMasBrillante) {
            valorPixelMasBrillante = brilloPixel;
            brillanteX = x;
            brillanteY = y;
          }
        } else {
          //Que valores brillantes estoy ignorando?
          if (brilloPixel > valorMinimo && brilloPixel > valorPixelMasBrillanteIgnorado) {
            valorPixelMasBrillanteIgnorado = brilloPixel;
          }
        }
        indice++;
      }
    }
    // Envia el valor de X,Y seguido de un salto de linea
    // por el puerto 5204
    if (brillanteX > 0 || brillanteY > 0) {
      datosCursor = (width-brillanteX)+","+(height-brillanteY)+"\n";
      //datosCursor = (brillanteX)+","+(brillanteY)+"\n";
    } else {
      datosCursor = "0,0\n";
    }
    //Enviar el dato por el puerto
    servidor.write(datosCursor);

    //Muestre informacion de la captura y datos de brillo en la pantalla
    fill(0, 0, 0, 128);
    rect(5, height-80, 220, 70);
    fill(255, 255, 0, 255);
    text("Cursor : "+datosCursor, 10, height-20);
    text("Valor Brillo : "+valorPixelMasBrillante, 10, height-35);
    text("Tolerancia Brillo : "+toleranciaBrillo, 10, height-50);
    text("Valor Brillo Ignorado (>"+valorMinimo+") : "+valorPixelMasBrillanteIgnorado, 10, height-65);

    // Dibujar un circulo rojo transparente
    // en la posicion del pixel mas brillante
    if (datosCursor != "0,0\n") {
      fill(255, 0, 0, 128);
      ellipse(brillanteX, brillanteY, 20, 20);
    }
  }
}
