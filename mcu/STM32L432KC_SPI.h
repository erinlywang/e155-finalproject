// STM32L432KC_SPI.h
// Caiya Coggshall
// ccoggshall@g.hmc.edu
// 10/16/25
// .h file for SPI.c, initializes functions and pins for chip select, clock, and MOSI, MISO

#ifndef STM32L4_SPI_H
#define STM32L4_SPI_H

#define SPI_CS PB1 //chip select/enable
#define SPI_SCK PB3
#define SPI_CIPO PB4 // MISO -> SDO
#define SPI_COPI PB5 // MOSI -> SDI


#include <stdint.h>
#include <stm32l432xx.h>

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

/* Enables the SPI peripheral and intializes its clock speed (baud rate), polarity, and phase.
 *    -- br: (0b000 - 0b111). The SPI clk will be the master clock / 2^(BR+1).
 *    -- cpol: clock polarity (0: inactive state is logical 0, 1: inactive state is logical 1).
 *    -- cpha: clock phase (0: data captured on leading edge of clk and changed on next edge, 
 *          1: data changed on leading edge of clk and captured on next edge)
 * Refer to the datasheet for more low-level details. */ 
void initSPI(int br, int cpol, int cpha);


/* Transmits a character (1 byte) over SPI and returns the received character.
 *    -- send: the character to send over SPI
 *    -- return: the character received over SPI */
char spiSendReceive(char send);

#endif