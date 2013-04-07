attribute vec4 position;
varying lowp vec2 ndc_position;

void main()
{
  ndc_position = vec2(position);
  gl_Position = position;
}
