#version 450

uniform vec3 col;
in vec3 pos;

out vec3 color;

void main() {
	gl_Position = vec4(pos.xy, 0.5, 1.0);
	color = col;
}
