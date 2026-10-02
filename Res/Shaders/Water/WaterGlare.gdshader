shader_type canvas_item;
render_mode unshaded;

uniform float scale = 0.5;
uniform float speed = 0.8;
uniform vec4 tint:source_color  = vec4(1.0, 0.7, 0.4, 1.0);

void fragment() {
	vec4 Tcolor = texture(TEXTURE, UV);
	Tcolor*=tint;
	vec4 k = vec4(TIME)*speed;
	k.xy = UV*100.0/scale;
	mat3 glare_mat = mat3(vec3(-1.0,-1.0,0.0),vec3(-1.0,-0.5,-1.0),vec3(1.0,-3.0,-1.0));
	float val = length(0.5-fract(k.xyw*=glare_mat*0.5));
	val = min(val,length(0.5-fract(k.xyw*=glare_mat*0.2)));
	val = pow(min(val,length(0.5-fract(k.xyw*=glare_mat*0.45))),7.0);
	Tcolor.rgb +=vec3(val);
	COLOR = Tcolor;
}