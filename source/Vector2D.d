import std.stdio;
import std.math;
import InputHandler;
class Vector2D
{ 
private:
  double _x;
  double _y;

public:
  this(double x, double y) 
  {
    _x = x;
    _y = y;
  }

  @property double X() { return _x; }
  @property double X(double x) { return _x=x; }

  @property double Y() { return _y; }
  @property double Y(double y) { return _y=y; }

  @property length() { return sqrt(_x * _x + _y * _y); }

  //void Normalize()
  //{
  //    if(length>0)
  //    {
  //      (this) *=1 / length;
  //    }
  //}

  Vector2D opBinary(string op)(Vector2D rhs) if (op == "+" || op == "-") {    
    return mixin("new Vector2D(_x"~op~"rhs.X,_y"~op~"rhs.Y)");
  }

  void  opOpAssign(string op)(double rhs) if (op == "*" || op == "/") {    
    mixin("_x"~op~"=rhs;");
    mixin("_y"~op~"=rhs;");
  }

  void opOpAssign(string op)(Vector2D rhs) if (op == "+" || op == "-") {    
    mixin("_x"~op~"=rhs.X;");
    mixin("_y"~op~"=rhs.Y;");
  }

  Vector2D opBinary(string op)(double rhs) if (op == "*" || op == "/") {
    return mixin("new Vector2D(_x"~op~"rhs,_y"~op~"rhs)");
  }

  @property Vector2D dup() { return new Vector2D(_x,_y); }
}

unittest{
  auto v = new Vector2D(5.0,5.0);
  auto v2 = new Vector2D(10.0,10.0);


  auto add = v + v2;
  assert(add.X==15.0 && add.Y==15.0);
  auto mul = v * 5.0;
  assert(mul.X==25.0 && mul.Y==25.0);

  v *= 5.0;
  assert(v.X==25.0 && v.Y==25.0);
  
  v2 += new Vector2D(1,1);
  assert(v2.X == 11 && v2.Y == 11);


}