#define ECG_LENGTH 1024
#include "ecg_data.h"
#include "iir_coeffs.h"



float ecg_output[ECG_LENGTH];

float ButterworthHPF(float input);

int main(void)
{
    int i;

    for(i=0;i<ECG_LENGTH;i++)
    {
        ecg_output[i] =
            ButterworthHPF(ecg_input[i]);
    }

    while(1)
    {
    }
}