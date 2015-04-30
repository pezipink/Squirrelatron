import derelict.sdl2.sdl;

import std.container;
import std.algorithm;
import std.algorithm;
import std.range;
import Workshop;
import GameObjects;
import Vector2D;

class Bullet : GameObject{
	private bool isPlayerBullet;

	override void Draw(SDL_Renderer* renderer) {
		auto v = _position + (_velocity*10);
		SDL_RenderDrawLine(renderer,cast(int)_position.X,cast(int)_position.Y,cast(int)v.X,cast(int)v.Y);
	}
}

class BulletManager
{
	private auto bulletShop = new ElfWorkshop!(Bullet,()=>new Bullet())(100);

	private auto bulletsInPlay =  SList!(Bullet)();

	void Update(){
		foreach(b; bulletsInPlay) {
			b.Update();

			}
		//auto r = bulletsInPlay.filter!(a=>true);		
		//bulletsInPlay.linearRemove(r);		
	}

	void Draw(SDL_Renderer* renderer){	
		SDL_SetRenderDrawColor(renderer,255,0,0,0);				
		foreach(b; bulletsInPlay) {
			b.Draw(renderer);
		}
		SDL_SetRenderDrawColor(renderer,0,0,0,0);				
	}

	void AddBullet(bool player, Vector2D position, Vector2D velocity) {
		auto b = bulletShop.Get();
		b.SetPosition(position);
		b.SetVelocity(velocity);
		auto x = b.Position;
		bulletsInPlay.insert(b);
	}
}
