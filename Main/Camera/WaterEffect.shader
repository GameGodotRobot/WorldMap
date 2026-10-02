shader_type canvas_item;

void vertex(){
	float uv_y = 4.0*sin(TIME+UV.x*2.0+UV.y*0.5);
	VERTEX.y += uv_y;
}