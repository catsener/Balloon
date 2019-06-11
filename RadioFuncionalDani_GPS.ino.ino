#define RADIOPIN 9

#include <SD.h>//Load the SD library
#include <SPI.h>//Load the SPI library
#include <Adafruit_GPS.h> //install library
#include <SoftwareSerial.h>
#include <Wire.h>
#include <string.h>
#include <util/crc16.h>
 
SoftwareSerial mySerial(8,7);//initialize port
Adafruit_GPS GPS(&mySerial); //Create GPS object
char datastring[100];
String NMEA1; //Variable for first NMEA sentence
String NMEA2; //Variable for second NMEA sentence
char c; //read characters from GPS

void setup() {                
  pinMode(RADIOPIN,OUTPUT);
  Serial.begin(115200); //turn on serial monitor
  delay(20);

  uint8_t c;
  GPS.begin(9600); //turn on GPS
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ); //Set update rate
  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA); //rEQUEST rmc AND gga sENTENCES ONLY
  GPS.sendCommand(PGCMD_NOANTENNA);
}
 
void loop() {
  GPS.wakeup();
  GPS.begin(9600);
  readGPS();
   while ((GPS.fix==0) || (NMEA1[21]==',')){
  Serial.println("No Fix ");
  readGPS();
 }
  Serial.println("Fixed");
  int hora=GPS.hour;
  int minuto=GPS.minute;
  int segundo=GPS.seconds;
  float latitud=GPS.latitude;
  char NS=GPS.lat;
  float longitud=GPS.longitude; 
  char EW=GPS.lon;
  float altura=GPS.altitude;
  GPS.standby();
  String buf;
//  int hora=10;
//  int minuto=49;
//  int segundo=30;
//  float latitud=4020.9868;
//  char NS='N';
//  float longitud=360.4855;  
//  char EW='W';    
//  float altura=715.70;
//  String buf;
  buf += F("$$Ball12,");
  if (hora < 10)    
  {
    buf +=F("0");
    buf += String(hora); 
  }  
  else
  {
    buf += String(hora);
  }
    if (minuto < 10)    
  {
    buf +=F("0");
    buf += String(minuto); 
  }  
  else
  {
    buf += String(minuto);
  }
    if (segundo < 10)    
  {
    buf +=F("0");
    buf += String(segundo); 
  }  
  else
  {
    buf += String(segundo);
  }
  buf += F(",");
  if (hora < 10)    
  {
    buf +=F("0");
    buf += String(hora); 
  }  
  else
  {
    buf += String(hora);
  }
  buf += F(":");
  if (minuto < 10)    
  {
    buf +=F("0");
    buf += String(minuto); 
  }  
  else
  {
    buf += String(minuto);
  }
  buf += F(":");
  if (segundo < 10)    
  {
    buf +=F("0");
    buf += String(segundo); 
  }  
  else
  {
    buf += String(segundo);
  }
  buf += F(",");
  if (NS == 'S')
  {
  buf +=F("-");
  buf += String(latitud,4);
  }
  else
  {
  buf += String(latitud,4);
  }
  buf += F(",");
  if (EW == 'W')
  {
  buf +=F("-");
  buf += String(longitud,4);
  }
  else
  {
  buf += String(longitud,4);
  }
  buf += F(",");
  buf += String(altura,4);
  Serial.println(buf);
  buf.toCharArray(datastring,100);
  unsigned int CHECKSUM = gps_CRC16_checksum(datastring);  // Calculates the checksum for this datastring
  char checksum_str[10];
  sprintf(checksum_str, "*%04X\n", CHECKSUM);
  strcat(datastring,checksum_str);
 
  rtty_txstring (datastring);
}
 
 
void rtty_txstring (char * string)
{
 
  /* Simple function to sent a char at a time to 
     ** rtty_txbyte function. 
    ** NB Each char is one byte (8 Bits)
    */
 
  char c;
 
  c = *string++;
 
  while ( c != '\0')
  {
    rtty_txbyte (c);
    c = *string++;
  }
}
 
 
void rtty_txbyte (char c)
{
  /* Simple function to sent each bit of a char to 
    ** rtty_txbit function. 
    ** NB The bits are sent Least Significant Bit first
    **
    ** All chars should be preceded with a 0 and 
    ** proceded with a 1. 0 = Start bit; 1 = Stop bit
    **
    */
 
  int i;
 
  rtty_txbit (0); // Start bit
 
  // Send bits for for char LSB first 
 
  for (i=0;i<7;i++) // Change this here 7 or 8 for ASCII-7 / ASCII-8
  {
    if (c & 1) rtty_txbit(1); 
 
    else rtty_txbit(0); 
 
    c = c >> 1;
 
  }
 
  rtty_txbit (1); // Stop bit
  rtty_txbit (1); // Stop bit
}
 
void rtty_txbit (int bit)
{
  if (bit)
  {
    // high
    digitalWrite(RADIOPIN, HIGH);
  }
  else
  {
    // low
    digitalWrite(RADIOPIN, LOW);
 
  }
 
  //                  delayMicroseconds(3370); // 300 baud
  delayMicroseconds(10000); // For 50 Baud uncomment this and the line below. 
  delayMicroseconds(10150); // You can't do 20150 it just doesn't work as the
                            // largest value that will produce an accurate delay is 16383
                            // See : http://arduino.cc/en/Reference/DelayMicroseconds
 
}
 
uint16_t gps_CRC16_checksum (char *string)
{
  size_t i;
  uint16_t crc;
  uint8_t c;
 
  crc = 0xFFFF;
 
  // Calculate checksum ignoring the first two $s
  for (i = 2; i < strlen(string); i++)
  {
    c = string[i];
    crc = _crc_xmodem_update (crc, c);
  }
 
  return crc;
}    

void readGPS(){
clearGPS();
while(!GPS.newNMEAreceived()){  //Loop until NMEA sentence
  c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA());//Parse that NMEA sentence
  NMEA1=GPS.lastNMEA();
while(!GPS.newNMEAreceived()){  //Loop until NMEA sentence
  c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA());//Parse that NMEA sentence
  NMEA2=GPS.lastNMEA();

}
void clearGPS(){  //clear old and corrupt data from serial port
  while(!GPS.newNMEAreceived()){  //Loop until NMEA sentence
  c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA());//Parse that NMEA sentence
  while(!GPS.newNMEAreceived()){  //Loop until NMEA sentence
  c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA());//Parse that NMEA sentence
  
}
