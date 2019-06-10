#define RADIOPIN 9
 
#include <string.h>
#include <util/crc16.h>
 

char datastring[100];


void setup() {                
  pinMode(RADIOPIN,OUTPUT);
  Serial.begin(115200); //turn on serial monitor
}
 
void loop() {
//  int hora=GPS.hour;
//  int minuto=GPS.minute;
//  int segundo=GPS.seconds;
//  float latitud=GPS.latitude;
//  float longitud=GPS.longitude; /// Cambiar signo con W! mirar codigo laboratorio clase para if command
//  float altura=GPS.altitude;
//  String buf;
  int hora=10;
  int minuto=47;
  int segundo=9;
  float latitud=4019.9868;
  float longitud=345.4855;      
  float altura=715.70;
  String buf;
  buf += F("$$MYPAYLOAD,");
  buf += String(hora);           //Solucionar que sea menor de 10 para poner 0x
  buf += String(minuto);
  buf += String(segundo,2);
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
  char checksum_str[10];
  sprintf(checksum_str, "*%04X\n", CHECKSUM);
  strcat(datastring,checksum_str);
 
  rtty_txstring (datastring);
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
