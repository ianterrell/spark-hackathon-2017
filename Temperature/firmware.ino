
// This #include statement was automatically added by the Particle IDE.
#include "OneWire/OneWire.h"

// This #include statement was automatically added by the Particle IDE.
#include "spark-dallas-temperature/spark-dallas-temperature.h"

DallasTemperature dallas(new OneWire(D3));

double temperature = 0;

void setup(){
    Serial.begin(9600);
    dallas.begin();

    Particle.variable("temperature", temperature);
}

void loop(){
    dallas.requestTemperatures();
    float reading = dallas.getTempCByIndex(0);

    // error value observed is -127; range is only to -55 C
    if (reading > -55) {
      temperature = reading;
      Serial.print("Temperature: "); Serial.println(temperature);
    } else {
      Serial.print("Error reading");
    }

    delay(1000);
}
