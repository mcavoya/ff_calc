# ff_calc
Verilog HDL Four Function Calculator

This project was started as an excercise. I wanted to try my hand at developing a four function calculator in Verilog HDL. More specifically, I wanted to design a Shunting Yard parser which converts infix notation to postfix (RPN). More information about the shunting yard algorithm can be found on Wikipedia.<br>
https://en.wikipedia.org/wiki/Shunting-yard_algorithm

Since this project is just an exercise, it is not very practical. But, it is completely extensible and could easilly be made fully functional.  Right now it simply uses 4-bit tokens.  The tokens are BCD 0 through 9, plus...

0xA : + (addition)<br>
0xB : - (subtraction)<br>
0xC : * (multiplication)<br>
0xD : / (division)<br>
0xE : = (equals)<br>
0xF : clear<br>

The calculations are simple integer math with no attempt at carry, borrow, rounding, etc.
