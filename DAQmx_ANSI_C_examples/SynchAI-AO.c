/*********************************************************************
*
* ANSI C Example program:
*    SynchAI-AO.c
*
* Example Category:
*    Sync
*
* Description:
*    This example demonstrates how to continuously acquire and
*    generate data at the same time, synchronized with one another.
*
* Instructions for Running:
*    1. Select the physical channel to correspond to where your
*       signal is input on the DAQ device. Also, select the
*       corresponding channel for where your signal is being
*       generated.
*    2. Enter the minimum and maximum voltage ranges.
*    Note: For better accuracy try to match the input range to the
*          expected voltage level of the measured signal.
*    3. Set the sample rate of the acquisition.
*    Note: The rate should be at least twice as fast as the maximum
*          frequency component of the signal being acquired.
*    4. Select the rate for the generation.
*    5. Select what type of signal to generate and the amplitude.
*    Note: This example requires two DMA channels to run. If your
*          hardware does not support two DMA channels, you need to
*          set the Data Transfer Mechanism attribute for the Analog
*          Output Task to use "Interrupts".
*
*    Refer to your device documentation to determine how many DMA
*    channels are supported for your hardware.
*
* Steps:
*    1. Create a task.
*    2. Create an analog input voltage channel. Also, create a analog
*       output channel.
*    3. Set the rate for the sample clocks. Additionally, define the
*       sample modes to be continuous. Also, set the sample clock
*       rate for the signal generation.
*    3a. Call the GetTerminalNameWithDevPrefix function. This will
*    take a task and a terminal and create a properly formatted
*    device + terminal name to use as the source of the digital
*    sample clock.
*    4. Define the parameters for a digital edge start trigger. Set
*       the analog output to trigger off the AI start trigger. This
*       is an internal trigger signal.
*    5. Synthesize a standard waveform (sine, square, or triangle)
*       and load this data into the output RAM buffer.
*    6. Call the start function to arm the two tasks. Make sure the
*       analog output is armed before the analog input. This will
*       ensure both will start at the same time.
*    7. Read the waveform data continuously until the user hits the
*       stop button or an error occurs.
*    8. Call the Stop function to stop the acquisition.
*    9. Call the Clear Task function to clear the task.
*    10. Display an error if any.
*
* I/O Connections Overview:
*    Make sure your signal input terminals match the Physical Channel
*    I/O controls.
*
*********************************************************************/

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <NIDAQmx.h>

static TaskHandle  AItaskHandle=0,AOtaskHandle=0;


#define PI	3.1415926535

#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

int GenSineWave(int numElements, double amplitude, double frequency, double *phase, double sineWave[]);

static int32 GetTerminalNameWithDevPrefix(TaskHandle taskHandle, const char terminalName[], char triggerName[]);

int32 CVICALLBACK EveryNCallback(TaskHandle taskHandle, int32 everyNsamplesEventType, uInt32 nSamples, void *callbackData);
int32 CVICALLBACK DoneCallback(TaskHandle taskHandle, int32 status, void *callbackData);

int main(void)
{
	int32   error=0;
	char    errBuff[2048]={'\0'};
	char    trigName[256];
	float64	AOdata[1000];
	float64	phase=0.0;

	/*********************************************/
	// DAQmx Configure Code
	/*********************************************/

	// Configure the analog input task
	DAQmxErrChk (DAQmxCreateTask("",&AItaskHandle));
	DAQmxErrChk (DAQmxCreateAIVoltageChan(AItaskHandle,"Dev1/ai0","",DAQmx_Val_Cfg_Default,-10.0,10.0,DAQmx_Val_Volts,NULL));
	DAQmxErrChk (DAQmxCfgSampClkTiming(AItaskHandle,"",10000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,1000));
	DAQmxErrChk (GetTerminalNameWithDevPrefix(AItaskHandle,"ai/StartTrigger",trigName));

	// Configure the analog output task
	DAQmxErrChk (DAQmxCreateTask("",&AOtaskHandle));
	DAQmxErrChk (DAQmxCreateAOVoltageChan(AOtaskHandle,"Dev1/ao0","",-10.0,10.0,DAQmx_Val_Volts,NULL));
	DAQmxErrChk (DAQmxCfgSampClkTiming(AOtaskHandle,"",5000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,1000));

	// Define parameters for the start trigger
	DAQmxErrChk (DAQmxCfgDigEdgeStartTrig(AOtaskHandle,trigName,DAQmx_Val_Rising));

	// Set up the callback functions
	DAQmxErrChk (DAQmxRegisterEveryNSamplesEvent(AItaskHandle,DAQmx_Val_Acquired_Into_Buffer,1000,0,EveryNCallback,NULL));
	DAQmxErrChk (DAQmxRegisterDoneEvent(AItaskHandle,0,DoneCallback,NULL));

	GenSineWave(1000,1.0,1.0/1000,&phase,AOdata);

	DAQmxErrChk (DAQmxWriteAnalogF64(AOtaskHandle, 1000, FALSE, 10.0, DAQmx_Val_GroupByChannel, AOdata, NULL, NULL));

	/*********************************************/
	// DAQmx Start Code
	/*********************************************/
	DAQmxErrChk (DAQmxStartTask(AOtaskHandle)); // Must be started first
	DAQmxErrChk (DAQmxStartTask(AItaskHandle));

	printf("Acquiring samples continuously. Press Enter to interrupt\n");
	printf("\nRead:\tAI\tTotal:\tAI\n");
	getchar();

Error:
	if( DAQmxFailed(error) )
		DAQmxGetExtendedErrorInfo(errBuff,2048);
	if( AItaskHandle ) {
		/*********************************************/
		// DAQmx Stop Code
		/*********************************************/
		DAQmxStopTask(AItaskHandle);
		DAQmxClearTask(AItaskHandle);
		AItaskHandle = 0;
	}
	if( AOtaskHandle ) {
		/*********************************************/
		// DAQmx Stop Code
		/*********************************************/
		DAQmxStopTask(AOtaskHandle);
		DAQmxClearTask(AOtaskHandle);
		AOtaskHandle = 0;
	}
	if( DAQmxFailed(error) )
		printf("DAQmx Error: %s\n",errBuff);
	printf("End of program, press Enter key to quit\n");
	getchar();
	return 0;
}

int32 CVICALLBACK EveryNCallback(TaskHandle taskHandle, int32 everyNsamplesEventType, uInt32 nSamples, void *callbackData)
{
	int32       error=0;
	char        errBuff[2048]={'\0'};
	static int  totalAI=0;
	int32       readAI;
	float64     AIdata[1000];

	/*********************************************/
	// DAQmx Read Code
	/*********************************************/
	DAQmxErrChk (DAQmxReadAnalogF64(AItaskHandle,1000,10.0,DAQmx_Val_GroupByChannel,AIdata,1000,&readAI,NULL));

	printf("\t%d\t\t%d\r",(int)readAI,(int)(totalAI+=readAI));
	fflush(stdout);

Error:
	if( DAQmxFailed(error) ) {
		DAQmxGetExtendedErrorInfo(errBuff,2048);
		/*********************************************/
		// DAQmx Stop Code
		/*********************************************/
		if( AItaskHandle ) {
			DAQmxStopTask(AItaskHandle);
			DAQmxClearTask(AItaskHandle);
			AItaskHandle = 0;
		}
		if( AOtaskHandle ) {
			DAQmxStopTask(AOtaskHandle);
			DAQmxClearTask(AOtaskHandle);
			AOtaskHandle = 0;
		}
		printf("DAQmx Error: %s\n",errBuff);
	}
	return 0;
}

int32 CVICALLBACK DoneCallback(TaskHandle taskHandle, int32 status, void *callbackData)
{
	int32   error=0;
	char    errBuff[2048]={'\0'};

	// Check to see if an error stopped the task.
	DAQmxErrChk (status);

Error:
	if( DAQmxFailed(error) ) {
		DAQmxGetExtendedErrorInfo(errBuff,2048);
		DAQmxClearTask(taskHandle);
		if( AItaskHandle ) {
			DAQmxStopTask(AItaskHandle);
			DAQmxClearTask(AItaskHandle);
			AItaskHandle = 0;
		}
		if( AOtaskHandle ) {
			DAQmxStopTask(AOtaskHandle);
			DAQmxClearTask(AOtaskHandle);
			AOtaskHandle = 0;
		}
		printf("DAQmx Error: %s\n",errBuff);
	}
	return 0;
}

int GenSineWave(int numElements, double amplitude, double frequency, double *phase, double sineWave[])
{
	int i=0;

	for(;i<numElements;++i)
		sineWave[i] = amplitude*sin(PI/180.0*(*phase+360.0*frequency*i));
	*phase = fmod(*phase+frequency*360.0*numElements,360.0);
	return 0;
}

static int32 GetTerminalNameWithDevPrefix(TaskHandle taskHandle, const char terminalName[], char triggerName[])
{
	int32	error=0;
	char	device[256];
	int32	productCategory;
	uInt32	numDevices,i=1;

	DAQmxErrChk (DAQmxGetTaskNumDevices(taskHandle,&numDevices));
	while( i<=numDevices ) {
		DAQmxErrChk (DAQmxGetNthTaskDevice(taskHandle,i++,device,256));
		DAQmxErrChk (DAQmxGetDevProductCategory(device,&productCategory));
		if( productCategory!=DAQmx_Val_CSeriesModule && productCategory!=DAQmx_Val_SCXIModule ) {
			*triggerName++ = '/';
			strcat(strcat(strcpy(triggerName,device),"/"),terminalName);
			break;
		}
	}

Error:
	return error;
}
