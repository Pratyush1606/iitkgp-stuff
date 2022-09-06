package com.example.pedometer;

import java.lang.Math;

public class KullbackLiebler {

    private static final double[][] pdf = new double[][]{
            // Standing Still
            {2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.473049e-14, 4.651192e-02, 8.169967e-01, 1.364910e-01, 3.833863e-07, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16}
            // Walking
            ,{2.220451e-16, 2.234563e-16, 1.988345e-15, 9.341733e-13, 2.087014e-10, 1.970907e-08, 7.865900e-07, 1.326698e-05, 9.456931e-05, 2.850521e-04, 3.671652e-04, 2.415422e-04, 2.543269e-04, 5.062315e-04, 1.137154e-03, 2.803654e-03, 5.306029e-03, 9.221794e-03, 1.703403e-02, 3.067062e-02, 5.169949e-02, 7.720157e-02, 9.655099e-02, 1.026508e-01, 9.955260e-02, 8.815217e-02, 7.271891e-02, 6.141366e-02, 5.508608e-02, 5.105377e-02, 4.612322e-02, 3.907479e-02, 3.127602e-02, 2.311662e-02, 1.495874e-02, 8.771021e-03, 5.161965e-03, 2.914330e-03, 1.578969e-03, 9.348819e-04, 6.658662e-04, 6.060439e-04, 4.907047e-04, 2.444546e-04, 5.941850e-05, 6.334828e-06, 2.917609e-07, 5.678848e-09, 4.671284e-11, 1.626082e-13, 4.606084e-16, 2.221927e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16}
            // Running
            ,{8.742735e-04, 1.399551e-03, 2.138514e-03, 3.130479e-03, 4.403115e-03, 5.971939e-03, 7.833878e-03, 9.967912e-03, 1.233265e-02, 1.486484e-02, 1.748289e-02, 2.008912e-02, 2.257882e-02, 2.484982e-02, 2.681338e-02, 2.840073e-02, 2.956799e-02, 3.029859e-02, 3.060098e-02, 3.050793e-02, 3.007044e-02, 2.935253e-02, 2.842422e-02, 2.735594e-02, 2.621603e-02, 2.506809e-02, 2.397174e-02, 2.297734e-02, 2.212234e-02, 2.142631e-02, 2.088886e-02, 2.048987e-02, 2.019915e-02, 1.998307e-02, 1.980985e-02, 1.964993e-02, 1.947398e-02, 1.924899e-02, 1.893887e-02, 1.851039e-02, 1.794152e-02, 1.722894e-02, 1.639072e-02, 1.546011e-02, 1.447563e-02, 1.346972e-02, 1.246329e-02, 1.146359e-02, 1.047191e-02, 9.488863e-03, 8.521015e-03, 7.582250e-03, 6.691540e-03, 5.869481e-03, 5.133460e-03, 4.494322e-03, 3.955268e-03, 3.511275e-03, 3.151835e-03, 2.862023e-03, 2.626864e-03, 2.433569e-03, 2.272288e-03, 2.135817e-03, 2.019097e-03, 1.916837e-03, 1.822567e-03, 1.728621e-03, 1.626772e-03, 1.510591e-03, 1.376928e-03, 1.227430e-03, 1.068307e-03, 9.084504e-04, 7.568892e-04, 6.210381e-04, 5.053858e-04, 4.116020e-04, 3.392559e-04, 2.876278e-04, 2.560088e-04, 2.433664e-04, 2.475276e-04, 2.644105e-04, 2.874684e-04, 3.086600e-04, 3.202374e-04, 3.164357e-04, 2.954915e-04, 2.595516e-04, 2.138902e-04, 1.651130e-04, 1.193648e-04, 8.075030e-05, 5.108893e-05, 3.025312e-05, 1.675585e-05, 8.679693e-06, 4.205064e-06, 1.905285e-06, 8.073375e-07}
            // Going Upstairs
            ,{1.012280e-08, 5.614557e-08, 3.679011e-07, 2.120682e-06, 1.062035e-05, 3.858326e-05, 1.205652e-04, 3.325561e-04, 8.078673e-04, 1.750917e-03, 3.403849e-03, 5.983320e-03, 9.583060e-03, 1.409833e-02, 1.921771e-02, 2.449303e-02, 2.947524e-02, 3.386976e-02, 3.762385e-02, 4.088811e-02, 4.388890e-02, 4.674568e-02, 4.934061e-02, 5.128719e-02, 5.208791e-02, 5.144481e-02, 4.952937e-02, 4.697843e-02, 4.453695e-02, 4.262708e-02, 4.116409e-02, 3.971201e-02, 3.779058e-02, 3.510432e-02, 3.161109e-02, 2.748290e-02, 2.302795e-02, 1.859421e-02, 1.447086e-02, 1.083868e-02, 7.765521e-03, 5.262426e-03, 3.322184e-03, 1.922413e-03, 1.004168e-03, 4.684404e-04, 1.927559e-04, 6.952220e-05, 2.177757e-05, 5.728040e-06, 1.402653e-06, 1.009669e-07, 1.920722e-08, 3.152989e-09, 4.466349e-10, 5.459546e-11, 5.758986e-12, 5.243967e-13, 4.139338e-14, 3.012571e-15, 3.852557e-16, 2.302819e-16, 2.224034e-16, 2.220581e-16, 2.220450e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16}
            // Going Downstairs
            ,{3.090803e-05, 7.741649e-05, 1.775604e-04, 3.787033e-04, 7.470090e-04, 1.376882e-03, 2.372191e-03, 3.842770e-03, 5.875616e-03, 8.525430e-03, 1.179572e-02, 1.563689e-02, 1.993725e-02, 2.451676e-02, 2.912506e-02, 3.346418e-02, 3.724469e-02, 4.026098e-02, 4.244866e-02, 4.387834e-02, 4.468098e-02, 4.494222e-02, 4.462336e-02, 4.358188e-02, 4.167096e-02, 3.887351e-02, 3.538798e-02, 3.160340e-02, 2.798000e-02, 2.489909e-02, 2.254184e-02, 2.087595e-02, 1.971451e-02, 1.882625e-02, 1.801727e-02, 1.717510e-02, 1.625360e-02, 1.525157e-02, 1.419410e-02, 1.313017e-02, 1.212752e-02, 1.125291e-02, 1.053938e-02, 9.965626e-03, 9.462645e-03, 8.950262e-03, 8.370176e-03, 7.713181e-03, 7.007772e-03, 6.296597e-03, 5.615079e-03, 4.976930e-03, 4.377863e-03, 3.806062e-03, 3.252447e-03, 2.715608e-03, 2.201731e-03, 1.723370e-03, 1.293085e-03, 9.237244e-04, 6.231683e-04, 3.946056e-04, 2.327254e-04, 1.272944e-04, 6.423134e-05, 2.956677e-05, 1.250854e-05, 4.759690e-06, 1.707404e-06, 4.954362e-07, 1.494314e-07, 4.085886e-08, 1.012793e-08, 2.275860e-09, 4.636182e-10, 8.561828e-11, 1.433400e-11, 2.175657e-12, 2.995324e-13, 3.755459e-14, 4.443319e-15, 6.547475e-16, 2.622539e-16, 2.254319e-16, 2.223033e-16, 2.220625e-16, 2.220457e-16, 2.220447e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16, 2.220446e-16}
    };


public double[] KLDiv(double[] pdf_acc) {
    int pdf_count = 5;
    int hist_order = 101;
    double[] Divergence = new double[pdf_count];
        for (int i = 0; i < pdf_count; i++) {
            Divergence[i] = 0;
        }
        for (int k = 0; k< pdf_count; k++) {
            for (int i = 0; i < hist_order; i++) {
                Divergence[k] += pdf_acc[i] * (Math.log10(pdf_acc[i] + 2.220446e-16) - Math.log10(pdf[k][i]));
            }
        }
        return Divergence;
    }

}