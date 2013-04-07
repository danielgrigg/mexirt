precision mediump float;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 projectionMatrix;
uniform mat4 inverseProjectionMatrix;
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

void main()
{
  Transform camera_to_ndc = Transform(projectionMatrix, inverseProjectionMatrix);

  Ray myRay = camera_ray(ndc_position, camera_to_ndc);

  gl_FragColor = debug_vector(myRay._direction.xy);
  //  gl_FragColor = debug_color();
}
