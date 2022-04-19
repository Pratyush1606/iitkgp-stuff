package com.example.pedometer;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.text.Editable;
import android.view.View;
import android.widget.TextView;
import android.widget.ProgressBar;
import android.widget.EditText;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    private static final KalmanFilter1 KF = new KalmanFilter1();
    private static final KullbackLiebler KL = new KullbackLiebler();
    private static final MatFunc MATLAB = new MatFunc();
    private TextView xText,yText,zText,statusText;
    private EditText suffix;
    private ProgressBar progress;

    private static String State = "Unknown";
    private static final int num_cat = 5;
    private static double[] category = new double[num_cat];

    public void dumpHistory(View view) {
        KF.dumpHistory(this);
    }

    private void classify(double[][] zcap, double[] category) {
        double acc = MATLAB.twoNorm(zcap, 3, 1);
        double min = category[0];
        int minidx = 0;
        if (acc < 0.8) {
            minidx = -1;
        }
        else {
            for (int i = 1; i < num_cat; i++) {
                if (category[i] < min) {
                    min = category[i];
                    minidx = i;
                }
            }
        }
        switch (minidx) {
            case -1:
                State = "Free Fall";
                break;
            case 0:
                State = "Standing Still";
                break;
            case 1:
                State = "Walking";
                break;
            case 2:
                State = "Running";
                break;
            case 3:
                State = "Going Upstairs";
                break;
            case 4:
                State = "Going Downstairs";
                break;
            default:
                State = "Unknown";
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // Create Sensor manager
        SensorManager SM = (SensorManager) getSystemService(SENSOR_SERVICE);
        // Assign accelerometer sensor manager
        assert SM != null;
        Sensor trueSensor = SM.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        // Register listener
        SM.registerListener(this, trueSensor, 50000);
        // Assign text view variables
        progress = findViewById(R.id.progressBar);
        progress.setMax(100);
        progress.setProgress(0);
        xText = findViewById(R.id.xText);
        yText = findViewById(R.id.yText);
        zText = findViewById(R.id.zText);
        statusText = findViewById(R.id.Status);
        suffix = findViewById(R.id.inputSuffix);
        KF.init();
    }

    @SuppressLint("SetTextI18n")
    @Override
    public void onSensorChanged(SensorEvent event) {
        double[][] Z = new double[3][1];
        for (int i=0; i<3; i++) {
            Z[i][0] = event.values[i];
        }
        double[][] zcap = KF.track(Z, System.currentTimeMillis()/1e3);
        KF.storeMem(Z, zcap, this);
        if (KalmanFilter1.datapoints > KalmanFilter1.acc_order) {
            category = KL.KLDiv(KalmanFilter1.pdf_acc);
            classify(zcap, category);
        }
        xText.setText("\tX: "+Z[0][0]+"\n\tY: "+Z[1][0]+"\n\tZ: "+Z[2][0]+"\nMeanAcc: "+ KalmanFilter1.accNorm);
        yText.setText("Standing Still: "+category[0]+"\nWalking: "+category[1]+"\nRunning: "+category[2]+"\nGoing Up: "+category[3]+"\nGoing Down: "+category[4]);
        zText.setText("h: "+ KalmanFilter1.h);
        statusText.setText("Status: "+State);
        progress.setProgress(KalmanFilter1.progress);
        KalmanFilter1.suffix = suffix.getText().toString();

    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

}
