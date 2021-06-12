# Solar-Tracker
- This is a 8051 based small project to track the direction of light. Using LDR we get appropiate voltage which is converted into digital form by ADC0808. This digital voltage (Intensity) will be shown on LCD in percentage and  accordingly the motor will be moved on which the solar panel is to be placed.
- This project uses Keil u vision,proteus and code is done using assembly language.
- For LDR keep ADC0808 pin (ADD A) Low and for measuring using POT Set ADC0808 pin (ADD A) in this way we can select either LDR or POT for measuring.
- Potentiometer is used to check measurements precisely as proteus only allows some values.
