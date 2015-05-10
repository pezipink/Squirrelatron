import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.algorithm;
import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import std.random;
import BackgroundEffects;
import GameObjects;
import InputHandler;
import TextureManager;
import Vector2D;
import Invaders;

immutable auto RGB_Yellow = SDL_Color(255, 255, 0, 0);

static this(){

}

class Game
{
private:
  static immutable int fps = 60;
  static immutable float delay_time = 1000.0 / fps;
  static immutable screen_width = 640;
  static immutable screen_height = 480;
  SDL_Window* _window;
  SDL_Renderer* _renderer;
  SDL_Texture* _pezi_tex;
  SDL_Surface* _scr;
  SDL_Texture* _scrTex;
  Player _pezi;
  CircularStarField _stars;
  Plasma _plasma;
  RawPlasma _rplasma;
  Tunnel _tunnel;
  string[max_invaders] _invadersMap;
  int _currentInvader = 0;
  Invader[30] _invaders; 
public:
  void Init()
  {
    
    SDL_Init(SDL_INIT_EVERYTHING);  
    _window = SDL_CreateWindow("Squirrelatron", SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED,640,480,SDL_WINDOW_SHOWN);
    SDL_SetWindowFullscreen(_window,SDL_WINDOW_FULLSCREEN);
    _renderer = SDL_CreateRenderer(_window,-1,0);
    InputHandler.InitializeJoysticks();
    TextureManager.Load(buildPath(getcwd(), "..\\images\\ps.png"), "pezi", _renderer);    
    TextureManager.Load(GetInvaderTexture(_renderer),  "invaders");    
    _scr = SDL_CreateRGBSurface(0, 640, 480, 32,
                                        0x00FF0000,
                                        0x0000FF00,
                                        0x000000FF,
                                        0xFF000000);
    _scrTex = SDL_CreateTexture(_renderer,
                                            SDL_PIXELFORMAT_ARGB8888,
                                            SDL_TEXTUREACCESS_STREAMING,
                                            640, 480);
    SDL_Rect source = TextureManager.GetRect("pezi");
    _pezi = new Player();
    _pezi.Load(0,0,32,26,0.0,"pezi");
    _stars = new CircularStarField(&_pezi);
    _plasma = new Plasma();
    _rplasma = new RawPlasma(&pset);
    _tunnel  = new Tunnel(&pset);

    for(int i =0; i <30; i++){
        _invaders[i] = new Invader(uniform(1,5),uniform(0,max_invaders));
        _invaders[i].Load(uniform(0,640),0,invader_full_width,invader_height,uniform(0.0,359.0),"invaders");
        _invaders[i].SetVelocity(new Vector2D(0.0,uniform(0.5,2.5)));
        _invaders[i].SetScale(4.0);
    }

    gameRunning = true;
   // std.stdio.writeln(invaders.length);
  };
  
void pset(int x, int y, const SDL_Color color)
{
  if(x < 0 || y < 0 || x >= screen_width || y >= screen_height) return;
  uint colorSDL = SDL_MapRGB(_scr.format, color.r, color.g, color.b);
  uint* bufp;
  bufp = cast(uint*)_scr.pixels + y * _scr.pitch / 4 + x;
  *bufp = colorSDL;
}

void Render(){

  //for(int x=0; x<screen_width; x++) {
  //  pset(x,50,RGB_Yellow);
  //}

  //_rplasma.Draw();
  _tunnel.Draw();
  SDL_UpdateTexture(_scrTex, null, _scr.pixels, _scr.pitch);
  SDL_RenderClear(_renderer);
  SDL_RenderCopy(_renderer, _scrTex, null, null);
  //_plasma.Draw(_renderer);
  SDL_RenderPresent(_renderer);
}

  //void Render() {
  //  //SDL_Rect source = TextureManager.GetRect("pezi");
  //  //SDL_RenderClear(_renderer);
  //  //_stars.Draw(_renderer);


  //  for(int x=0; x>screen_width; x++) {
  //  }

  //  //_pezi.Draw(_renderer);
  //  //foreach(i;_invaders) i.Draw(_renderer);
  //  //for(int row = 0; row <480/invader_height; row++ ){
  //  //  for(int col = 0; col < 640/invader_full_width; col++ ){
  //  //    int v = (row * (640/invader_full_width)) + col;
  //  //    //writeln(row, " " , col, " " ,v);
  //  //    int x = col * invader_full_width;
  //  //    int y = row * invader_height;
  //  //    TextureManager.Draw(invaders[v],x,y,invader_full_width,invader_height,0.0,_renderer,SDL_FLIP_NONE);
  //  //  }
  //  //}
  //  //TextureManager.Draw(invaders[_currentInvader],10,10,invader_full_width,invader_height,0.0,_renderer,SDL_FLIP_NONE,5.0);
  //  //SDL_RenderPresent(_renderer);
  //};
  
  void Update() {
    //if( Direction.TurretRight.testDirection){
    //  _currentInvader = MIN(_currentInvader+1,max_invaders);
    //}else if( Direction.TurretLeft.testDirection){
    //  _currentInvader = MAX(_currentInvader-1,0);
    //}
    _rplasma.Update();
    _pezi.Update();    
    _stars.Update();
    //_plasma.Update();
    foreach(i;_invaders) { 
      i.Update();
      if( i.Position.Y > 480) {
        i.SetInvaderIndex(uniform(0,max_invaders));
        i.Load(uniform(0,640),0,invader_full_width,invader_height,uniform(0.0,359.0),"invaders");
        i.SetScale(uniform(1.0,8.0));
      }
    }
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