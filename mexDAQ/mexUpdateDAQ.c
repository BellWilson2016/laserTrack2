/* mexUpdateDAQ.c
 *
 */

#include "mex.h"
#include "NIDAQmx.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	TaskHandle taskH    = (TaskHandle) mxGetScalar(prhs[0]);
	int32 sampsPerChan  = mxGetScalar(prhs[1]);
	bool32 autoStart    = mxGetScalar(prhs[2]);
	float64 timeOut     = mxGetScalar(prhs[3]);
	bool32 dataLayout   = mxGetScalar(prhs[4]);
	float64 *writeArray = (float64 *) prhs[5];
	int32 *sampsWritten = (int32 *) prhs[6];
	int32 err;
	int32 *nullPointer = 0;

	err = DAQmxWriteAnalogF64(taskH, sampsPerChan, autoStart, timeOut, dataLayout, writeArray, sampsWritten,nullPointer);

	mexPrintf("Error out: %d\n",err);

	return;
}

