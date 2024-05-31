// Name:              Virtual Machine in Odin, port of LC3-VM.
// Autor of the port: João Carvalho
// Date:              2024-05-31
// Original Author:   Andrei Ciobanu - nomemory
//                    Software Engineer from Eastern Europe.
//                    https://www.andreinc.net/
//
// Description: This is a port of the LC3-VM virtual machine from C to the Odin language.
//              This is a simple 16 bit VM that can run simple LC3 programs.
//              The original code was written in less than 125 lines of C code.
//              My version has more lines because I formatted the code and added some comments.
//              The original code is also included in the format of comments, so that other
//              persons can follow it and it was very important in the Epopeic debug that I did,
//              because I have initially made some errors in the port and some of them were
//              really silent.  
//              The original code was written by Andrei Ciobanu - nomemory.
//              But all in all it was a very good exercise to port this code to the Odin language,
//              and lots of fun!
//
// Original blob post article:
//    lc3-vm
//    Writing a simple 16 bit VM in less than 125 lines of C 
//    https://www.andreinc.net/2021/12/01/writing-a-simple-vm-in-less-than-125-lines-of-c
//
//    A LC3 virtual machine implementation in a few lines of C code.
//    The machine should be able to run simple LC3 programs.
//
// Original github repository:
//   lc3-vm
//   https://github.com/nomemory/lc3-vm
//
// 
// To compile and run the code of this Virtual Machine with 2 provided programs do:
//
//   # Compile the Virtual Machine in Odin
//   $ make
//
//
//   # ==> PROG1
//   # Compile the program that generate the obj - object file for prog1.
//   $ make prog_1
//
//   # Run the program that generate the obj - object file for prog1.
//   $ make run_prog_1
//
//   # To run the Virtual Machine with the program 1 object file.
//   $ make run_vm_prog_1
//
//
//   # ==> PROG2
//   # Compile the program that generate the obj - object file for prog2.
//   $ make prog_2
//
//   # Run the program that generate the obj - object file for prog2.
//   $ make run_prog_2
//
//   # To run the virtual machine with the program 2 object file.
//   $ make run_vm_prog_2
//
//
// This was developed in the Odin language in Linux.
// You only need the Odin compiler and make to run this code.
//
// Best regards!
//


package virtual_machine

import "core:fmt"
import "core:os"
import memory "core:mem"
import "core:c/libc"

// #define NOPS (16)

NUMBER_OPERATIONS :: 16

// #define OPC(i) ((i)>>12)

m_opc :: #force_inline proc ( i : u16 ) -> u16 {
    return i >> 12
}

// #define DR(i) (((i)>>9)&0x7)

m_dr :: #force_inline proc ( i : u16 ) -> u16 {
    return ( i >> 9 ) & 0x7
}

// #define SR1(i) (((i)>>6)&0x7)

m_sr1 :: #force_inline proc ( i : u16 ) -> u16 {
    return ( i >> 6 ) & 0x7
}

// #define SR2(i) ((i)&0x7)

m_sr2 :: #force_inline proc ( i : u16 ) -> u16 {
    return i & 0x7
}

// #define FIMM(i) ((i>>5)&01)

m_fimm :: #force_inline proc ( i : u16 ) -> u16 {
    return ( ( i >> 5 ) & 01 )
}

// #define IMM(i) ((i)&0x1F)
m_imm :: #force_inline proc ( i : u16 ) -> u16 {
    return i & 0x1F
}

// #define SEXTIMM(i) sext(IMM(i),5)

m_sextimm :: #force_inline proc ( i : u16 ) -> u16 {
    return sext( m_imm( i ) , 5 )
}

// #define FCND(i) (((i)>>9)&0x7)

m_fcnd :: #force_inline proc ( i : u16 ) -> u16 {
    return ( i >> 9 ) & 0x7
}

// #define POFF(i) sext((i)&0x3F, 6)

m_poff :: #force_inline proc ( i : u16 ) -> u16 {
    return sext( i & 0x3F , 6 )
}

// #define POFF9(i) sext((i)&0x1FF, 9)

m_poff9 :: #force_inline proc ( i : u16 ) -> u16 {
    return sext( i & 0x1FF , 9 )
}

// #define POFF11(i) sext((i)&0x7FF, 11)

m_poff11 :: #force_inline proc ( i : u16 ) -> u16 {
    return sext( i & 0x7FF , 11 )
}

// #define FL(i) (((i)>>11)&1)

m_fl :: #force_inline proc ( i : u16 ) -> u16 {
    return ( i >> 11 ) & 1
}

// #define BR(i) (((i)>>6)&0x7)

m_br :: #force_inline proc ( i : u16 ) -> u16 {
    return ( i >> 6 ) & 0x7
}

// #define TRP(i) ((i)&0xFF)

m_trp :: #force_inline proc ( i : u16 ) -> u16 {
    return i & 0xFF
}


// bool running = true;
running : bool = true

// typedef void (*op_ex_f)(uint16_t i);
op_ex_f :: proc ( i : u16 )

// typedef void (*trp_ex_f)();

trp_ex_f :: proc ()


// enum { trp_offset = 0x20 };
Trp_offset :: enum u16 {
    value = 0x20
}


// Registers of the virtual machine "processor".

// enum regist { R0 = 0, R1, R2, R3, R4, R5, R6, R7, RPC, RCND, RCNT };

Regi :: enum u16 {
    R0 = 0,
    R1,
    R2,
    R3,
    R4,
    R5,
    R6,
    R7,
    RPC,
    RCND,
    RCNT
}

// enum flags { FP = 1 << 0, FZ = 1 << 1, FN = 1 << 2 };

Flags :: enum u16 {
    FP = 1 << 0,
    FZ = 1 << 1,
    FN = 1 << 2
}

// uint16_t mem[UINT16_MAX] = {0};

U16MAX : u16 : 0xFFFF

mem : [ U16MAX ]u16 = { }  // Initialize with 0

// uint16_t reg[RCNT] = {0};

reg : [ Regi.RCNT ]u16 = { }  // Initialize with 0

reg_name := [ Regi.RCNT ]cstring{ "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "RPC", "RCND" }


// uint16_t PC_START = 0x3000;

PC_START : u16 : 0x3000

// static inline uint16_t mr(uint16_t address) { return mem[address];  }

mr :: #force_inline proc ( address : u16 ) -> u16 {
    return mem[ address ]
}

// static inline void mw(uint16_t address, uint16_t val) { mem[address] = val; }

mw :: #force_inline proc ( address : u16 , val : u16 ) {
    mem[ address ] = val
}


// static inline uint16_t sext(uint16_t n, int b) { return ((n>>(b-1))&1) ? (n|(0xFFFF << b)) : n; }

sext :: #force_inline proc ( n : u16 , b : u16 ) -> u16 {
    return ( ( n >> ( b - 1 ) ) & 1 ) != 0 ? ( n | ( 0xFFFF << b ) ) : n
}


// static inline void uf(enum regist r) {
//     if (reg[r]==0) reg[RCND] = FZ;
//     else if (reg[r]>>15) reg[RCND] = FN;
//     else reg[RCND] = FP;
// }

uf :: #force_inline proc ( r : Regi ) {
    if reg[ r ] == 0 {
        reg[ Regi.RCND ] = u16( Flags.FZ )
    } else if ( reg[ r ] >> 15 ) != 0 {
        reg[ Regi.RCND ] = u16( Flags.FN )
    } else {
        reg[ Regi.RCND ] = u16( Flags.FP )
    }
}


// static inline void add(uint16_t i)  { reg[DR(i)] = reg[SR1(i)] + (FIMM(i) ? SEXTIMM(i) : reg[SR2(i)]); uf(DR(i)); }

add :: #force_inline proc ( i : u16 ) {

    // fmt.printfln( "Add operation: m_fimm = %v, m_sextimm = %v ", m_fimm( i ), m_sextimm( i ) )

    reg[ m_dr( i ) ] = reg[ m_sr1( i ) ] + ( m_fimm( i )  != 0 ? m_sextimm( i ) : reg[ m_sr2( i ) ] ) 
    uf( Regi( m_dr( i ) ) )
}

// static inline void and(uint16_t i)  { reg[DR(i)] = reg[SR1(i)] & (FIMM(i) ? SEXTIMM(i) : reg[SR2(i)]); uf(DR(i)); }

and :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = ( reg[ m_sr1( i ) ] & ( m_fimm( i ) ) != 0 ? m_sextimm( i ) : reg[ m_sr2( i ) ] )
    uf( Regi( m_dr( i ) ) )
}

// static inline void ldi(uint16_t i)  { reg[DR(i)] = mr(mr(reg[RPC]+POFF9(i))); uf(DR(i)); }

ldi :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = mr( mr( reg[ Regi.RPC ] + m_poff9( i ) ) )
    uf( Regi( m_dr( i ) ) )
}

// static inline void not(uint16_t i)  { reg[DR(i)]=~reg[SR1(i)]; uf(DR(i)); }

not :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = ~reg[ m_sr1( i ) ]
    uf( Regi( m_dr( i ) ) )
}

// static inline void br(uint16_t i)   { if (reg[RCND] & FCND(i)) { reg[RPC] += POFF9(i); } }

br :: #force_inline proc ( i : u16 ) {
    if ( reg[ Regi.RCND ] & m_fcnd( i ) ) != 0 {
        reg[ Regi.RPC ] += m_poff9( i )
    }
}

// static inline void jsr(uint16_t i)  { reg[R7] = reg[RPC]; reg[RPC] = (FL(i)) ? reg[RPC] + POFF11(i) : reg[BR(i)]; }

jsr :: #force_inline proc ( i : u16 ) {
    reg[ Regi.R7 ] = reg[ Regi.RPC ]
    reg[ Regi.RPC ] =  m_fl( i ) != 0  ? reg[ Regi.RPC ] + m_poff11( i ) : reg[ m_br( i ) ]
}

// static inline void jmp(uint16_t i)  { reg[RPC] = reg[BR(i)]; }

jmp :: #force_inline proc ( i : u16 ) {
    reg[ Regi.RPC ] = reg[ m_br( i ) ]
}

// static inline void ld(uint16_t i)   { reg[DR(i)] = mr(reg[RPC] + POFF9(i)); uf(DR(i)); }

ld :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = mr( reg[ Regi.RPC ] + m_poff9( i ) )
    uf( Regi( m_dr( i ) ) )
}

// static inline void ldr(uint16_t i)  { reg[DR(i)] = mr(reg[SR1(i)] + POFF(i)); uf(DR(i)); }

ldr :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = mr( reg[ m_sr1( i ) ] + m_poff( i ) )
    uf( Regi( m_dr( i ) ) )
}

// static inline void lea(uint16_t i)  { reg[DR(i)] =reg[RPC] + POFF9(i); uf(DR(i)); }

lea :: #force_inline proc ( i : u16 ) {
    reg[ m_dr( i ) ] = reg[ Regi.RPC ] + m_poff9( i )
    uf( Regi( m_dr( i ) ) )
}

// static inline void st(uint16_t i)   { mw(reg[RPC] + POFF9(i), reg[DR(i)]); }

st :: #force_inline proc ( i : u16 ) {
    mw( reg[ Regi.RPC ] + m_poff9( i ) , reg[ m_dr( i ) ] )
}

// static inline void sti(uint16_t i)  { mw(mr(reg[RPC] + POFF9(i)), reg[DR(i)]); }

sti :: #force_inline proc ( i : u16 ) {
    mw( mr( reg[ Regi.RPC ] + m_poff9( i ) ) , reg[ m_dr( i ) ] )
}

// static inline void str(uint16_t i)  { mw(reg[SR1(i)] + POFF(i), reg[DR(i)]); }

str :: #force_inline proc ( i : u16 ) {
    mw( reg[ m_sr1( i ) ] + m_poff( i ) , reg[ m_dr( i ) ] )
}

// static inline void rti(uint16_t i) {} // unused

rti :: #force_inline proc ( i : u16 ) {} // unused

// static inline void res(uint16_t i) {} // unused

res :: #force_inline proc ( i : u16 ) {} // unused

// static inline void tgetc() { reg[R0] = getchar(); }

tgetc :: #force_inline proc () {
    reg[ Regi.R0 ] = u16( libc.getchar() )            // TODO: What is the getchat() function equivalente in Odin?
}

// static inline void tout() { fprintf(stdout, "%c", (char)reg[R0]); }

tout :: #force_inline proc () {
    // TODO: Check Rune cast and printf option.
    fmt.fprintf( os.stdout , "%c" , u8( rune( reg[ Regi.R0 ] )) )   
}


// static inline void tputs() {
//     uint16_t *p = mem + reg[R0];
//     while(*p) {
//         fprintf(stdout, "%c", (char)*p);
//         p++;
//     }
// }


tputs :: #force_inline proc () {
    // p : ^u16 = mem + reg[ regi.R0 ]
    new_mem_pos : ^u16 = memory.ptr_offset( &mem[0], int( reg[ Regi.R0 ] ) )
    p : ^u16 = new_mem_pos

    for  p^ != 0 {
        fmt.fprintf(os.stdout, "%c", u8( rune ( p^ ) ) )
        // p++  // TODO: Check pointer increment
        p = memory.ptr_offset( p, 1 )
    }
}

// static inline void tin() { reg[R0] = getchar(); fprintf(stdout, "%c", reg[R0]); }

tin :: #force_inline proc () {
    reg[ Regi.R0 ] = u16( libc.getchar() )        // The getchat() function equivalente in Odin.
    fmt.fprintf( os.stdout , "%c" , u8( rune( reg[ Regi.R0 ] ) ) )
}

// static inline void tputsp() { /* Not Implemented */ }

tputsp :: #force_inline proc () {} // Not Implemented

// static inline void thalt() { running = false; } 

thalt :: #force_inline proc () {
    running = false
}

// static inline void tinu16() { fscanf(stdin, "%hu", &reg[R0]); }

tinu16 :: #force_inline proc () {
    libc.fscanf( libc.stdin, "%hu", &reg[ Regi.R0 ] )   // TODO Check the scanf function
}

// static inline void toutu16() { fprintf(stdout, "%hu\n", reg[R0]); }

toutu16 :: #force_inline proc () {
    fmt.fprintf(os.stdout, "%hu\n", reg[ Regi.R0 ] )
}

// trp_ex_f trp_ex[8] = { tgetc, tout, tputs, tin, tputsp, thalt, tinu16, toutu16 };

trp_ex : [ 8 ]trp_ex_f = { tgetc, tout, tputs, tin, tputsp, thalt, tinu16, toutu16 }

// static inline void trap(uint16_t i) { trp_ex[TRP(i)-trp_offset](); }

trap :: #force_inline proc ( i : u16 ) {
    trp_ex[ m_trp( i ) - u16( Trp_offset.value ) ]()
}

// op_ex_f op_ex[NOPS] = { /*0*/ br, add, ld, st, jsr, and, ldr, str, rti, not, ldi, sti, jmp, res, lea, trap };

op_ex : [ NUMBER_OPERATIONS ]op_ex_f = { /* 0 */ br, add, ld, st, jsr, and, ldr, str, rti, not, ldi, sti, jmp, res, lea, trap }

op_ex_names : [ NUMBER_OPERATIONS ]cstring = { "BR", "ADD", "LD", "ST", "JSR", "AND", "LDR", "STR", "RTI", "NOT", "LDI", "STI", "JMP", "RES", "LEA", "TRAP" }

// void start(uint16_t offset) { 
//     reg[RPC] = PC_START + offset;
//     while(running) {
//         uint16_t i = mr(reg[RPC]++);
//         op_ex[OPC(i)](i);
//     }
// }

start :: proc ( offset : u16 ) {
    reg[ Regi.RPC ] = PC_START + offset
    for running {
        // NOTE( jnc ): Modification of the original code to avoid the increment of the register in the same line.
        i : u16 = mr( reg[ Regi.RPC ] ) 
        reg[ Regi.RPC ] += 1

        // op_ex[ m_opc( i ) ]( i )
        
        operation_code : int = int( m_opc( i ) )

        fmt.print( "\n" )
        fprintf_reg_all( libc.stdout, & reg[ 0 ], 10 )
        fprintf_inst( libc.stdout, i )

        if operation_code < 0 && operation_code >= NUMBER_OPERATIONS {
            fmt.fprintf( os.stderr , "Invalid operation code: %d\n" , operation_code )
            os.exit( 1 )
        } 

        // Execute the operation, by calling the function in the op_ex array.
        op_ex[ operation_code ]( i )
    }
}

// void ld_img(char *fname, uint16_t offset) {
//     FILE *in = fopen(fname, "rb");
//     if (NULL==in) {
//         fprintf(stderr, "Cannot open file %s.\n", fname);
//         exit(1);    
//     }
//     uint16_t *p = mem + PC_START + offset;
//     fread(p, sizeof(uint16_t), (UINT16_MAX-PC_START), in);
//     fclose(in);
// }

ld_img :: proc ( fname : string , offset : u16 ) {
    in_file_buffer, ok := os.read_entire_file( fname )
    if !ok {
        fmt.fprintf( os.stderr , "Cannot open file %s.\n" , fname )
        os.exit( 1 )
    }

    for i : int = 0; i < ( len( in_file_buffer ) ); i = i + 2 {
        // TODO: Ver se é little Endian or big Endian.
        var_tmp : u16 = u16( in_file_buffer[ i ] ) |  ( u16( in_file_buffer[ i + 1 ] ) << 8 )
        mem[ int( PC_START + offset ) + i / 2 ] = var_tmp
    }
}

// int main(int argc, char **argv) {
//     ld_img(argv[1], 0x0);
//     fprintf(stdout, "Occupied memory after program load:\n");
//     fprintf_mem_nonzero(stdout, mem, UINT16_MAX);
//     start(0x0); // START PROGRAM
//     fprintf(stdout, "Occupied memory after program execution:\n");
//     fprintf_mem_nonzero(stdout, mem, UINT16_MAX);
//     fprintf(stdout, "Registers after program execution:\n");
//     fprintf_reg_all(stdout, reg, RCNT);
//     return 0;
// }

main :: proc ( ) {
    fmt.println("Begin LC3 Vitual Machine...\n" )

    if len( os.args ) < 2 {
        fmt.fprintf( os.stderr , "Usage: %s <filename.obj>\n" , os.args[0] )
        os.exit( 1 )
    }
    
    fmt.printfln( "Before print non zero memory before loading the image..." )
    fprintf_mem_nonzero( libc.stdout , & mem[ 0 ] , U16MAX )
    fmt.printfln( "After print non zero memory before loading the image..." )
    
    fmt.printfln( "\nLoading the image from %v", os.args[ 1 ] )
    
    ld_img( os.args[ 1 ] , 0x0 )
    fmt.fprintfln( os.stdout , "Occupied memory after program load:" )
    fprintf_mem_nonzero( libc.stdout , & mem[ 0 ] , U16MAX )


    fmt.printfln( "\n Start running the program..." )
    
    start( 0x0 ) // START PROGRAM

    fmt.printfln( "\n ..end running the program...\n" )

 
    fmt.fprintf( os.stdout , "Occupied memory after program execution:\n" )
    fprintf_mem_nonzero( libc.stdout , & mem[ 0 ] , U16MAX )
    fmt.fprintf( os.stdout , "Registers after program execution:\n" )
    fmt.print( "\n" )
    fprintf_reg_all( libc.stdout , & reg[ 0 ] , int( Regi.RCNT ) )

    fmt.println("\n... end LC3 Vitual Machine." )
}


