byte pin = A0;
String buff[3];

void setup() {
  Serial.begin(115200);
      while (!Serial) {
     ; // wait for serial port to connect
  }
}

void loop() {
  for(int i=0;i<3;i++){
    buff[i]=String(analogRead(pin+i));
  }
  Serial.print(String(micros())+","+buff[0]+","+buff[1]+","+buff[2]+"\n");
  delayMicroseconds(8500);
}
