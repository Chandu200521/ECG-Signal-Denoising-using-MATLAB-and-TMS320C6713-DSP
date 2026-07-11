#include "fir_coeffs.h"

/* Delay line */

float delay_line[FIR_LENGTH] = {0};

float FIR_Filter(float input)
{
    int i;
    float output = 0.0f;

    /* Shift delay line */

    for(i = FIR_LENGTH-1; i > 0; i--)
    {
        delay_line[i] = delay_line[i-1];
    }

    /* Insert newest sample */

    delay_line[0] = input;

    /* FIR convolution */

    for(i = 0; i < FIR_LENGTH; i++)
    {
        output += fir_coeffs[i] * delay_line[i];
    }

    return output;
}
