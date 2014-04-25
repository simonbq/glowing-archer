/* Copyright Simon Bergkvist 2014 */

/* 
//DEFAULT
int leds[8][8] = {
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0}
};
//DOTA LOGO 1
int leds[8][8] = {
{1, 1, 1, 1, 1, 1, 1, 1},
{1, 0, 0, 0, 0, 0, 0, 1},
{1, 0, 1, 0, 0, 1, 0, 1},
{1, 0, 0, 1, 0, 0, 0, 1},
{1, 0, 0, 0, 1, 0, 0, 1},
{1, 0, 1, 0, 0, 1, 0, 1},
{1, 0, 0, 0, 0, 0, 0, 1},
{1, 1, 1, 1, 1, 1, 1, 1}
};
//DOTA LOGO 2
int leds[8][8] = {
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 1, 0, 0, 1, 1, 0},
{0, 1, 1, 1, 0, 0, 1, 0},
{0, 0, 1, 1, 1, 0, 0, 0},
{0, 0, 0, 1, 1, 1, 0, 0},
{0, 1, 0, 0, 1, 1, 1, 0},
{0, 1, 1, 0, 0, 1, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0}
};

//SMILEY
int leds[8][8] = {
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 1, 0, 0, 1, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 1, 1, 1, 1, 1, 1, 0},
{0, 1, 0, 0, 0, 0, 1, 0},
{0, 0, 1, 0, 0, 1, 0, 0},
{0, 0, 0, 1, 1, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0}
};


int leds[8][8] = {
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 1, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0},
{0, 0, 1, 1, 1, 0, 0, 0},
{0, 0, 0, 0, 0, 0, 0, 0}
};
*/

int snakex[64];
int snakey[64];
int snakelength = 3;
int snakedirection = 1;

int row[8] =     { 14, 15, 16, 17, 2, 3, 4, 5 };
int column[8] =  { 6, 7, 8, 9, 10, 11, 12, 13 };
int joystickX = 19;
int joystickY = 18;

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
  
  snakex[0]=1;
  snakey[0]=4;
  snakex[1]=1;
  snakey[1]=3;
  snakex[2]=1;
  snakey[2]=2;
}

void loop()
{
  for(int t=0; t<700;t++){
    for(int i=snakelength-1; i>=0; i--){
      digitalWrite(row[snakey[i]], HIGH);
      digitalWrite(column[snakex[i]], HIGH);
      delay(1);
      digitalWrite(row[snakey[i]], LOW);
      digitalWrite(column[snakex[i]], LOW);
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
      }
    }else{
      snakex[i] = snakex[i-1];
      snakey[i] = snakey[i-1];
    }
  }
  /*
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      if(leds[i][j]>0){
        digitalWrite(row[i], HIGH);
        digitalWrite(column[j], HIGH);
        delay(1);
      }
      
    digitalWrite(column[j], LOW);
    }
  digitalWrite(row[i], LOW);
  }*/
}

int getDirection(){
  if(analogRead(joystickX) > 800){
    return 0;
  }
  if(analogRead(joystickX) < 200){
    return 2;
  }
  if(analogRead(joystickY) > 800){
    return 1;
  }
  if(analogRead(joystickY) < 200){
    return 3;
  }
  return snakedirection;
}

