# CyclePro
Sensor-based platform-independent gait cycle detection framework


## Framework Implementation
CyclePro.m - main function with the input of data file name ('fname') and sensor sampling frequency ('freq')

Correlation.m - help function to compute normalized cross-correlation

newPeak.m - help function to finalize the segmentation points for gait cycles


## Sample Data (freq = 26Hz)
acc.csv - 3D accelerometer data collected from one foot in a 10-meter-walk experiment

gyro.csv - 3D gyroscope data collected from one foot in a 10-meter-walk experiment

fsr.csv - five 1D force-sensing resistor data collected under one foot in a 10-meter-walk experiment


## Sample Visualization
Image files named acc-salience.jpg, acc-temp1.jpg, acc-temp2.jpg and acc-temp3.jpg provide visualization of the stepwise results in CyclePro.
