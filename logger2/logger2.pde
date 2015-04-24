import processing.serial.*;
Serial myPort;
int P = 1000;
int value[] = new int[4];//value[0]..time  value[1-3]..A0-A2
int past[][][] = new int[3][P][2];
int num=0;
color col[] = new color[3]; 
boolean flag[] = new boolean[3];

 float a; 
 float F = 10; // cutoff frequency

PrintWriter pw;
//--------------------------------------------------------------------------------------------------
void setup() {
  size(1000, 500);
  background(255); 
  frameRate(30);
  myPort = new Serial(this,Serial.list()[0], 115200);
  myPort.bufferUntil('\n');
  delay(200);
  initGraph();
  String title = String.valueOf(year()) + '_' + String.valueOf(month()) + '_' + String.valueOf(day()) + '_' + String.valueOf(hour()) + '_' + String.valueOf(minute()) + '_' + String.valueOf(second()) + "_Logger2.txt";
  pw = createWriter(title);
}
 //--------------------------------------draw------------------------------------------------------------
void draw() {
    background(255);
    for(int i=0;i<3;i++){
      if(flag[i]){drawPoints(past[i],col[i]);}
    }
    drawGraphPresets();
}
 //--------------------------------------drawpoints------------------------------------------------------------
void drawPoints(int[][] p, color c){
    for(int j=0;j<P;j++){
    float tx = (p[0][1]-p[j][1])*0.001*0.25;
    float ty = map(p[j][0], 0, 1023, height, 0);
    stroke(c);
    strokeWeight(2);
    if(tx<=width)point(tx,ty);
    }
}
 
 //-------------------------------
void initGraph() {   
  for(int h=0;h<3;h++){
  for(int i=0;i<P;i++){
    past[h][i][0] = 0;
    past[h][i][1] = 0;
  }
  }
  noStroke();
  col[0] = color(255, 0, 0);
  col[1] = color(0, 0, 155);
  col[2] = color(0, 155, 0);
  for(int i=0;i<3;i++){
    flag[i]=true;
  }
}

void drawGraphPresets(){
     stroke(0);
     strokeWeight(1);
      line(250,0,250,height);
      line(500,0,500,height);
      line(750,0,750,height);
     strokeWeight(2);
     if(flag[0]) drawHanrei("A0",col[0],30);
     if(flag[1]) drawHanrei("A1",col[1],60);
     if(flag[2]) drawHanrei("A2",col[2],90);
     
  fill(0);
  textSize(16);
  text((int(value[0])/1000000.0),width-100,height-20);
}

void drawHanrei(String s,color c, int h){
  fill(0);
  textSize(16);
  text(s,950,h+8);
  stroke(c);
  for(int i=0;i<5;i++){
    point(890+i*10,h);
  }
}
 //--------------------------------------------------------------------------------------------------
 
void serialEvent(Serial p) { 
  try{
  if(myPort.available()>1){
    String myString = myPort.readStringUntil('\n');
    if(checkData(myString)){
      println(myString);
      pw.print(myString);
     // textString = textString + myString;//buffer & append raw data
      purseData(myString);
      for(int i=0;i<3;i++){
        queueData(past[i],i);
      }
      num++;
    }
  if(num>=P){num=0;}
  }
  }catch(RuntimeException e){
  }
}
//--------------------------------queueData
void queueData(int[][] p,int pin){
    for(int i=P-1;i>0;i--){//imamade no data zurasu
         p[i][0]=p[i-1][0]; //y
         p[i][1]=p[i-1][1]; //x
        }
    p[0][1] = value[0];//time(micros)
    a = 1 - exp(-2*PI*F*(p[0][1] - p[1][1])*0.001*0.001);
    p[0][0] = int(value[pin+1]*a + p[1][0]*(1-a));
    num++;
}

//-----------pursedata
boolean checkData(String s){
  String[] data = splitTokens(trim(s),",");
  if(data[0]==null){return false;}
  for(int i=1;i<4;i++){
    if(int(data[i])<0||int(data[i])>1023){return false;}
  }
  return true;
}
void purseData(String s){
  String[] data = splitTokens(trim(s),",");
  for(int i=0;i<4;i++){
  value[i] = int(data[i]);
  }
}
//--------------------------------------------------------------------------------------------------

void keyPressed() {
  if (key == 's') { 
    pw.println("start");
    println("start");
  }
  if (key == 'e') { 
    pw.println("end");
    println("end");
  }
   if (key == '1') { 
      flag[0] = !flag[0];
    println("A0"+flag[0]);
  }
   if (key == '2') { 
      flag[1] = !flag[1];
    println("A1"+flag[1]);
  }
   if (key == '3') { 
      flag[2] = !flag[2];
    println("A2"+flag[2]);
  }
  
  if(keyCode==ENTER){
    pw.println("ENTER");
    pw.close();
    exit();
  }
}

