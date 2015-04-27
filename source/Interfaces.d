import derelict.sdl2.sdl;

interface IGameEntity {
	void Draw(SDL_Renderer* rednerer);
	void Update();
}

