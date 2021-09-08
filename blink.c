#include <wiringPi.h>

const int ledpin=21;

int main(void){
	wiringPiSetupGpio();
	pinMode(ledpin, OUTPUT);
	
	while(1){
	digitalWrite(ledpin, HIGH);
	delay(500);
	digitalWrite(ledpin, LOW);
	delay(500);
	}
}
