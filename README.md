# Chip8-Verilog
A basic implementation (6 instructions) of Chip 8.

Video:

https://github.com/user-attachments/assets/69308db4-ee98-405e-8f5e-cbd777ea6b18

## What is Chip 8
Chip 8 is an intrepretted programming language that was implemented for 1802 Microprocessor.
It was made to be easy to program for and to use less memory than other programming languages like BASIC.

## What does my emulator do?
My emulator has a FETCH, DECODE, EXECUTE cycle for CHIP 8 Console. It Decodes 6 instructions required for
running the IBMLOGO rom which is a rom to test the working of the Chip 8.

## How am I doing display
I am sending the DRAW data serially through UART protocol to the computer and using a python program to display.
