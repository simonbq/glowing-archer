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
*/
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



int row[8] =     { 14, 15, 16, 17, 2, 3, 4, 5 };
int column[8] =  { 6, 7, 8, 9, 10, 11, 12, 13 };

// Variables will change:
int ledState = HIGH;             // ledState used to set the LED

void setup() {
  // set the digital pin as output:
  for(int i=0;i<8;i++){
    pinMode(row[i], OUTPUT);
    pinMode(column[i], OUTPUT);
  }
  pinMode(18, INPUT);
  pinMode(19, INPUT);
}

void loop()
{
  
  for(int i=0;i<8;i++){
    for(int j=0;j<8;j++){
      if(leds[i][j]>0){
        digitalWrite(row[i], HIGH);
        digitalWrite(column[j], HIGH);
      }else{
        digitalWrite(row[i], LOW);
        digitalWrite(column[j], LOW);
      }
    digitalWrite(row[i], LOW);
    digitalWrite(column[j], LOW);
    }  
  }
}

