import std.stdio;
import std.algorithm;
import std.string;
import std.math;
import InputHandler;
import GameObjects;
import TextureManager;
import Vector2D;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

import std.file;

class Game
{
private:
  static immutable fps = 60;
  static immutable delay_time = 1000.0 / fps;
  SDL_Window* _window;
  SDL_Renderer* _renderer;
  SDL_Texture* _pezi_tex;
  Player _pezi;
public:
  
  void Init()
  {
    SDL_Init(SDL_INIT_EVERYTHING);  
    _window = SDL_CreateWindow("Squirrelatron", SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,640,480,SDL_WINDOW_SHOWN);
    _renderer = SDL_CreateRenderer(_window,-1,0);
    InputHandler.InitializeJoysticks();
    TextureManager.Load("F:\\GIT\\Squirrelatron\\images\\ps_temp.jpg", "pezi", _renderer);    
    SDL_Rect source = TextureManager.GetRect("pezi");
    _pezi = new Player();
    _pezi.Load(0,0,source.w,source.h,"pezi");
    gameRunning = true;
  };
  
  void Render() {
    SDL_Rect source = TextureManager.GetRect("pezi");
    SDL_RenderClear(_renderer);
    _pezi.Draw(_renderer);
    SDL_RenderPresent(_renderer);
  };
  
  void Update() {
    _pezi.Update();
    auto frame = ((SDL_GetTicks() / 1000) % 6);
  };
  
  void HandleEvents()  {
    InputHandler.Update();
  };
  void Clean()  {
    InputHandler.Clean();
    SDL_DestroyWindow(_window);
    SDL_DestroyRenderer(_renderer);
    SDL_Quit();
  };

  @property bool running() { return gameRunning; }
}

void main() {
  DerelictSDL2.load();
  DerelictSDL2Image.load();
  auto game = new Game();
  uint frameStart, frameTime;
  game.Init();
  while(game.running)
  {
    frameStart = SDL_GetTicks();
    game.HandleEvents();
    game.Update();
    game.Render();
    frameTime = SDL_GetTicks() - frameStart;
    if( frameTime < Game.delay_time ){
      SDL_Delay(cast(int)Game.delay_time-frameTime);
    }
  }
  game.Clean();
}