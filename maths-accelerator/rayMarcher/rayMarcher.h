#ifndef RAYMARCHER_H
#define RAYMARCHER_H

class vec3 {
public:
    float x, y, z;
    vec3(float x_, float y_, float z_);
    vec3 addition(const vec3& other) const;
    vec3 scalarMul(float mul) const;
    float length() const;
    vec3 normalize() const;
};

float sdSphere(vec3 p, float s);
float scene(vec3 p);
float raymarch(vec3 ro, vec3 rd);

#endif // RAYMARCHER_H