package virtual_machine

import "core:c/libc"

// DEBUG
// void fprintf_binary(FILE *f, uint16_t num) {
//     int c = 16;
//     while(c-->0) {
//         if ((c+1)%4==0) {
//             fprintf(f, " ");
//         }
//         fprintf(f, "%d", (num>>c)&1);
//     }
// }

fprintf_binary :: proc ( f : ^libc.FILE, num : u16 ) {
    c : uint = 16;
    for c > 0 {
        c -= 1
        if ( c + 1 ) % 4 == 0 {
            libc.fprintf( f, " " )
        }
        libc.fprintf( f, "%d", ( num >> c ) & 1 )
    }
}

// void fprintf_inst(FILE *f, uint16_t instr) {
//     fprintf(f, "instr=%u, binary=", instr);
//     fprintf_binary(f, instr);
//     fprintf(f, "\n");
// }

instr_counter : int = 0

fprintf_inst :: proc ( f : ^libc.FILE, instr : u16) {
    libc.fprintf( f, " %d  instr=%u, %s,  binary=", instr_counter, instr, op_ex_names[ m_opc( instr ) ] )
    fprintf_binary( f, instr )
    libc.fprintf( f, "\n" )
    instr_counter += 1
}

// void fprintf_mem(FILE *f, uint16_t *mem, uint16_t from, uint16_t to) {
//     for(int i = from; i < to; i++) {
//         fprintf(f, "mem[%d|0x%.04x]=", i, i);
//         fprintf_binary(f, mem[i]);
//         fprintf(f, "\n");
//     }
// }

fprintf_mem :: proc ( f : ^libc.FILE, mem : [ ^ ]u16, from : u16, to : u16 ) {
    for i : int = int( from ); i < int( to ); i += 1 {
        libc.fprintf( f, "mem[%d|0x%.04x]=", i, i )
        fprintf_binary( f, mem[ i ] )
        libc.fprintf( f, "\n" )
    }
}

// void fprintf_mem_nonzero(FILE *f, uint16_t *mem, uint32_t stop) {
//     for(int i = 0; i < stop; i++) {
//         if (mem[i]!=0) {
//             fprintf(f, "mem[%d|0x%.04x]=", i, i);
//             fprintf_binary(f, mem[i]);
//             fprintf(f, "\n"); 
//         }
//     }
// }

fprintf_mem_nonzero :: proc ( f : ^libc.FILE, mem : [ ^ ]u16, stop : u16 ) {
    for i : int = 0; i < int( stop ); i += 1 {
        if mem[ i ] != 0 {
            libc.fprintf( f, "mem[%d|0x%.04x]=", i, i )
            fprintf_binary( f, mem[ i ] )
            libc.fprintf( f, "\n" ) 
        }
    }
}

// void fprintf_reg(FILE *f, uint16_t *reg, int idx) {
//     fprintf(stdout, "reg[%d]=0x%.04x\n", idx, reg[idx]);
// }

fprintf_reg :: proc ( f : ^libc.FILE, reg : [ ^ ]u16, idx : int ) {
    libc.fprintf( libc.stdout, "reg[%d]=0x%.04x  %s \n", idx, reg[ idx ], reg_name[ idx ] )
}

// void fprintf_reg_all(FILE *f, uint16_t *reg, int size) {
//     for(int i = 0; i < size; i++) {
//         fprintf_reg(f, reg, i);
//     }
// }

fprintf_reg_all :: proc ( f : ^libc.FILE, reg : [ ^ ]u16, size : int ) {
    for i : int = 0; i < size; i += 1 {
        fprintf_reg( f, reg, i )
    }
}