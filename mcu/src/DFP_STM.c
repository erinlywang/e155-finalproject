// DFP_STM.c
// Mini Music Module Functions

#include <stdint.h>
#include <stddef.h>
#include "main.h"
#include "DFP_STM.h"

// From datasheet:
// 0x7E 0xFF 0x06 CMD FEEDBACK PARA_H PARA_L CHK_H CHK_L 0xEF

USART_TypeDef *dfp_usart = NULL;
USART_TypeDef *dbg_usart = NULL;  // USART2 over ST-LINK VCP (optional debug)

// Send raw bytes to DFPlayer
void DFP_SendRaw(const uint8_t *buf, uint8_t len) {
    for (uint8_t i = 0; i < len; i++) {
        sendChar(dfp_usart, (char)buf[i]);
    }
}

// Build and send a standard 10-byte DFPlayer frame
void DFP_SendCommand(uint8_t cmd, uint16_t param) {
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
void DFP_SelectTFCard(void) {
    DFP_SendCommand(0x09, 0x0002);
}

// Set volume 0..30 (0x06)
void DFP_SetVolume(uint8_t volume) {
    if (volume > 30) {
        volume = 30;
    }
    DFP_SendCommand(0x06, volume);
}

// // play by global track number 0..2999 on current device (0x03)
void DFP_PlayTrack(uint16_t track) {
    if (track > 2999) {
        track = 2999;
    }
    DFP_SendCommand(0x03, track);
}

// Play /<folder>/<file>.mp3, where folder = 1..99, file = 1..255, per datasheet’s folder scheme (e.g. /01/001.mp3). :contentReference[oaicite:2]{index=2}
void DFP_PlayFolderTrack(uint8_t folder, uint8_t file) {
    uint16_t param = ((uint16_t)folder << 8) | file;
    DFP_SendCommand(0x0F, param);
}

// // start / resume playback of current track (0x0D)
void DFP_Play(void) {
    DFP_SendCommand(0x0D, 0x0000);
}

// // Pause playback (0x0E)
void DFP_Pause(void) {
    DFP_SendCommand(0x0E, 0x0000);
}
