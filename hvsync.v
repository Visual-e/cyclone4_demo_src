
///////////////////////////////////////////////////////////////
//module which generates video sync impulses
///////////////////////////////////////////////////////////////

module hvsync (
	// inputs:
	input wire pixel_clock,
	input wire [2:0]tumblers,
	input wire reset,
	
	// outputs:
	output reg hsync,
	output reg vsync,

	//high-color test video signal
	output wire [4:0]r,
	output wire [5:0]g,
	output wire [4:0]b
	);
	

	// video signal parameters, default 640x480 60Hz
/*	parameter horz_front_porch = 16;
	parameter horz_sync = 96;
	parameter horz_back_porch = 48;
	parameter horz_addr_time = 640;
	
	parameter vert_front_porch = 10;
	parameter vert_sync = 2;
	parameter vert_back_porch = 33;
	parameter vert_addr_time = 480;*/
	
	// video signal parameters, default 1280x1024 60Hz
	parameter horz_front_porch = 48;
	parameter horz_sync = 112;
	parameter horz_back_porch = 248;
	parameter horz_addr_time = 1280;
	
	parameter vert_front_porch = 1;
	parameter vert_sync = 3;
	parameter vert_back_porch = 38;
	parameter vert_addr_time = 1024;
	
	//variables	
	reg [11:0]pixel_count = 0;
	reg [11:0]line_count = 0;

	//variables	
	reg [11:0] x;
	reg [11:0] y;

	wire [7:0]rr;
	wire [7:0]gg;
	wire [7:0]bb;
	
//	assign r = visible &&( frameCounter[6] || ( y<800 && x<800 && y>400 && x>400)) ? 8'hFF :0;
//	assign g = visible &&( frameCounter[7] || ( y<800 && x<800 && y>400 && x>400)) ? 8'hFF :0;
//	assign b = visible &&( frameCounter[8] || ( y<800 && x<800 && y>400 && x>400)) ? 8'hFF :0;
//	
//	assign r = frameCounter[6] || ( y<800 && x<800 && y>400 && x>400) ? rr[7:3] :0;
//	assign g = frameCounter[7] || ( y<800 && x<800 && y>400 && x>400) ? gg[7:2] :0;
//	assign b = frameCounter[8] || ( y<800 && x<800 && y>400 && x>400) ? bb[7:3] :0;
//	
	assign r = visible? rr[7:3] :0;
	assign g = visible? gg[7:2] :0;
	assign b = visible? bb[7:3] :0;
	
reg hvisible = 1'b0;
reg vvisible = 1'b0;

//synchronous process
always @(posedge pixel_clock)
begin
	hsync <= (pixel_count < horz_sync);
	hvisible <= (pixel_count >= (horz_sync+horz_back_porch)) && 
		(pixel_count < (horz_sync+horz_back_porch+horz_addr_time));
	
	if(pixel_count < (horz_sync+horz_back_porch+horz_addr_time+horz_front_porch) )
		pixel_count <= pixel_count + 1'b1;
	else
		pixel_count <= 0;
	if ( hvisible )
		x <= x+1;
	else
		x <=0;
end

always @(posedge hsync)
begin
	vsync <= (line_count < vert_sync);
	vvisible <= (line_count >= (vert_sync+vert_back_porch)) && 
		(line_count < (vert_sync+vert_back_porch+vert_addr_time));
	
	if(line_count < (vert_sync+vert_back_porch+vert_addr_time+vert_front_porch) )
		line_count <= line_count + 1'b1;
	else
		line_count <= 0;
	if ( vvisible )
		y <= y+1;
	else
		y <=0;
end

reg [15:0]frameCounter;

always @(posedge vvisible)
begin
	frameCounter <= frameCounter+1;
end

wire visible; assign visible = hvisible & vvisible;

Ibniz_adapter ibnitz_adapt( .clk( pixel_clock ), .rst( reset ), 
								.iX_video( x ), .iY_video( y ),
								.oR_video( rr ), .oG_video( gg ), .oB_video( bb ),
								.tumblers( tumblers ), .endFrame( ~vvisible && y!=0 && pixel_count==0 ),
								.dbg_val( dbg_val_i )
							);

defparam ibnitz_adapt.SCENE_COMPILED= 7;								

endmodule

