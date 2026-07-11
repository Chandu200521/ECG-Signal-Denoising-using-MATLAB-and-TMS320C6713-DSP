#include "iir_coeffs.h"

float sos_matrix[NUM_SECTIONS][6] =
{
    {0.9778825105f, -1.9557650210f, 0.9778825105f, 1.0000000000f, -1.9829520420f, 0.9830275497f},
    {1.0000000000f, -2.0000000000f, 1.0000000000f, 1.0000000000f, -1.9855172327f, 0.9855928380f},
    {1.0000000000f, -2.0000000000f, 1.0000000000f, 1.0000000000f, -1.9902745902f, 0.9903503766f},
    {1.0000000000f, -2.0000000000f, 1.0000000000f, 1.0000000000f, -1.9965248372f, 0.9966008617f}
};

float x1[NUM_SECTIONS] = {0};
float x2[NUM_SECTIONS] = {0};

float y1[NUM_SECTIONS] = {0};
float y2[NUM_SECTIONS] = {0};

float ButterworthHPF(float input)
{
    int sec;

    float stage_in = input;
    float stage_out;

    for(sec=0; sec<NUM_SECTIONS; sec++)
    {
        float b0 = sos_matrix[sec][0];
        float b1 = sos_matrix[sec][1];
        float b2 = sos_matrix[sec][2];

        float a0 = sos_matrix[sec][3];
        float a1 = sos_matrix[sec][4];
        float a2 = sos_matrix[sec][5];

        stage_out =
            b0*stage_in
          + b1*x1[sec]
          + b2*x2[sec]
          - a1*y1[sec]
          - a2*y2[sec];

        stage_out /= a0;

        x2[sec] = x1[sec];
        x1[sec] = stage_in;

        y2[sec] = y1[sec];
        y1[sec] = stage_out;

        stage_in = stage_out;
    }

    return stage_out;
}