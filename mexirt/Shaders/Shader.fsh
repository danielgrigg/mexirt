//
//  Shader.fsh
//  mexirt
//
//  Created by Daniel Grigg on 6/04/13.
//  Copyright (c) 2013 Daniel Grigg. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
  //gl_FragColor = colorVarying;
  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
