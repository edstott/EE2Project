package vector_pkg;

  // parameterize your element width
  parameter DATA_WIDTH = 32;

  // signed fixed-point 3-vector
  typedef struct packed {
    logic signed [DATA_WIDTH-1:0] x;
    logic signed [DATA_WIDTH-1:0] y;
    logic signed [DATA_WIDTH-1:0] z;
  } vec3;

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

  // scalar multiply
  function automatic vec3 vec3_scale(vec3 a, logic signed [DATA_WIDTH-1:0] s);
    vec3_scale.x = (a.x * s) >>> FRACT; // if fixed-point you shift down by FRACT bits
    vec3_scale.y = (a.y * s) >>> FRACT;
    vec3_scale.z = (a.z * s) >>> FRACT;
  endfunction

endpackage : vector_pkg
