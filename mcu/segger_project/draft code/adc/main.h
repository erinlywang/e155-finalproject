/**
    Main Header: Contains general defines and selected portions of CMSIS files
    @file main.h
    @author Josh Brake
    @version 1.0 10/7/2020
*/

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Custom defines
///////////////////////////////////////////////////////////////////////////////

#define LED_PIN PA6
#define BUTTON_PIN PA4
#define DELAY_TIM TIM2
#define HIGH_THRESHOLD 2400   // adjust to your needs
void configureInterrupt(int pin);

int handdetection(void);

#endif // MAIN_H
