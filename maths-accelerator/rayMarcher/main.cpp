#define SDL_MAIN_HANDLED
#include <SDL2/SDL.h>
#include <cmath>
#include "rayMarcher.h"
#include <iostream>

constexpr float PI = 3.14159265f;

int main() {
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

    vec3 camera_pos(0, 0, -3);
    float fov = 90.0f;
    float aspect_ratio = static_cast<float>(width) / height;
    float scale = tan(fov * 0.5f * PI / 180.0f);

    bool running = true;
    SDL_Event event;
    uint32_t* pixels = new uint32_t[width * height];
    float uTime = 0.0f;

    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) running = false;
        }

        vec3 lightPosition(-10.0f * cosf(uTime), 10.0f, 10.0f * sinf(uTime));

        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                float px = (2.0f * (x + 0.5f) / width - 1.0f) * aspect_ratio * scale;
                float py = (1.0f - 2.0f * (y + 0.5f) / height) * scale;

                vec3 ray_dir(px, py, 1);
                ray_dir = ray_dir.normalise();

                float dist = raymarch(camera_pos, ray_dir);
                vec3 p = camera_pos.addition(ray_dir.scalarMul(dist));

                float brightness = 0.0f;
                if (dist < 100.0f) {
                    vec3 normal = calcNormal(p); 
                    vec3 lightDirection = lightPosition.addition(p.scalarMul(-1)).normalise();
                    float diffuseCoeff = std::max(dot(normal, lightDirection), 0.0f);
                    brightness = diffuseCoeff;
                }

                uint8_t colorValue = static_cast<uint8_t>(brightness * 255);
                pixels[y * width + x] = (colorValue << 16) | (colorValue << 8) | colorValue;
            }
        }

        SDL_UpdateTexture(texture, nullptr, pixels, width * sizeof(uint32_t));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, nullptr, nullptr);
        SDL_RenderPresent(renderer);

        uTime += 0.05f;
    }

    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}