/**
    Main Header: Contains general defines and selected portions of CMSIS files
    @file main.c
    @author Caiya Coggshall & Erin Wang
    @version 1.0 11/19/2025
    @summary DFPlayer Mini + STM32L432KC over USART1
    Full Datasheet for the DFP Player can be found here: https://picaxe.com/docs/spe033.pdf
*/


#include <stdint.h>
#include "main.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_FLASH.h"
#include "STM32L432KC_USART.h"
#include "STM32L432KC_GPIO.h"


// assuming ~80 MHz system clock after configureClock().
static void delay_ms(uint32_t ms) {
    for (uint32_t i = 0; i < ms; i++) {
        for (volatile uint32_t j = 0; j < 10000; j++) {
            __NOP(); // no operation
        }
    }
}

// From datasheet:
// 0x7E 0xFF 0x06 CMD FEEDBACK PARA_H PARA_L CHK_H CHK_L 0xEF

static USART_TypeDef *dfp_usart = NULL;
static USART_TypeDef *dbg_usart = NULL;  // USART2 over ST-LINK VCP (optional debug)

// Send raw bytes to DFPlayer
static void DFP_SendRaw(const uint8_t *buf, uint8_t len) {
    for (uint8_t i = 0; i < len; i++) {
        sendChar(dfp_usart, (char)buf[i]);
    }
}

// Build and send a standard 10-byte DFPlayer frame
static void DFP_SendCommand(uint8_t cmd, uint16_t param) {
    uint8_t  frame[10];
    uint16_t sum = 0;
    uint16_t checksum; // 16 bits but frame in bytes

    frame[0] = 0x7E;                 // Start byte
    frame[1] = 0xFF;                 // Version
    frame[2] = 0x06;                 // Length
    frame[3] = cmd;                  // Command
    frame[4] = 0x00;                 // Feedback (0 = no reply, 1 = reply)
    frame[5] = (param >> 8) & 0xFF;  // Parameter high byte shift and then only keep low 8 bits
    frame[6] = param & 0xFF;         // Parameter low byte keep low 8 bits

    // Checksum = 0 - (VER + Len + CMD + Feedback + para1 + para2)
    for (int i = 1; i <= 6; i++) {
        sum += frame[i];
    }
    checksum = (uint16_t)(0 - sum);

    frame[7] = (checksum >> 8) & 0xFF;
    frame[8] = checksum & 0xFF;
    frame[9] = 0xEF;                 // End byte

    DFP_SendRaw(frame, sizeof(frame));
}

// Convenience wrappers around DFP_SendCommand(), using commands from datasheet:
// 0x09 = specify playback source; 0x06 = volume; 0x03 = track; 0x0F = folder+file; etc. :contentReference[oaicite:1]{index=1}

// Select TF (microSD) as playback device (0x09, param = 0x0002)
static void DFP_SelectTFCard(void) {
    DFP_SendCommand(0x09, 0x0002);
}

// Set volume 0..30 (0x06)
static void DFP_SetVolume(uint8_t volume) {
    if (volume > 30) {
        volume = 30;
    }
    DFP_SendCommand(0x06, volume);
}

// // play by global track number 0..2999 on current device (0x03)
static void DFP_PlayTrack(uint16_t track) {
    if (track > 2999) {
        track = 2999;
    }
    DFP_SendCommand(0x03, track);
}

// Play /<folder>/<file>.mp3, where folder = 1..99, file = 1..255, per datasheet’s folder scheme (e.g. /01/001.mp3). :contentReference[oaicite:2]{index=2}
static void DFP_PlayFolderTrack(uint8_t folder, uint8_t file) {
    uint16_t param = ((uint16_t)folder << 8) | file;
    DFP_SendCommand(0x0F, param);
}

// // start / resume playback of current track (0x0D)
static void DFP_Play(void) {
    DFP_SendCommand(0x0D, 0x0000);
}

// // Pause playback (0x0E)
static void DFP_Pause(void) {
    DFP_SendCommand(0x0E, 0x0000);
}



// Actual Main call
int main(void) {
    // Flash wait states + prefetch, sys clock to 80 MHz
    configureFlash();
    configureClock();

    // initialize UARTs
    // USART1: DFPlayer @ 9600 baud (PA9 = TX -> DFPlayer RX, PA10 = RX <- DFPlayer TX)
    dfp_usart = initUSART(USART1_ID, 9600); // chooses PA9 and PA10 here

    // setting volume
    sendString(dbg_usart, "Setting volume\r\n");
    DFP_SetVolume(20); // 0 to 30

    // USART2: debug console over ST-LINK VCP @ 115200 baud (opt baud)
    // send strings all on USART2 so it doesn't interfere with DFP pin send on USART1
    dbg_usart = initUSART(USART2_ID, 115200);
    sendString(dbg_usart, "Booting DFPlayer demo\r\n");

    // wait for DFPlayer + TF card to finish power-on init.
    //    Datasheet says ~1.5–3 s depending on number of file ??
    delay_ms(2500);

    // select TF card as playback device
    sendString(dbg_usart, "Selecting TF card\r\n");
    DFP_SelectTFCard();

    // datasheet says wait ~200 ms after selecting device before issuing track commands for model to initialize file info
    delay_ms(250);


    // Playback
    // play by global track number
    // DFP_PlayTrack(1);      // play track 1

    // organizing files as /01/001.mp3 on TF card
    sendString(dbg_usart, "Playing Test Drive\r\n");
    DFP_PlayFolderTrack(1, 1);  // folder "01", file "001.mp3" datasheet has format written

    delay_ms(1000);

    //if (servomotor trigger the digitalRead() == 1??) {
    sendString(dbg_usart, "Playing ROAR\r\n");
    DFP_PlayFolderTrack(1, 2); 
    //}


    //// main loop for later idle.
    //while (1) {
    //    // read buttons, send DFP_PlayTrack(), DFP_Pause(), etc. to connect w big model
    //}
}







// NO SPI
////initSPI(0b101, 0, 0); 
////digitalWrite(SPI_CS, 1); // it's high when transmitting
////spiSendReceive(0x7E); // START command
////spiSendReceive(0xFF); // Version info
////spiSendReceive(0x06); // data length not including parity
////spiSendReceive(0x03); // representative No
////spiSendReceive(0x00); // 00 dont need to return
////spiSendReceive(0x00); // track high byte [DH]
////spiSendReceive(0x01); // track low byte [DL]
////spiSendReceive(0xFF); // checksum high byte for song 1
////spiSendReceive(0xE6); // checksum low byte for song 1
////spiSendReceive(0xEF); // END command
////digitalWrite(SPI_CS, 0); // and then it turns off after done
