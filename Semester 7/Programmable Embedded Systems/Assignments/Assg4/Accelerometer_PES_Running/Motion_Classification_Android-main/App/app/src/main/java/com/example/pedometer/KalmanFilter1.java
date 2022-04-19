package com.example.pedometer;

import android.content.Context;
import android.widget.Toast;
import java.lang.Math;

public class KalmanFilter1 {

    private static final MatFunc MATLAB = new MatFunc();
    private static final FileHandler FileH = new FileHandler();
    public static final double[][] H = new double[][]{  {0, 0, 0, 0, 0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0, 0, 0, 1, 0},
            {0, 0, 0, 0, 0, 0, 0, 0, 1}};

    public static double[][] P = new double[9][9];
    public static double[][] R = new double[3][3];
    public static double[][] Q = new double[9][9];
    public static double[][] X = new double[9][1];

    public static int len_hist = 100;
    public static int acc_order = 50;
    public static double[][] filtered_data = new double[len_hist][3];
    public static double[][] raw_data = new double[len_hist][3];
    public static double[] acc = new double[acc_order];
    public static int datapoints = 0;

    public static double[][] K = new double[9][3];
    public static double accNorm = 0;
    public static double prevTime = 0.0;
    public static double h;

    public static int hist_order = 101;
    public static double lb = 0.0;
    public static double ub = 40.0;
    public static double[] pdf_acc = new double[hist_order];

    private static int startRecording = 0;
    private static int timeOut = 0;
    public static int progress = 0;

    public static String suffix = "";

    public void init() {
        prevTime = System.currentTimeMillis()/1e3;
        for(int i=0; i<acc_order; i++) {
            acc[i] = 0;
        }
        for (int i=0; i<9; i++) {
            for (int j=0; j<3; j++) {
                K[i][j] = 0;
            }
        }
        for (int i=0; i<hist_order; i++) {
            if (i == returnBin(0))
                pdf_acc[i] = 1;
            else
                pdf_acc[i] = 0;
        }
        for(int i=0; i<9; i++) {
            X[i][0] = 0.1;
            for(int j=0; j<9; j++) {
                if (i == j) {
                    P[i][j] = 5;
                    Q[i][j] = 1;
                }
                else {
                    P[i][j] = 0;
                    Q[i][j] = 0;
                }
            }
        }
        for(int i=0; i<3; i++) {
            for(int j=0; j<3; j++) {
                if (i == j)
                    R[i][j] = 0.1;
                else
                    R[i][j] = 0;
            }
        }
        for(int i=0; i<len_hist; i++) {
            for(int j=0; j<3; j++) {
                raw_data[i][j] = 0.0;
                filtered_data[i][j] = 0.0;
            }
        }
    }

    public void storeMem(double[][] Z, double[][] zcap, Context context) {
        if (timeOut > 0 && startRecording == 1) {
            progress = 100 - (int) ((double)timeOut*100/len_hist);
            timeOut = timeOut - 1;
        }
        else if (timeOut <= 0 && startRecording == 1) {
            FileH.dumpHistory(len_hist, hist_order, raw_data, filtered_data, pdf_acc, suffix, context);
            startRecording = 0;
            timeOut = 0;
            progress = 100;
        }
        if (startRecording == 1) {
            for (int i = len_hist - 1; i >= 1; i--) {
                for (int j = 0; j < 3; j++) {
                    raw_data[i][j] = raw_data[i - 1][j];
                    filtered_data[i][j] = filtered_data[i - 1][j];
                }
            }
            for (int i = 0; i < 3; i++) {
                raw_data[0][i] = Z[i][0];
                filtered_data[0][i] = zcap[i][0];
            }
        }
        accNorm -= acc[acc_order-1]/acc_order;
        for(int i=acc_order-1; i>=1; i--) {
            acc[i] = acc[i-1];
        }
        acc[0] = MATLAB.twoNorm(zcap, 3, 1);
        accNorm += acc[0]/acc_order;
        updateHist();
        datapoints += 1;
        if (datapoints == acc_order) {
            Toast.makeText(context, "Calibrated", Toast.LENGTH_LONG ).show();
        }
    }

    public void dumpHistory(Context context) {
        // Starts recording the history of acceleration data over a window len_hist
        if (datapoints >= acc_order && startRecording == 0) {
            startRecording = 1;
            timeOut = len_hist;
        }
        else {
            Toast.makeText(context, "Not ready", Toast.LENGTH_SHORT ).show();
        }
    }

    public double[][] track(double[][] Z, double time) {

        // Implements the Kalman Filter

        // dX = Ph*X + q
        // z = H*X + r
        // Q = Cov(q), R = Cov(r)

        h = time - prevTime;
        prevTime = time;
        double h2 = h*h/2;
        double[][] Ph = new double[][]{ {1, 0, 0, h, 0, 0, h2, 0, 0},
                {0, 1, 0, 0, h, 0, 0, h2, 0},
                {0, 0, 1, 0, 0, h, 0, 0, h2},
                {0, 0, 0, 1, 0, 0, h, 0, 0},
                {0, 0, 0, 0, 1, 0, 0, h, 0},
                {0, 0, 0, 0, 0, 1, 0, 0, h},
                {0, 0, 0, 0, 0, 0, 1, 0, 0},
                {0, 0, 0, 0, 0, 0, 0, 1, 0},
                {0, 0, 0, 0, 0, 0, 0, 0, 1}};

        // Step 1 : Compute Kalman Gain
        // K = P*H*(H*P*H' + R)^-1
        double[][] Ht = MATLAB.matTranspose(H, 3, 9);
        double[][] Ktemp = MATLAB.matMul(H, P, 3, 9, 9);
        Ktemp = MATLAB.matMul(Ktemp, Ht, 3, 9, 3);
        Ktemp = MATLAB.matAdd(Ktemp, R, 3, 3, 1);
        double[][] inv = new double[3][3];
        boolean invertible = MATLAB.inverse(Ktemp, inv, 3);
        if (invertible) {
            Ktemp = MATLAB.matMul(P, Ht, 9, 9, 3);
            Ktemp = MATLAB.matMul(Ktemp, inv, 9, 3, 3);
            for (int i=0; i<9; i++) {
                for (int j=0; j<3; j++) {
                    K[i][j] = Ktemp[i][j];
                }
            }
        }

        // Step 2 : Update the estimates
        // zcap = H*x
        // x = x + K*(z - zcap)
        double[][] zcap = MATLAB.matMul(H, X, 3, 9, 1);
        X = MATLAB.matAdd(X, MATLAB.matMul(K, MATLAB.matAdd(Z, zcap, 3, 1, -1), 9, 3, 1), 9, 1, 1);

        // Step 3 : Compute posterior error covariance
        // P = (I - K*H)*P
        P = MATLAB.matMul(MATLAB.matAdd(MATLAB.genID(9), MATLAB.matMul(K, H, 9, 3, 9), 9, 9, -1), P, 9, 9, 9);

        // Step 4 : Project ahead
        // x = Ph*x
        // P = Ph*P*Ph' + Q
        X = MATLAB.matMul(Ph, X, 9, 9, 1);
        P = MATLAB.matMul(MATLAB.matMul(Ph, P, 9, 9, 9), MATLAB.matTranspose(Ph, 9, 9), 9, 9, 9);
        P = MATLAB.matAdd(P, Q, 9, 9, 1);

        return zcap;
    }

    private int returnBin(double acc) {
        // Returns the bin to which a particular acceleration belongs in the histogram
        long idx = Math.round((acc - lb)*(hist_order-1)/(ub - lb));
        if (idx > hist_order-1) {
            idx = hist_order-1;
        }
        else if (idx < 0) {
            idx = 0;
        }
        return (int) idx;
    }

    public void updateHist() {
        // Updates the histogram with the data in the current acceleration window
        for (int i=0; i<hist_order; i++) {
            pdf_acc[i] = 0;
        }
        for(int i=0; i<acc_order; i++) {
            pdf_acc[returnBin(acc[i])] += 1.0/acc_order;
        }
    }

}
