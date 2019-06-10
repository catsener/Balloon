/*  NTX2 Radio Test Part 2
 
    Transmits data via RTTY with a checksum.
 
    Created 2012 by M0UPU as part of a UKHAS Guide on linking NTX2 Modules to Arduino.
    RTTY code from Rob Harrison Icarus Project. 
    http://ukhas.org.uk
*/ 
#include <SD.h>//Load the SD library
#include <SPI.h>//Load the SPI library
#include <Adafruit_GPS.h> //install library
#include <SoftwareSerial.h>
#include <Wire.h>
#include <string.h>
#include <util/crc16.h>
#define RADIOPIN 9
 
SoftwareSerial mySerial(8,7);//initialize port
Adafruit_GPS GPS(&mySerial); //Create GPS object
char datastring[50];
String NMEA1; //Variable for first NMEA sentence
String NMEA2; //Variable for second NMEA sentence
char c; //read characters from GPS
int chipSelect = 10;//Select where our sd card is selected
File mySensorData;//Declare variable for your sd card object

char filename[15];
char filename1[15];

void setup() {                
  pinMode(RADIOPIN,OUTPUT);
 Serial.begin(115200); //turn on serial monitor  
delay(20);
 if(SD.exists("NMEA.TXT")){//Check existance of file and delete it
    SD.remove("NMEA.TXT");
  }
    if(SD.exists("GPSDATA.TXT")){//Check existance of file and delete it
    SD.remove("GPSDATA.TXT");
    }
  int error;
  uint8_t c;
GPS.begin(9600); //turn on GPS
//GPS.sendCommand("$PGCMD,33,0*6D"); //Turn off antenna update nuisance data
GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ); //Set update rate
GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA); //rEQUEST rmc AND gga sENTENCES ONLY
GPS.sendCommand(PGCMD_NOANTENNA);

pinMode(10,OUTPUT); //keep sd card reader happy
SD.begin(chipSelect);//Initialize SD card, connected to chipSelect

  /*strcpy(filename, "GPSLOG00.TXT");
  for (uint8_t i = 0; i < 100; i++) {
    filename[6] = '0' + i/10;
    filename[7] = '0' + i%10;
    // create if does not exist, do not open existing, write, sync after write
    if (! SD.exists(filename)) {
      break;
    }
  }
  strcpy(filename1, "NMEALG00.TXT");
  for (uint8_t i = 0; i < 100; i++) {
    filename1[6] = '0' + i/10;
    filename1[7] = '0' + i%10;
    // create if does not exist, do not open existing, write, sync after write
    if (! SD.exists(filename1)) {
      break;
    }
  }*/


}
 
void loop() {
 GPS.wakeup();
 GPS.begin(9600);
 readGPS();
 while ((GPS.fix==0) || (NMEA1[21]==',')){
  Serial.println("No Fix ");
  readGPS();
 }
  //readGPS();
  delay(20);
  //NMEA1[68]='0';
 Serial.println("Fixed");
 Serial.println(NMEA1);
 Serial.println(GPS.hour);
 Serial.println(GPS.minute);
 Serial.println(GPS.seconds);
  Serial.print(GPS.hour,DEC); Serial.print(GPS.minute,DEC);Serial.println(GPS.seconds,DEC);
 Serial.println(GPS.latitude,4);
 float latitud=GPS.latitude;
  Serial.println(latitud,4);
 Serial.println(GPS.longitude,4);
 Serial.println(GPS.altitude);
 Serial.println(GPS.lon);
 //if(GPS.fix==1){//only log data after you have a fix
  GPS.standby();
  mySensorData=SD.open("NMEA.TXT", FILE_WRITE);//open NMEA.txt for writing
  if (mySensorData) {
    //mySensorData.println("Fixed ok");
  mySensorData.println(NMEA1);//write first sentence
  mySensorData.println(NMEA2);//write second sentence
  mySensorData.close();//close the file
  }
  mySensorData=SD.open("GPSDATA.TXT", FILE_WRITE); //Open the GPSData.txt on SD card
  if (mySensorData) {
    //mySensorData.println("Fixed ok");
  mySensorData.print(GPS.latitude,4);//write latitude to gps file
  mySensorData.print(GPS.lat);//hemisphere N or S
  mySensorData.print(",");//write a comma
  mySensorData.print(GPS.longitude,4);//write longitude on gps file
  mySensorData.print(GPS.lon);//hemisphere E or W
  mySensorData.print(",");//write a comma
  mySensorData.println(GPS.altitude);//write altitude
  //mySensorData.println("Time = ");
  //mySensorData.print(time);
  mySensorData.close();//close file
  }
 delay(20);
 //if (counter==1){
   // counter=0;
   //frase = "";
   //frase = String(GPS.latitude) + " " + String(GPS.lat) + String(GPS.longitude) + " " + String(GPS.lon);
  // frase.toCharArray(datastring, 50);
 /*}
 else if (counter==0){
    counter=1;
    NMEA2.toCharArray(datastring,50);
 }*/
 
    int hora=GPS.hour;
  int minuto=GPS.minute;
  int segundo=GPS.seconds;
  float longitud=GPS.longitude; /// Cambiar signo con W! mirar codigo laboratorio clase para if command
  float altura=GPS.altitude;
  String buf;
  buf += F("$$MYPAYLOAD,");
  buf += String(hora);
  buf += String(minuto);
  buf += String(segundo);
  buf += F(",");
  buf += String(hora);
  buf += F(":");
  buf += String(minuto);
  buf += F(":");
  buf += String(segundo);
  buf += F(",");
  buf += String(latitud,4);
  buf += F(",");
  buf += String(longitud,4);
  buf += F(",");
  buf += String(altura,4);
  Serial.println(buf);
  buf.toCharArray(datastring,100);
  unsigned int CHECKSUM = gps_CRC16_checksum(datastring);  // Calculates the checksum for this datastring
  char checksum_str[6];
  sprintf(checksum_str, "*%04X\n", CHECKSUM);
  strcat(datastring,checksum_str);
 
  rtty_txstring (datastring);
  //if (GPS.fix==0) {
    NMEA1.toCharArray(datastring, 70);
  //}
 //printf(datastring);
 
  delay(2000);
 
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
 
  //                  delayMicroseconds(3370); // 500 baud
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

  /*Serial.println(NMEA1);
  Serial.println(NMEA2);
  Serial.println("");*/
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
