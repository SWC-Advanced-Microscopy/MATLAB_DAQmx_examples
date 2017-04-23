/*********************************************************************
*
* ANSI C Example program:
*    ContGen-ExtClk-DigStart.c
*
* Example Category:
*    AO
*
* Description:
*    This example demonstrates how to continuously output a waveform
*    using an external sample clock and a digital start trigger.
*
* Instructions for Running:
*    1. Select the Physical Channel to correspond to where your
*       signal is output on the DAQ device.
*    2. Enter the Minimum and Maximum Voltage range.
*    3. Select the Sample Clock source.
*    4. Select the Digital Trigger source.
*    5. Specify the desired Trigger Edge.
*    6. Select the desired waveform type.
*    7. The rest of the parameters in the Waveform Information
*       section will affect the way the waveform is created, before
*       it's sent to the analog output of the board. Select the
*       number of samples per cycle and the total number of cycles to
*       be used as waveform data.
*
* Steps:
*    1. Create a task.
*    2. Create an Analog Output Voltage channel.
*    3. Define the Sample Clock source. Additionally, define the
*       sample mode to be continuous.
*    4. Define the Triggering parameters: Source and Edge.
*    5. Write the waveform to the output buffer.
*    6. Call the Start function.
*    7. Wait until the user presses the Stop button.
*    8. Call the Clear Task function to clear the Task.
*    9. Display an error if any.
*
* I/O Connections Overview:
*    Make sure your signal output terminal matches the Physical
*    Channel I/O Control. Also, make sure your digital trigger
*    terminal matches the Trigger Source Control. For further
*    connection information, refer to your hardware reference manual.
*
*********************************************************************/

#include <NIDAQmx.h>
#include <stdio.h>
#include <math.h>

#define DAQmxErrChk(functionCall) if( DAQmxFailed(error=(functionCall)) ) goto Error; else

#define PI	3.1415926535

int32 CVICALLBACK DoneCallback(TaskHandle taskHandle, int32 status, void *callbackData);

int main(void)
{
	int32       error=0;
	TaskHandle  taskHandle=0;
	float64     data[1000];
	char        errBuff[2048]={'\0'};
	int         i=0;

	for(;i<1000;i++)
		data[i] = 9.95*sin((double)i*2.0*PI/1000.0);

	/*********************************************/
	// DAQmx Configure Code
	/*********************************************/
	DAQmxErrChk (DAQmxCreateTask("",&taskHandle));
	DAQmxErrChk (DAQmxCreateAOVoltageChan(taskHandle,"Dev1/ao0","",-10.0,10.0,DAQmx_Val_Volts,NULL));
	DAQmxErrChk (DAQmxCfgSampClkTiming(taskHandle,"/Dev1/PFI0",1000.0,DAQmx_Val_Rising,DAQmx_Val_ContSamps,1000));
	DAQmxErrChk (DAQmxCfgDigEdgeStartTrig(taskHandle,"/Dev1/PFI0",DAQmx_Val_Rising));

	DAQmxErrChk (DAQmxRegisterDoneEvent(taskHandle,0,DoneCallback,NULL));

	/*********************************************/
	// DAQmx Write Code
	/*********************************************/
	DAQmxErrChk (DAQmxWriteAnalogF64(taskHandle,1000,0,10.0,DAQmx_Val_GroupByChannel,data,NULL,NULL));

	/*********************************************/
	// DAQmx Start Code
	/*********************************************/
	DAQmxErrChk (DAQmxStartTask(taskHandle));

	printf("Generating voltage continuously. Press Enter to interrupt\n");
	getchar();

Error:
	if( DAQmxFailed(error) )
		DAQmxGetExtendedErrorInfo(errBuff,2048);
	if( taskHandle!=0 ) {
		/*********************************************/
		// DAQmx Stop Code
		/*********************************************/
		DAQmxStopTask(taskHandle);
		DAQmxClearTask(taskHandle);
	}
	if( DAQmxFailed(error) )
		printf("DAQmx Error: %s\n",errBuff);
	printf("End of program, press Enter key to quit\n");
	getchar();
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
		printf("DAQmx Error: %s\n",errBuff);
	}
	return 0;
}
