import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.algorithm;
import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import BackgroundEffects;
import GameObjects;
import InputHandler;
import TextureManager;
import Vector2D;


class Game
{
private:
  static immutable fps = 60;
  static immutable delay_time = 1000.0 / fps;
  SDL_Window* _window;
  SDL_Renderer* _renderer;
  SDL_Texture* _pezi_tex;
  Player _pezi;
  CircularStarField _stars;
  PlasmaFractal _plasma;
public:
  
  void Init()
  {
    SDL_Init(SDL_INIT_EVERYTHING);  
    _window = SDL_CreateWindow("Squirrelatron", SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,640,480,SDL_WINDOW_SHOWN);
    //SDL_SetWindowFullscreen(_window,SDL_WINDOW_FULLSCREEN);
    _renderer = SDL_CreateRenderer(_window,-1,0);
    InputHandler.InitializeJoysticks();
    TextureManager.Load(buildPath(getcwd(), "..\\images\\ps.png"), "pezi", _renderer);    
    SDL_Rect source = TextureManager.GetRect("pezi");
    _pezi = new Player();
    _pezi.Load(0,0,32,26,"pezi");
    _stars = new CircularStarField(&_pezi);
    _plasma = new PlasmaFractal(4);
    gameRunning = true;
  };
  
  void Render() {
    SDL_Rect source = TextureManager.GetRect("pezi");
    SDL_RenderClear(_renderer);
    _stars.Draw(_renderer);
    //_plasma.Draw(_renderer);
    _pezi.Draw(_renderer);
    
    SDL_RenderPresent(_renderer);
  };
  
  void Update() {
    _pezi.Update();    
    _stars.Update();
    //auto frame = ((SDL_GetTicks() / 1000) % 6);
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
    //writeln(SDL_GetTicks());
    //writeln(frameStart);
    if( frameTime < Game.delay_time ){
      //writeln(Game.delay_time-frameTime);
      SDL_Delay(cast(int)Game.delay_time-frameTime);
    }
  }
  game.Clean();
}