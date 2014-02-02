#include <stdio.h>

#define d0 4 
#define d1 5 
#define d2 6 
#define d3 7 
#define d4 8 
#define d5 9 
#define d6 10 
#define d7 11 
#define strobe 2 
#define ack 13 

int character = 0;

void setup()
{
  pinMode(d0, OUTPUT); 
  pinMode(d1, OUTPUT); 
  pinMode(d2, OUTPUT); 
  pinMode(d3, OUTPUT); 
  pinMode(d4, OUTPUT); 
  pinMode(d5, OUTPUT); 
  pinMode(d6, OUTPUT); 
  pinMode(d7, OUTPUT); 
  pinMode(strobe, INPUT); 
  pinMode(ack, OUTPUT);
  
  Serial.begin(115200);
  delay(1000);
  digitalWrite(ack, HIGH);
  //attachInterrupt(0, readUserPort, FALLING);
}

void loop()
{
  char c[]="hELLO, I LOVE YOU, WON'T YOU TELL ME YOUR NAME?\n";
  int i=0;
  
  while (i<(sizeof(c)/sizeof(char)))
  {
    if(c[i]=='\n')
      c[i]=13;
    //c=Serial.read();
    writeParallel(c[i]);
    
    i++;
    //delay(500);
  }
}

void writeParallel(char c)
{
  digitalWrite(d0, bitRead(c, 7));
  digitalWrite(d1, bitRead(c, 6));
  digitalWrite(d2, bitRead(c, 5));
  digitalWrite(d3, bitRead(c, 4));
  digitalWrite(d4, bitRead(c, 3));
  digitalWrite(d5, bitRead(c, 2));
  digitalWrite(d6, bitRead(c, 1));
  digitalWrite(d7, bitRead(c, 0));
    
  digitalWrite(ack, LOW);
  delayMicroseconds(2);
  digitalWrite(ack, HIGH);
  delay(35);
}

