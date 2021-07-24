#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ezTime.h>

Timezone myLocalTime; 

const char* ssid = "boku no"; //SSID of wifi network
const char* password = "pico";// Password for wifi network
const int alarmHour= 6; // just while we don't have firebase or app to set it
const int alarmMinute= 9; // ^^^^^ (sets minute for alarm)
const int buzzerPin = 0; // pin of buzzer (D3 on NodeMCU)




void setup() {
  // put your setup code here, to run once:
 
 pinMode (buzzerPin, OUTPUT);
 
 Serial.begin(115200);
  // WiFi configuration

 
  WiFi.begin(ssid, password);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  // Set desired time zone for Timezone object declared in the beginning
  myLocalTime.setLocation(F("America/Los_Angeles")); // set your time zone

  // Sync NTP time for ezTime library
  waitForSync(); 

  delay(2000);
}

void loop() {
  int currentHour = myLocalTime.hour();
  int currentMinute = myLocalTime.minute();
Serial.println(myLocalTime.minute());
if (currentHour == alarmHour && currentMinute == alarmMinute) {
  digitalWrite( buzzerPin, HIGH);
  delay(2000);
  digitalWrite( buzzerPin, LOW);
}
delay(1000);
}
