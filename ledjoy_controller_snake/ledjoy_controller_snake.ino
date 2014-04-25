/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * Simon Bergkvist & Erik Forsberg wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy us a beer in return Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 */

int snakex[64];
int snakey[64];
int snakelength = 1;
int snakedirection = 1;

int row[8] =     { 14, 15, 16, 17, 2, 3, 4, 5 };
int column[8] =  { 6, 7, 8, 9, 10, 11, 12, 13 };
int joystickX = 19;
int joystickY = 18;

int foodX,foodY;

// Variables will change:
int ledState = HIGH;             // ledState used to set the LED

void setup() {
  // set the digital pin as output:
  for(int i=0;i<8;i++){
    pinMode(row[i], OUTPUT);
    pinMode(column[i], OUTPUT);
  }
  pinMode(joystickX, INPUT);
  pinMode(joystickY, INPUT);
  
  placeSnake();
  placeFood();
}

void loop()
{
  for(int t=0; t<300/snakelength;t++){
    draw(foodX,foodY);
    for(int i=snakelength-1; i>=0; i--){
      draw(snakex[i],snakey[i]);
    }
    snakedirection = getDirection();
  }
  
  
  for(int i=snakelength-1; i>=0; i--){
     if(i==0){
      switch(snakedirection){
        case 0:
          snakex[i]+=1;
          break;
        case 1:
          snakey[i]+=1;
          break;
        case 2:
          snakex[i]-=1;
          break;
        case 3:
          snakey[i]-=1;
          break;
      };
      if(snakex[i] < 0){snakex[i]=7;}
      if(snakex[i] > 7){snakex[i]=0;}
      if(snakey[i] < 0){snakey[i]=7;}
      if(snakey[i] > 7){snakey[i]=0;}
      
      if(checkCollision()==1)
      {
          placeSnake();
          placeFood();          
      }
      if(snakex[i]==foodX && snakey[i]==foodY)
      {
        snakex[snakelength]=foodX;
        snakey[snakelength]=foodY;
        snakelength++;
        placeFood();
      }
    }else{
      snakex[i] = snakex[i-1];
      snakey[i] = snakey[i-1];
    }
  }
}

int getDirection(){
  if(analogRead(joystickX) > 800 && (snakedirection != 0 || snakelength == 1)){
    return 2;
  }
  if(analogRead(joystickX) < 200 && (snakedirection != 2 || snakelength == 1)){
    return 0;
  }
  if(analogRead(joystickY) > 800 && (snakedirection != 1 || snakelength == 1)){
    return 3;
  }
  if(analogRead(joystickY) < 200 && (snakedirection != 3 || snakelength == 1)){
    return 1;
  }
  return snakedirection;
}

void draw(int x, int y)
{
  digitalWrite(row[y], HIGH);
  digitalWrite(column[x], HIGH);
  delay(1);
  digitalWrite(row[y], LOW);
  digitalWrite(column[x], LOW);
}

void placeSnake()
{
  snakex[0]=rand()%8;
  snakey[0]=rand()%8;
  snakelength=1;
  snakedirection=rand()%4;
}
void placeFood()
{
  int onSnake=0;
  do{
    onSnake=0;
    foodX=rand()%8;
    foodY=rand()%8;
    for(int i=snakelength-1; i>=0; i--){
      if(snakex[i]==foodX && snakey[i]==foodY)
      {
        onSnake=1;
      }
    }
  }while(onSnake==1);
}

int checkCollision()
{
  for(int i=snakelength-1; i>0; i--){
    if(snakex[i]==snakex[0] && snakey[i]==snakey[0])
    {
      return 1;
    }
  }
  return 0;
}

