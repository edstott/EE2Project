#include "rayMarcher.h"
#include <cmath>

#define MAX_STEPS 100
#define MAX_DIST 100.0f
#define SURFACE_DIST 0.01f

vec3::vec3(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}
vec2::vec2(float x_, float y_) : x(x_), y(y_) {}

vec3 vec2::xyy() const {
    return vec3(x, y, y);
}

vec3 vec2::yxy() const {
    return vec3(y, x, y);
}

vec3 vec2::yyx() const {
    return vec3(y, y, x);
}

vec3 vec3::addition(const vec3& other) const {
    return vec3(x + other.x, y + other.y, z + other.z);
}
vec3 vec3::subtraction(const vec3& other) const {
    return vec3(x - other.x, y - other.y, z - other.z);
}
vec3 vec3::scalarMul(float mul) const {
    return vec3(x * mul, y * mul, z * mul);
}
float vec3::length() const {
    return sqrt(x*x + y*y + z*z);
}
vec3 vec3::normalise() const {
    float len = length();
    return vec3(x/len, y/len, z/len);
}

float sdSphere(vec3 p, float s) {
    return p.length() - s;
}

float sdfTorus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdfBoxFrame(vec3 p, vec3 b, float e) 
{
    p = abs(p  )-b;
    vec3 q = abs(p+e)-e;
    return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float scene(vec3 p) {
    return sdfSphere(p, 1.0f);
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

vec3 calcNormal(vec3 p) 
{
    const float eps = 0.001; 
    const vec2 h = vec2(eps,0);
    vec3 normalVector(scene(p.addition(h.xyy())) - scene(p.subtraction(h.xyy())), //See blog explanation here: https://iquilezles.org/articles/normalsSDF/
                    scene(p.addition(h.yxy())) - scene(p.subtraction(h.yxy())),
                    scene(p.addition(h.yyx())) - scene(p.subtraction(h.yyx())));
    return normalVector.normalise();
}

float dot(vec3 v1, vec3 v2){
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

