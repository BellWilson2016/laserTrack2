/* resetDev1.c
 *
 * A brief wrapper program to reset the DAC in event of a crash.
 *
 * Compile with: gcc resetDev1.c -o resetDev -lnidaqmx
 *
 */
#include "NIDAQmx.h"
#include <stdio.h>

int main(void) {

	int err;

	err = DAQmxResetDevice("Dev1");

	if (err == 0) {
		printf("--- Successfully Reset Dev1 ---\n");
	} else { 
		printf("--- Error in device reset: %d ---\n",err);
	}
	return err;
}
