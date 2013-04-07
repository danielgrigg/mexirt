precision mediump float;

const float kEpsilon = 3.0e-5;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 projectionMatrix;
uniform mat4 inverseProjectionMatrix;
uniform float time;
varying vec2 ndc_position;


vec3 expand(vec3 v) { return 0.5 * v + vec3(0.5); }
vec4 expand(vec4 v) { return 0.5 * v + vec4(0.5); }

// Encapsulate a forward & reverse transformation matrix
struct Transform {
  mat4 _forward;
  mat4 _inverse;
};

// Return the inverse transform of T.
Transform inverse(Transform T) {
  return Transform(T._inverse, T._forward);
}

struct Ray {
  vec3 _origin;
  vec3 _direction;
};

vec3 ray_at(Ray ray, float t) {
  return ray._origin + t * ray._direction;
}

// Generate a camera-space ray from a position in NDC.
Ray camera_ray(vec2 ndc_position, Transform camera_to_ndc) {
  return Ray(vec3(0.0),
	     vec3(inverse(camera_to_ndc)._forward * vec4(ndc_position, -1.0, 1.0)));
} 

// Convert a vec3 to an opaque color
vec4 color(vec3 v) { return vec4(v, 1.0); }
vec4 debug_color() { return vec4(1.0, 0.0, 0.0, 1.0); }
vec4 debug_vector(vec3 v) { return color(expand(v)); }
vec4 debug_vector(vec2 v) { return color(expand(vec3(v, 0.0))); }

struct Sphere {
  vec3 _centre;
  float _radius;
};

bool intersects(Ray ray, Sphere sphere)
{
  float a = dot(ray._direction, ray._direction);
  vec3 l = ray._origin - sphere._centre;
  float b = 2.0 * dot(ray._direction, l); 
  float c = dot(l,l) - sphere._radius * sphere._radius;
  float discriminant = b*b - 4.0 * a * c;

  return discriminant > kEpsilon;
} 

struct Plane {
  vec3 _position;
  vec3 _normal;
};

float trace(Ray r, Plane p) {
  float rn = dot(r._direction, p._normal);
  if (abs(rn) > kEpsilon) {
    float t = dot(p._position - r._origin, p._normal) / rn;
    return t;
  }
  return 0.0;
}

vec4 shade_checker(vec3 pos) {
  float x = step(2.0, mod(pos.x, 4.0));
  float y = step(2.0, mod(pos.z, 4.0));
  return mix(vec4(1.0, 0.5, 0.5, 1.0), 
	     vec4(0.5, 0.5, 1.0, 1.0), 
	     abs(x - y));
}

// Fog out the horrid checker aliasing
vec4 fog(vec4 color, float t, float t_min, float t_max) {
  if (t < t_min) return color;
  return mix(color, vec4(0.75, 0.9, 0.85, 1.0), 
	     min((t - t_min) / (t_max - t_min), 1.0));
}

vec4 trace_scene(Ray ray, Sphere s)
{ 
  if (intersects(ray, s)) {
    return vec4(1.0);
  }

  Plane ground = Plane(vec3(0.0, -5.0, 0.0), vec3(0.0, 1.0, 0.0));
  float plane_t = trace(ray, ground);
  if (plane_t > kEpsilon) {
    vec3 ground_pos = ray_at(ray, plane_t);
    
    return fog(shade_checker(ground_pos), plane_t, 10.0, 200.0);
  }
   
  return vec4(0.0, 0.0, 0.0, 1.0);
}

void main()
{
  Transform camera_to_ndc = Transform(projectionMatrix, inverseProjectionMatrix);

  Ray trace_ray = camera_ray(ndc_position, camera_to_ndc);

  Sphere s = Sphere(vec3(cos(time), sin(time), -10.0), 1.0);

  gl_FragColor = trace_scene(trace_ray, s);

    //gl_FragColor = debug_vector(myRay._direction.xy);
  //  gl_FragColor = debug_color();
}
