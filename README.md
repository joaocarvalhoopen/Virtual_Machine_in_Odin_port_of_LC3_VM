# Virtual Machine in Odin port of LC3-VM
A port of a simple LC3 Virtual Machine from C to the Odin programming language.

## Description

This is a port of the LC3-VM virtual machine from C to the Odin language. This is a simple 16 bit VM that can run simple LC3 programs. The original code was written in less than 125 lines of C code. My version has more lines because I formatted the code and added some comments. The original code is also included in the format of comments, so that other persons can follow it and it was very important in the Epopeic debug that I did, because I have initially made some errors in the port and some of them were really silent. The original code was written by Andrei Ciobanu - nomemory. But all in all it was a very good exercise to port this code to the Odin language, and lots of fun!

## Original author of cl3-vm
Andrei Ciobanu - nomemory <br>
Software Engineer from Eastern Europe. <br>
[https://www.andreinc.net/](https://www.andreinc.net/)

## Original blob post article
lc3-vm <br>
Writing a simple 16 bit VM in less than 125 lines of C <br>
[https://www.andreinc.net/2021/12/01/writing-a-simple-vm-in-less-than-125-lines-of-c](https://www.andreinc.net/2021/12/01/writing-a-simple-vm-in-less-than-125-lines-of-c) <br>
<br>
A LC3 virtual machine implementation in a few lines of C code. <br>
The machine should be able to run simple LC3 programs.

## Original github repository
Github - nomemory - lc3-vm <br>
[https://github.com/nomemory/lc3-vm](https://github.com/nomemory/lc3-vm)  

## Usage
This was developed in the Odin language in Linux. <br>
You only need the Odin compiler and make to run this code. <br>
To compile and run the code of this Virtual Machine with 2 provided programs do: <br>

```
# Compile the Virtual Machine in Odin
$ make


# ==> PROG1
# Compile the program that generate the obj - object
# file for prog1.
$ make prog_1

# Run the program that generate the obj - object file
# for prog1.
$ make run_prog_1

# To run the Virtual Machine with the program 1 object
# file.    
$ make run_vm_prog_1


# ==> PROG2
# Compile the program that generate the obj - object
# file for prog2.
$ make prog_2

# Run the program that generate the obj - object file
# for prog2.
$ make run_prog_2

# To run the virtual machine with the program 2 object
# file.
$ make run_vm_prog_2
```

## Have fun!
Best regards, <br>
João Carvalho <br>