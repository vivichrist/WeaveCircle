#version 450

in vec3 color;

out vec4 fragColor;

void main() {
	fragColor = vec4(color.r, color.g, color.b, 0.3);
}
