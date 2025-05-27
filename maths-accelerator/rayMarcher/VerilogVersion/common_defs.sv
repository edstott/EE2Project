package common_defs;

`define INT_BITS    8
`define FRAC_BITS   24
`define WORD_WIDTH   (`INT_BITS+`FRAC_BITS)

`define SCREEN_WIDTH    640
`define SCREEN_HEIGHT   480

typedef logic signed [`WORD_WIDTH-1:0] fp;
typedef struct packed {
    fp x;
    fp y;
    fp z;
} vec3;

endpackage