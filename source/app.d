import std.stdio;
// This example shows how to import all of the DerelictSDL2 bindings. Of course,
// you only need to import the modules that correspond to the libraries you
// actually need to load.
import derelict.sdl2.sdl;
import derelict.sdl2.image;
//import derelict.sdl2.mixer;
//import derelict.sdl2.ttf;
//import derelict.sdl2.net;

void main() {
    // This example shows how to load all of the SDL2 libraries. You only need
    // to call the load methods for those libraries you actually need to load.

    // Load the SDL 2 library.
    DerelictSDL2.load();

    if( SDL_Init(SDL_INIT_EVERYTHING)>=0)
    {
printf("is good");

    }    

    auto window = SDL_CreateWindow("Squirreltron", SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,640,480,SDL_WINDOW_SHOWN);

    auto renderer = SDL_CreateRenderer(window,-1,0);
//    DerelictSDL2Image.load();
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    //// Load the SDL2_mixer library.
    //DerelictSDL2Mixer.load();

    //// Load the SDL2_ttf library
    //DerelictSDL2ttf.load();

    //// Load the SDL2_net library.
    //DerelictSDL2Net.load();

    // Now pSDL 2 functions for all of the SDL2 libraries can be called.
    //...

   // clear the window to black 
   SDL_RenderClear(renderer);
   // show the window
    SDL_RenderPresent(renderer);
   // set a delay before quitting 
   SDL_Delay(5000);
   // clean up SDL
   SDL_Quit(); 
    printf("hhjhdfheuiosfhiodj");

}