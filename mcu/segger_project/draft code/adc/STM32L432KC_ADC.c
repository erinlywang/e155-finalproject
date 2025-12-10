// STM32L432KC_ADC.c
// Source code for ADC functions

#include "STM32L432KC_ADC.h"
#include "STM32L432KC.h"

#include "stm32l432xx.h"

#define CHANNEL_NUMBER 5


// -----------------------------------------------------------------------------
// Initialize ADC1 for single-channel software-triggered conversions.
// ADC channel number (5 for PA0)
// -----------------------------------------------------------------------------
void initADC()
{
    //Enable ADC Clock and set to system clock
    RCC->AHB2ENR |= RCC_AHB2ENR_ADCEN;
    RCC->CCIPR |= _VAL2FLD(RCC_CCIPR_ADCSEL, 0b11);


    // Select ADC clock to be HCLK/4 and prescaler to not divide
    ADC1_COMMON->CCR &= ~ADC_CCR_CKMODE_Msk;
    ADC1_COMMON->CCR |= _VAL2FLD(ADC_CCR_CKMODE, 0b11);
    ADC1_COMMON->CCR &= ~ADC_CCR_PRESC_Msk;

    // Turn off Deep Power-Down Mode and then enable the voltage regulator
    ADC1->CR &= ~ADC_CR_DEEPPWD;
    ADC1->CR |= ADC_CR_ADVREGEN;           // Enable regulator
    for (volatile int i = 0; i < 1000; i++) {
        __ASM("nop");
    } // Delay >= 20us as per datasheet

    // Calibrate the ADC
    ADC1->CR |= ADC_CR_ADCAL;
    while (ADC1->CR & ADC_CR_ADCAL);       // Wait finish

    // Configure ADC: single, right-aligned, 12-bit
    ADC1->CFGR = 0;               // Default OK

    // Enable ADC
    ADC1->ISR |= ADC_ISR_ADRDY;            // Clear ADRDY
    ADC1->CR |= ADC_CR_ADEN;               // Enable ADC
    while (!(ADC1->ISR & ADC_ISR_ADRDY));  // Wait ready

    // Configure sequence: 1 conversion, channel in SQ1
    ADC1->SQR1 = 0;
    ADC1->SQR1 |= _VAL2FLD(ADC_SQR1_SQ1, CHANNEL_NUMBER);
    
    ADC1->ISR |= ADC_ISR_ADRDY;            // Clear ADRDY

}

// -----------------------------------------------------------------------------
// Trigger one ADC conversion and return the 12-bit result.
// -----------------------------------------------------------------------------
uint16_t readADC(void) {
    
    ADC1->CR |= ADC_CR_ADSTART;   
    
    while (!(ADC1->ISR & ADC_ISR_EOC));    // Wait for next conversion done

    return (uint16_t)ADC1->DR;             // Read (clears EOC)
}
