#define SDL_MAIN_HANDLED
#include <SDL2/SDL.h>
#include <cmath>
#include "rayMarcher.h"
#include <iostream>

constexpr float PI = 3.14159265f;

int main() {
    //SETUP START
    const int width = 800;
    const int height = 600;
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL failed to initialize: " << SDL_GetError() << std::endl;
        return 1;
    }
    SDL_Window* window = SDL_CreateWindow("Raymarcher Sphere",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        width, height, SDL_WINDOW_SHOWN);
    if (!window) {
        std::cerr << "Failed to create window: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB888, SDL_TEXTUREACCESS_STREAMING, width, height);
    bool running = true;
    SDL_Event event;
    uint32_t* pixels = new uint32_t[width * height];
    float uTime = 0.0f;
    uint32_t lastTime = SDL_GetTicks();
    //SETUP FINISHED
    


    vec3 camera_pos(0, 0, -3);
    float fov = 90.0f; //This is the angle of the view cone (vertical FOV so from top to bottom of the pixel plane is 90 degrees)
    float aspect_ratio = static_cast<float>(width) / height;
    float scale = tan(fov * 0.5f * PI / 180.0f); //We place the pixel plane at z = 1 (this is relative to the camera), so we can calculate the scale (or half height of pixel plane) (Note: tan function takes in radians, not degrees)
    // O = tan(theta) * A, where O is the scale, theta is fov/2 is half the pixel plane height (fov/2) and A is a length of 1 
    // The object in the scene is centered at the origin


    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) running = false;
        }

        uint32_t currentTime = SDL_GetTicks();
        float deltaTime = (currentTime - lastTime) / 1000.0f; 
        lastTime = currentTime;
        uTime += deltaTime; //Timing stuff for the rotating light

        vec3 lightPosition(
            10.0f * sinf(uTime * 0.5f),
            //8.0f + 2.0f * sinf(uTime * 0.3f), 
            10.0f,
            10.0f * cosf(uTime * 0.5f)
        ); //Rotating light position

        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) { //Raster pattern
                //Image plane height: scale * 2
                //Image plane width: aspect_ratio * scale * 2 
                //(x + 0.5f) / width  => Maps the centre of the pixel to a range of [0,1] (Centre of a pixel is x+0.5)
                //2 * ... - 1   => Maps the pixels to a range of [-1, 1] (i.e leftmost pixel has value -1, and rightmost has value of 1)
                float px = (2.0f * ((x + 0.5f) / width) - 1.0f) * aspect_ratio * scale; //x direction vector of ray for this pixel
                float py = -(2.0f * ((y + 0.5f) / height) - 1.0f) * scale; //y direction vector of ray for this pixel
                //py is calculated in a similar way but the mapping of [-1, 1] needs to flipped as vertical pixel number increases as you go downwards the screen

                vec3 ray_dir(px, py, 1); //This ray goes 1 unit forward in the camera's local +z direction. px and py point the ray in the correct direction
                ray_dir = ray_dir.normalise(); //Normalise so that we can easily project it to certain distances

                float dist = raymarch(camera_pos, ray_dir); //Raymarch this certain ray 
                vec3 p = camera_pos.addition(ray_dir.scalarMul(dist)); //p is the position of the ray after it is done ray marching. p = a + lambda * d 

                float brightness = 0.0f;
                if (dist < 100.0f) { //If ray hit an object, calculate how lit up that object surface point is
                    vec3 normal = calcNormal(p); //Calculate normal vector of the surface at point p 
                    vec3 lightDirection = lightPosition.addition(p.scalarMul(-1)).normalise(); //Calculate normalised light direction vector at point p
                    float diffuseCoeff = std::max(dot(normal, lightDirection), 0.0f); //Dot product both vectors to get the coeff that determines how "lit up" that point is. Read the blog to see how this works
                    brightness = diffuseCoeff; //DiffuseCoeff can take any value between 0 and 1
                }
                //If it didn't hit an object, then the brightness of that ray/pixel is 0

                uint8_t colorValue = static_cast<uint8_t>(brightness * 255); //Convert brightness(0-1) into grayscale(0-255)  
                pixels[y * width + x] = (colorValue << 16) | (colorValue << 8) | colorValue; //Colour in pixels (I don't know how this works)
            }
        }


        //DRAW FRAME
        SDL_UpdateTexture(texture, nullptr, pixels, width * sizeof(uint32_t));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);
    }
    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}