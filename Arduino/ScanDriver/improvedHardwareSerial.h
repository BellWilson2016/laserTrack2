/*
  HardwareSerial.h - Hardware serial library for Wiring
  Copyright (c) 2006 Nicholas Zambetti.  All right reserved.

  Modified 28 September 2010 by Mark Sproul
  
  Modified 12/11/2012 by Joe Bell
    -Nb. #ifndef's will keep old HardwareSerial_h from loading in arduino.h
*/

#ifndef HardwareSerial_h
#define HardwareSerial_h

#include <inttypes.h>

#include "Stream.h"

struct ring_buffer;

class improvedHardwareSerial : public Stream
{
  private:
    ring_buffer *_rx_buffer;
    ring_buffer *_tx_buffer;
    volatile uint8_t *_ubrrh;
    volatile uint8_t *_ubrrl;
    volatile uint8_t *_ucsra;
    volatile uint8_t *_ucsrb;
    volatile uint8_t *_udr;
    uint8_t _rxen;
    uint8_t _txen;
    uint8_t _rxcie;
    uint8_t _udrie;
    uint8_t _u2x;
  public:
    improvedHardwareSerial(ring_buffer *rx_buffer, ring_buffer *tx_buffer,
      volatile uint8_t *ubrrh, volatile uint8_t *ubrrl,
      volatile uint8_t *ucsra, volatile uint8_t *ucsrb,
      volatile uint8_t *udr,
      uint8_t rxen, uint8_t txen, uint8_t rxcie, uint8_t udrie, uint8_t u2x);
    void begin(unsigned long);
    void end();
    int txBufferSpace(); 
    virtual int available(void);
    virtual int peek(void);
    virtual int read(void);
    virtual void flush(void);
    virtual size_t write(uint8_t);
    using Print::write; // pull in write(str) and write(buf, size) from Print
    operator bool();
};

#if defined(UBRRH) || defined(UBRR0H)
  extern improvedHardwareSerial Serial;
#elif defined(USBCON)
  #include "USBAPI.h"
//  extern HardwareSerial Serial_;  
#endif
#if defined(UBRR1H)
  extern improvedHardwareSerial Serial1;
#endif
#if defined(UBRR2H)
  extern improvedHardwareSerial Serial2;
#endif
#if defined(UBRR3H)
  extern improvedHardwareSerial Serial3;
#endif

extern void serialEventRun(void) __attribute__((weak));

#endif

