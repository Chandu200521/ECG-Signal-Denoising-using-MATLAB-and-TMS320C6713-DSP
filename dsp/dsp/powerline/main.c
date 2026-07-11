#define ECG_LENGTH 1024

#include "ecg_data_2.h"
#include "fir_coeffs.h"

float ecg_output[ECG_LENGTH];

float FIR_Filter(float input);

int main(void)
{
    int i;

    for(i = 0; i < ECG_LENGTH; i++)
    {
        ecg_output[i] = FIR_Filter(ecg_input[i]);
    }

    while(1)
    {
    }
}
