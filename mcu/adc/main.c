/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdio.h>
#include <stm32l432xx.h>
#include "main.h"

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/


int main(void) {
    // Configure flash to add waitstates to avoid timing errors
    configureFlash();

    // Setup the PLL and switch clock source to the PLL
    configureClock();

    
    gpioEnable(GPIO_PORT_A);
    gpioEnable(GPIO_PORT_B);

    // Enable PA0 as an Analog input pin for the ADC
    pinMode(0, GPIO_ANALOG);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD0, 0b10); // Set PA0 as pull-down

    // Enable PA8 as a GPIO input pin for the capsensor
    pinMode(8, GPIO_INPUT);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD8, 0b10);

    // Enable PA6 and PB3 as a GPIO output pin for an LED
    pinMode(6, GPIO_OUTPUT);
    GPIOA->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD6, 0b10);
    pinMode(19, GPIO_OUTPUT);
    GPIOB->PUPDR |= _VAL2FLD(GPIO_PUPDR_PUPD3, 0b10);

    // Enable 

    // Initialize timer
    enableAPB1_TIM2();
    initTIM(DELAY_TIM);

    // 1. Enable SYSCFG clock domain in RCC
    enableAPB2_SYSCFG();

    initADC();
    
    while(1) {
      int capvalue = digitalRead(8);
      digitalWrite(19, capvalue);
      int irvalue = handdetection();
      digitalWrite(6, irvalue);
      //printf("Touch = %d\n", irvalue);

    }
}

int handdetection(void){
    uint16_t value = readADC();

    if (value > HIGH_THRESHOLD)
        return 1;   // digital HIGH
    else
        return 0;   // digital LOW
}
/*************************** End of file ****************************/

//connect AREF to 3.3V
// connect to multimeter and then tap the input pin and if it changes the voltage reading then we need a buffer
