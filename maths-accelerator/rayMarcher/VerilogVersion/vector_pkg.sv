package vector_pkg;

  // parameterize your element width
  parameter DATA_WIDTH = 32;
  parameter FRACT = 16;
  typedef logic signed [DATA_WIDTH-1:0] num;

  // signed fixed-point 3-vector
  typedef struct packed {
    logic signed [DATA_WIDTH-1:0] x;
    logic signed [DATA_WIDTH-1:0] y;
    logic signed [DATA_WIDTH-1:0] z;
  } vec3;

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

  function automatic logic signed [DATA_WIDTH-1:0] vec3_dot(input vec3 a, input vec3 b);
    logic signed [2*DATA_WIDTH-1:0] xr, yr, zr, sum;
    xr = $signed(a.x) * $signed(b.x);
    yr = $signed(a.y) * $signed(b.y);
    zr = $signed(a.z) * $signed(b.z);
    vec3_dot = (xr >>> FRACT) + (yr >>>FRACT) + (zr >>> FRACT);
  endfunction

  // scalar multiply
  // function automatic vec3 vec3_scale(vec3 a, logic signed [DATA_WIDTH-1:0] s);
  //   vec3_scale.x = (a.x * s) >>> FRACT; // if fixed-point you shift down by FRACT bits
  //   vec3_scale.y = (a.y * s) >>> FRACT;
  //   vec3_scale.z = (a.z * s) >>> FRACT;
  // endfunction

endpackage : vector_pkg
