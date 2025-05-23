#include "rayMarcher.h"
#include <cmath>
using namespace std;

#define MAX_STEPS 100
#define MAX_DIST 100.0f
#define SURFACE_DIST 0.01f
constexpr float PI = 3.14159265f;

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
float vec2::length() const {
    return sqrt(x*x + y*y);
}
vec3 vec3::normalise() const {
    float len = length();
    return vec3(x/len, y/len, z/len);
}
vec3 vec3::abs() const{
    return vec3(std::fabs(x), std::fabs(y), std::fabs(z));
}
vec2 vec2::abs() const{
    return vec2(std::fabs(x), std::fabs(y));
}

float sdfSphere(vec3 p, float s) {
    return p.length() - s;
}

float sdfTorus(vec3 p, vec2 t) //t.x is the major radius and t.y is the minor radius
{
    float angle = PI * 0.5f;
    float cosA = cos(angle);
    float sinA = sin(angle);
    float y = p.y * cosA - p.z * sinA;
    float z = p.y * sinA + p.z * cosA;
    p.y = y;
    p.z = z;

    vec2 pXZ(p.x, p.z);
    vec2 q = vec2(pXZ.length()-t.x, p.y);
    return q.length() - t.y;
}


float sdfRoundedCube(vec3 p, vec3 b, float e){
    p = p.abs();
    vec3 q = p.subtraction(b);
    vec3 d = vec3(
        std::max(q.x, 0.0f),
        std::max(q.y, 0.0f),
        std::max(q.z, 0.0f)
    );
    float outsideDist = d.length();

    float insideDist = std::min(std::max(q.x, std::max(q.y, q.z)), 0.0f);
    float distance = outsideDist + insideDist;

    return distance - e;
}

float sdfBoxFrame(vec3 p, vec3 b, float e)
{
    p = p.abs().subtraction(b);
    vec3 q = p.addition(vec3(e, e, e)).abs().subtraction(vec3(e, e, e));
    float d1 = vec3(std::max(p.x, 0.0f), std::max(q.y, 0.0f), std::max(q.z, 0.0f)).length() +
               std::min(std::max(p.x, std::max(q.y, q.z)), 0.0f);
    float d2 = vec3(std::max(q.x, 0.0f), std::max(p.y, 0.0f), std::max(q.z, 0.0f)).length() +
               std::min(std::max(q.x, std::max(p.y, q.z)), 0.0f);
    float d3 = vec3(std::max(q.x, 0.0f), std::max(q.y, 0.0f), std::max(p.z, 0.0f)).length() +
               std::min(std::max(q.x, std::max(q.y, p.z)), 0.0f);
    return std::min(std::min(d1, d2), d3);
}

float scene(vec3 p) {
    //return sdfSphere(p, 1.0f);

    //vec2 torusDimensions(1.5f, 0.5f);
    //return sdfTorus(p, torusDimensions);

    // vec3 squareDimensions(1.0f, 1.0f, 1.0f);
    // float roundedCoeff = 0.1f;
    // return sdfRoundedCube(p, squareDimensions, roundedCoeff);

    vec3 boxFrameDimensions(1.0f, 1.0f, 1.0f);
    float barThickness = 0.1f;
    return sdfBoxFrame(p, boxFrameDimensions, barThickness);
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

