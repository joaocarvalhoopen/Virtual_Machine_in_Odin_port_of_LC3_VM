
package prog_01

import "core:fmt"
import "core:c/libc"
import "core:c"

/* Ask for 2 values from 0 to 15 and add them, the ouput is in register R0 */

program := [ ? ]u16{

    /*mem[0x3000]=*/    0xF026,    //  1111 0000 0010 0110             TRAP trp_in_u16  ;read an uint16_t from stdin and put it in R0
    /*mem[0x3002]=*/    0x1220,    //  0001 0010 0010 0000             ADD R1,R0,x0     ;add contents of R0 to R1
    /*mem[0x3003]=*/    0xF026,    //  1111 0000 0010 0110             TRAP trp_in_u16  ;read an uint16_t from stdin and put it in R0
    /*mem[0x3004]=*/    0x1240,    //  0001 0010 0100 0000             ADD R1,R1,R0     ;add contents of R0 to R1
    /*mem[0x3006]=*/    0x1060,    //  0001 0000 0110 0000             ADD R0,R1,x0     ;add contents of R1 to R0
    /*mem[0x3007]=*/    0xF027,    //  1111 0000 0010 0111             TRAP trp_out_u16;show the contents of R0 to stdout
    /*mem[0x3006]=*/    0xF025,    //  1111 0000 0010 0101             HALT             ;halt

}

// int main(int argc, char** argv) {
//     char *outf = "sum.obj";
//     FILE *f = fopen(outf, "wb");
//     if (NULL==f) {
//         fprintf(stderr, "Cannot write to file %s\n", outf);
//     }
//     size_t writ = fwrite(program, sizeof(uint16_t), sizeof(program), f);
//     fprintf(stdout, "Written size_t=%lu to file %s\n", writ, outf);
//     fclose(f);
//     return 0;
// }


main :: proc ( ) {
    outf : cstring = "sum_program.obj"
    f : ^libc.FILE = libc.fopen( outf, "wb" )
    if f == nil {
        libc.fprintf( libc.stderr, "Cannot write to file %s\n", outf )
    }
    writ : uint = libc.fwrite( &program[ 0 ], size_of( u16 ), size_of( program ) / 2, f )
    libc.fprintf( libc.stdout, "Written size_t=%lu to file %s\n", writ, outf )
    libc.fclose( f )
}
