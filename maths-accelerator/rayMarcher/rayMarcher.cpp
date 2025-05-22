#include "rayMarcher.h"
#include <cmath>

#define MAX_STEPS 100
#define MAX_DIST 100.0f
#define SURFACE_DIST 0.01f

vec3::vec3(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}

vec3 vec3::addition(const vec3& other) const {
    return vec3(x + other.x, y + other.y, z + other.z);
}
vec3 vec3::scalarMul(float mul) const {
    return vec3(x * mul, y * mul, z * mul);
}
float vec3::length() const {
    return sqrt(x*x + y*y + z*z);
}
vec3 vec3::normalize() const {
    float len = length();
    return vec3(x/len, y/len, z/len);
}

float sdSphere(vec3 p, float s) {
    return p.length() - s;
}

float scene(vec3 p) {
    return sdSphere(p, 1.0f);
}

float raymarch(vec3 ro, vec3 rd) {
    float rayDist = 0.0f;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro.addition(rd.scalarMul(rayDist));
        float dS = scene(p);
        rayDist += dS;
        if(rayDist > MAX_DIST || dS < SURFACE_DIST) break;
    }
    return rayDist;
}