# Solar-Tracker
- This is a 8051 based small project to track the direction of light. Using LDR we get appropiate voltage which is converted into digital form by ADC0808. This digital voltage (Intensity) will be shown on LCD in percentage and  accordingly the motor will be moved on which the solar panel is to be placed.
- This project uses Keil u vision,proteus and code is done using assembly language.
- For LDR keep ADC0808 pin (ADD A) Low and for measuring using POT Set ADC0808 pin (ADD A) in this way we can select either LDR or POT for measuring.
- Potentiometer is used to check measurements precisely as proteus only allows some values.

![image](https://user-images.githubusercontent.com/79077056/149976291-d0bc8270-53ca-4f8e-80c2-e36c8ceb6463.png)

## THREE SOLAR PANEL CONDITIONS

- When Intensity is more in LDR
![image](https://user-images.githubusercontent.com/79077056/149975259-b5298a1f-2116-4f24-ab37-099a2c5b4b8f.png)
- When Intensity is little in LDR
![image](https://user-images.githubusercontent.com/79077056/149975398-7cc6ad52-d0a5-42b6-9e17-d321c9604140.png)
- When Intensity is less in LDR
![image](https://user-images.githubusercontent.com/79077056/149975471-3e25ce5d-5537-40c5-a1ee-3d39f3292d09.png)

