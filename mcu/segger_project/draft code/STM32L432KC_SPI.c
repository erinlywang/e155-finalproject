//// STM32L432KC_SPI.c
//// Caiya Coggshall
//// ccoggshall@g.hmc.edu
//// 10/16/25
//// TODO: This file includes Serial Peripheral Interfacing functions to initialize and perform synchronous short-distance communication between "m*ster" and "sl*ve" devices in embedded systems

#include "STM32L432KC.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha) {
    // Turn on GPIOA and GPIOB clock domains (GPIOAEN and GPIOBEN bits in AHB1ENR)
    RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN);
    
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN; // Turn on SPI1 clock domain (SPI1EN bit in APB2ENR)

    // Initially assigning SPI pins
    pinMode(SPI_SCK, GPIO_ALT); // SPI1_SCK
    pinMode(SPI_CIPO, GPIO_ALT); // SPI1_MISO
    pinMode(SPI_COPI, GPIO_ALT); // SPI1_MOSI
    pinMode(SPI_CS, GPIO_OUTPUT); //  Manual CS

    // Set output speed type to high for SCK
    GPIOB->OSPEEDR |= (GPIO_OSPEEDR_OSPEED3);

    // Set to AF05 for SPI alternate functions
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5);
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5);
    GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5);
    
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_BR, br); // Set baud rate divider

    SPI1->CR1 |= (SPI_CR1_MSTR);
    SPI1->CR1 &= ~(SPI_CR1_CPOL | SPI_CR1_CPHA | SPI_CR1_LSBFIRST | SPI_CR1_SSM);
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha);
    SPI1->CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol);
    SPI1->CR2 |= _VAL2FLD(SPI_CR2_DS, 0b0111);
    SPI1->CR2 |= (SPI_CR2_FRXTH | SPI_CR2_SSOE);

    SPI1->CR1 |= (SPI_CR1_SPE); // Enable SPI
}

/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
//char spiSendReceive(char send) {
//    while(!(SPI1->SR & SPI_SR_TXE)); // Wait until the transmit buffer is empty
//    *(volatile char *) (&SPI1->DR) = send; // Transmit the character over SPI
//    while(!(SPI1->SR & SPI_SR_RXNE)); // Wait until data has been received
//    char rec = (volatile char) SPI1->DR;
//    return rec; // Return received character
//}


char spiSendReceive(char send) {
  // SPI1 -> CR1 &= ~ (0 << 10); // RXONLY full-duplex transmit and recieve enabled
  //SPI1 -> DR |= (send << 0); // putting the char in the data register to prepare to send

  // 1. wait until transmit buffer is empty
  while (!(SPI1->SR & SPI_SR_TXE));
  // 2. write to data reg (which i have) -> 
      // be careful to define data reg as volatile before writing to it, (it's alr volatile)
      // need to cast address of DR to be a volatile address, 
      // then dereference the volatile address to write to it (a couple stars) 
      // important: we are taking the DS pointer and casting it from a 16 bit to a 8 bit so that when we write the char it's a 8 bit int
  *(volatile char *) (&SPI1->DR) = send;
  // & is the address of operator so then we cast it to be a volatile address and then dereference (first *)
  // 3. wait until data is ready (receive flag so not empty) RXNE
  while (!(SPI1->SR & SPI_SR_RXNE));
  // 4. read data from data reg, return that
  char received = (volatile char) SPI1->DR ;
  return received;

}



////#include "STM32L432KC.h"
//#include "STM32L432KC_SPI.h"
//#include "STM32L432KC_GPIO.h"
////#include "STM32L432KC_RCC.h"

//void initSPI(int br, int cpol, int cpha) {

//  // Turn on GPIOA and GPIOB clock domains (GPIOAEN and GPIOBEN bits in AHB1ENR)
//  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN);

//  // Turn on RCC clock for SPI
//  RCC -> APB2ENR |= RCC_APB2ENR_SPI1EN; 

//  // Set output speed to be fast
//  GPIOB ->OSPEEDR |= GPIO_OSPEEDR_OSPEED3;

//  // Connect Alt Func to Pin
//  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL3, 5); // AFSEL3 -> 5 
//  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL4, 5); // AFSEL 4 -> 5
//  GPIOB->AFR[0] |= _VAL2FLD(GPIO_AFRL_AFSEL5, 5); // AFSEL 5 -> 5

//  // Set ALT GPIO pins
//  pinMode(SPI_CS, GPIO_OUTPUT); // set this high and low, dont need alt
//  pinMode(SPI_SCK, GPIO_ALT);
//  pinMode(SPI_CIPO, GPIO_ALT);
//  pinMode(SPI_COPI, GPIO_ALT);

//  // Set M*ster Microcontroller Selection
//  SPI1->CR1 |= (SPI_CR1_MSTR);

//  //// Set BR, CPOL, CPHA
//  SPI1 -> CR1 |= _VAL2FLD(SPI_CR1_BR, br);  //(br << 3); // bits [5:3] is baud rate
//  SPI1 -> CR1 &= ~(1 << 1); // clear cpol
//  SPI1 -> CR1 |= _VAL2FLD(SPI_CR1_CPOL, cpol); // (cpol << 1); // bit [1] is clock polarity
//  SPI1 -> CR1 &= ~(1 << 0); // clear cpha
//  SPI1 -> CR1 |= _VAL2FLD(SPI_CR1_CPHA, cpha); //(cpha << 0); // bit [0] is clock phase

//  // Set data size to 8 bit
//  SPI1-> CR2 |= _VAL2FLD(SPI_CR2_DS, 0b0111);

//  // Set FRXTH bit
//  SPI1 -> CR2 |= _VAL2FLD(SPI_CR2_FRXTH, 1); // send receive and sensor is 8 bit so set to be 8 bit mode
  
//  // Finally enable
//  SPI1 -> CR1 |= SPI_CR1_SPE; // enable SPI
//}



//char spiSendReceive(char send) {
//  // SPI1 -> CR1 &= ~ (0 << 10); // RXONLY full-duplex transmit and recieve enabled
//  //SPI1 -> DR |= (send << 0); // putting the char in the data register to prepare to send

//  // 1. wait until transmit buffer is empty
//  while (!(SPI1->SR & SPI_SR_TXE));
//  // 2. write to data reg (which i have) -> 
//      // be careful to define data reg as volatile before writing to it, (it's alr volatile)
//      // need to cast address of DR to be a volatile address, 
//      // then dereference the volatile address to write to it (a couple stars) 
//      // important: we are taking the DS pointer and casting it from a 16 bit to a 8 bit so that when we write the char it's a 8 bit int
//  *(volatile char *) (&SPI1->DR) = send;
//  // & is the address of operator so then we cast it to be a volatile address and then dereference (first *)
//  // 3. wait until data is ready (receive flag so not empty) RXNE
//  while (!(SPI1->SR & SPI_SR_RXNE));
//  // 4. read data from data reg, return that
//  char received = (volatile char) SPI1->DR ;
//  return received;

//}
