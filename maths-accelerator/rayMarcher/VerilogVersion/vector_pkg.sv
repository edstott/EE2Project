package vector_pkg;

  `include "common_defs.svh";

  typedef logic signed [`WORD_WIDTH-1:0] fp;
  typedef struct packed {
      fp x;
      fp y;
      fp z;
  } vec3;

  // parameterize your element width
  parameter DATA_WIDTH = 32;
  typedef logic signed [DATA_WIDTH-1:0] num;

  // normal fixed point arithmetic

  function automatic fp fp_add(input fp a, input fp b);
    return a+b;
  endfunction

  function automatic fp fp_add3(input fp a, input fp b, input fp c);
    return a+b+c;
  endfunction

  function automatic fp fp_mul(input fp a, input fp b);
    logic signed [63:0] result;
    result = $signed(a) * $signed(b);
    result = result >>> `FRAC_BITS;
    return result[31:0];
  endfunction

  // vector arithmetic

  function automatic vec3 make_vec3(input num x, input num y, input num z);
    make_vec3.x = x;
    make_vec3.y = y;
    make_vec3.z = z;
  endfunction
  // vector addition
  function automatic vec3 vec3_add(vec3 a, vec3 b);
    vec3_add.x = a.x + b.x;
    vec3_add.y = a.y + b.y;
    vec3_add.z = a.z + b.z;
  endfunction

  //vector subtraction
  function automatic vec3 vec3_sub(input vec3 a, input vec3 b);
    vec3_sub.x = a.x - b.x;
    vec3_sub.y = a.y - b.y;
    vec3_sub.z = a.z - b.z;
  endfunction

  //vector negation (2's complement)
  function automatic vec3 vec3_neg(input vec3 a);
    vec3_neg.x = ~a.x + 1;
    vec3_neg.y = ~a.y + 1;
    vec3_neg.z = ~a.z + 1;
  endfunction

  function automatic fp vec3_dot(input vec3 a, input vec3 b);
    fp xr = fp_mul(a.x, b.x);
    fp yr = fp_mul(a.y, b,y);
    fp zr = fp_mul(a.z, b,z);
    fp sum = fp_add(xr, fp_add(yr,zr));
  endfunction

  function automatic vec3 vec3_cross(input vec3 a, input vec3 b);
    vec3_cross.x = fp_mul(a.y, b.z) - fp_mul(a.z,b.y);
    vec3_cross.y = fp_mul(a.z, b.x) - fp_mul(a.x, b.z);
    vec3_cross.z = fp_mul(a.x, b.y) - fp_mul(a.y, b.x);
  endfunction

  // scalar multiply
  function automatic vec3 vec3_scale(vec3 a, logic signed [DATA_WIDTH-1:0] s);
    vec3_scale.x = (a.x * s) >>> FRAC_BITS; // if fixed-point you shift down by FRACT bits
    vec3_scale.y = (a.y * s) >>> FRAC_BITS;
    vec3_scale.z = (a.z * s) >>> FRAC_BITS;
  endfunction

  

endpackage : vector_pkg
