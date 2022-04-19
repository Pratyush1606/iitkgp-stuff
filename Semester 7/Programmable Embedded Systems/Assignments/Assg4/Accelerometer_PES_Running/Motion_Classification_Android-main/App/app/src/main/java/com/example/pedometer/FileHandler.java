package com.example.pedometer;

import android.annotation.SuppressLint;
import android.content.Context;
import android.widget.Toast;
import android.os.Environment;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class FileHandler {

    public void dumpHistory(int len_hist, int hist_order, double[][] z_hist, double[][] zcap_hist, double[] pdf_acc, String suffix, Context context) {

        try {
            File root = new File(Environment.getExternalStorageDirectory(), "Kalman");
            if (!root.exists()) {
                root.mkdirs();
            }
            File zFile = new File(root, "Raw_Data_"+suffix.toString()+".txt");
            File zcapFile = new File(root, "Filtered_Data_"+suffix.toString()+".txt");
            File histFile = new File(root, "Histogram_"+suffix.toString()+".txt");

            Toast.makeText(context, "Data Dumped", Toast.LENGTH_LONG ).show();

            FileWriter zwriter = new FileWriter(zFile);
            FileWriter zcapwriter = new FileWriter(zcapFile);
            FileWriter histwriter = new FileWriter(histFile);
            for (int i=len_hist-1; i>=0; i--) {
                @SuppressLint("DefaultLocale") String temp1 = String.format("%f %f %f\n", z_hist[i][0], z_hist[i][1], z_hist[i][2]);
                @SuppressLint("DefaultLocale") String temp2 = String.format("%f %f %f\n", zcap_hist[i][0], zcap_hist[i][1], zcap_hist[i][2]);
                zwriter.write(temp1);
                zcapwriter.write(temp2);
            }
            for(int i=0; i<hist_order; i++) {
                @SuppressLint("DefaultLocale") String temp3 = String.format("%e\n", pdf_acc[i]);
                histwriter.write(temp3);
            }
            zwriter.close();
            zcapwriter.close();
            histwriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}
