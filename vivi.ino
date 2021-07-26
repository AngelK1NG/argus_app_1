 //#include <ESP8266Firebase.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ezTime.h>

//#define Project_ID "vivi11"
Timezone myLocalTime; 

const char* ssid = "boku no"; //SSID of wifi network
const char* password = "pico";// Password for wifi network
const int alarmHour= 19; // just while we don't have firebase or app to set it
const int alarmMinute= 7; // ^^^^^ (sets minute for alarm)
const int buzzerPin = 14; // pin of buzzer (D5 on NodeMCU)
const int buttonPin = 12; //D6

//Firebase milky(Project_ID);

void setup() {
  // put your setup code here, to run once:
 
 pinMode (buzzerPin, OUTPUT);
 pinMode (buttonPin, INPUT);
 
 Serial.begin(115200);
  // WiFi configuration

 
  WiFi.begin(ssid, password);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
Serial.println("connected");
  // Set desired time zone for Timezone object declared in the beginning
  myLocalTime.setLocation(F("America/Los_Angeles")); // set your time zone

  // Sync NTP time for ezTime library
  waitForSync(); 
Serial.println("synced");
  delay(2000);

//  milky.setInt("Hour", 4 ); // just while we get the app to write times into the database
//  milky.setInt("Minute", 32); //^^^^
}

void loop() {
  int currentHour = myLocalTime.hour();
  int currentMinute = myLocalTime.minute();
Serial.print(myLocalTime.hour());
Serial.print(":");
Serial.print(myLocalTime.minute());
Serial.println();

if (currentHour == alarmHour && currentMinute == alarmMinute) {
  int val= digitalRead(buttonPin);
 while(val != LOW){
  digitalWrite(buzzerPin, HIGH);
  delay(1000);
  digitalWrite(buzzerPin, LOW);
  val= digitalRead(buttonPin);
  if(val == LOW){
    break;
  }
 }
}
//if (currentHour == milky.getInt("Hour") && currentMinute == milky.getInt("Minute")) {
//  digitalWrite( buzzerPin, HIGH);
//  delay(2000);
//  digitalWrite(buzzerPin, LOW);
//}
delay(1000);
}
