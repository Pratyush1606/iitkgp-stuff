package com.example.pedometer;

import java.lang.Math;

public class MatFunc {

    public double[][] matMul(double[][] A, double[][] B, int n, int m, int s) {
        // A - n x m
        // B - m x s
        // C - n x s
        double[][] C = new double[n][s];
        for (int i=0; i<n; i++) {
            for (int j=0; j<s; j++) {
                C[i][j] = 0.0;
            }
        }
        for (int i=0; i<n; i++) {
            for (int j=0; j<s; j++) {
                for (int k=0; k<m; k++) {
                    C[i][j] += A[i][k]*B[k][j];
                }
            }
        }
        return C;
    }

    public double twoNorm(double[][] A, int n, int m) {
        double sum = 0;
        for (int i=0; i<n; i++) {
            for (int j=0; j<m; j++) {
                sum += A[i][j]*A[i][j];
            }
        }
        return Math.sqrt(sum);
    }

    public double twoNormVect(double[] A, int n) {
        double sum = 0;
        for (int i=0; i<n; i++) {
            sum += A[i]*A[i];
        }
        return Math.sqrt(sum);
    }

    public double oneNorm(double[] A, int n) {
        double sum = 0;
        for (int i=0; i<n; i++) {
            sum += Math.abs(A[i]);
        }
        return sum;
    }

    public double[][] matTranspose(double[][] A, int n, int m) {
        // A - n x m
        // B - m x n
        double[][] B = new double[m][n];
        for (int i=0; i<n; i++) {
            for (int j=0; j<m; j++) {
                B[j][i] = A[i][j];
            }
        }
        return B;
    }

    public double[][] matAdd(double[][] A, double[][] B, int n, int m, int sign) {
        double[][] C = new double[n][m];
        for (int i=0; i<n; i++) {
            for (int j=0; j<m; j++) {
                C[i][j] = A[i][j] + B[i][j]*sign;
            }
        }
        return C;
    }

    static void getCofactor(double[][] A, double[][] temp, int p, int q, int n)
    {
        int i = 0, j = 0;
        for (int row = 0; row < n; row++)
        {
            for (int col = 0; col < n; col++)
            {
                if (row != p && col != q)
                {
                    temp[i][j++] = A[row][col];
                    if (j == n - 1)
                    {
                        j = 0;
                        i++;
                    }
                }
            }
        }
    }

    static double determinant(double A[][], int n, int N)
    {
        int D = 0;
        if (n == 1)
            return A[0][0];
        double [][]temp = new double[N][N];
        int sign = 1;
        for (int f = 0; f < n; f++)
        {
            getCofactor(A, temp, 0, f, n);
            D += sign * A[0][f] * determinant(temp, n - 1, N);
            sign = -sign;
        }

        return D;
    }

    static void adjoint(double[][] A, double[][] adj, int  N)
    {
        if (N == 1)
        {
            adj[0][0] = 1;
            return;
        }
        int sign = 1;
        double [][]temp = new double[N][N];

        for (int i = 0; i < N; i++)
        {
            for (int j = 0; j < N; j++)
            {
                getCofactor(A, temp, i, j, N);
                sign = ((i + j) % 2 == 0)? 1: -1;
                adj[j][i] = (sign)*(determinant(temp, N-1, N));
            }
        }
    }

    static boolean inverse(double A[][], double [][]inverse, int N)
    {
        double det = determinant(A, N, N);
        if (det == 0)
        {
            System.out.print("Singular matrix, can't find its inverse");
            return false;
        }
        double [][]adj = new double[N][N];
        adjoint(A, adj, N);
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++)
                inverse[i][j] = adj[i][j]/(float)det;

        return true;
    }

    public double[][] genID(int n) {
        double[][] ID = new double[n][n];
        for (int i=0; i<n; i++) {
            for (int j=0; j<n; j++) {
                if (i==j)
                    ID[i][j] = 1;
                else
                    ID[i][j] = 0;
            }
        }
        return ID;
    }

}
