#ifndef RAYMARCHER_H
#define RAYMARCHER_H

class vec3 {
public:
    float x, y, z;
    vec3(float x_, float y_, float z_);
    vec3 addition(const vec3& other) const;
    vec3 subtraction(const vec3& other) const;
    vec3 scalarMul(float mul) const;
    float length() const;
    vec3 normalise() const;
    vec3 abs() const;
};

class vec2 {
public:
    float x, y;
    vec2(float x_, float y_);
    vec2 addition(const vec2& other) const;
    vec2 subtraction(const vec3& other) const;
    vec2 scalarMul(float mul) const;
    float length() const;
    vec2 normalize() const;
    vec3 xyy() const;
    vec3 yxy() const;
    vec3 yyx() const;
    vec2 abs() const;
};

float sdfSphere(vec3 p, float s);
float sdfTorus(vec3 p, vec2 dimensions);
float sdfBoxFrame(vec3 p, vec3 halfDimensions, float thickness);
float scene(vec3 p);
float raymarch(vec3 ro, vec3 rd);
float dot(vec3 v1, vec3 v2);
vec3 calcNormal(vec3 p); 
extern float uTime;

#endif 