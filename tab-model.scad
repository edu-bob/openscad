$fn=40;
module origin(len)
{
	rotate([0,0,0]) {
		#translate([0,0,-len/2]) cylinder(len,r=0.1);
		translate([0,0,len/2]) color("Blue") cylinder(.75, r1=0.4, r2=0);
	}
	rotate([-90,0,0]) {
		#translate([0,0,-len/2]) cylinder(len,r=0.1);
		translate([0,0,len/2]) color("Green") cylinder(.75, r1=0.4, r2=0);
	}
	rotate([0,90,0]) {
		#translate([0,0,-len/2]) cylinder(len,r=0.1);
		translate([0,0,len/2]) color("Red") cylinder(.75, r1=0.4, r2=0);
	}
}

module side_piece()
{
	union() {
		cube([side_thickness, blade_height-taper_height, side_width]);
//		origin(20);
		difference() {
			translate([0,-prop_overlap,-prop_height]) 
				cube([side_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height, -prop_height]) 
				rotate([0,90,0]) cylinder(side_thickness+e, r=prop_height, $fn=80);
		}
		difference() {
			translate([0,-prop_overlap,side_width-prop_overlap]) 
				cube([side_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height,side_width+prop_height]) rotate([0,90,0])
				cylinder(side_thickness+e, r=prop_height, $fn=80);
		}
		translate([0, blade_height-taper_height, 0]) {
			polyhedron(points=[
				[0,0,0],
	 			[0,0,side_width],
				[0,taper_height, side_width-(side_width-side_top_width)/2],
				[0,taper_height, (side_width-side_top_width)/2],
				[side_thickness,0,0],
	 			[side_thickness,0,side_width],
				[side_thickness,taper_height, side_width-(side_width-side_top_width)/2],
				[side_thickness,taper_height, (side_width-side_top_width)/2]
		], faces=[[0,3,2,1], [0,4,7,3], [4,5,6,7], [1,2,6,5], [2,3,7,6], [0, 1, 5, 4]
		]);
		translate([0,taper_height,side_width/2]) 
			rotate([0,90,0]) 
			cylinder(side_thickness, r=side_top_width/2);
		}
	}
}


module support()
{
	union() {
		cube([support_thickness, support_lower_height, support_lower_width]);
		difference() {
			translate([0,-prop_overlap,support_lower_width-prop_overlap]) 
				cube([support_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height,support_lower_width+prop_height]) rotate([0,90,0])
				cylinder(support_thickness+e, r=prop_height, $fn=80);
		}
		difference() {
			translate([0,-prop_overlap,-prop_height]) 
				cube([support_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height,-prop_height]) rotate([0,90,0])
				cylinder(support_thickness+e, r=prop_height, $fn=80);
		}

		translate([0,support_lower_height, 0])
			polyhedron(points=[
				[0,0,0],
	 			[0,0,support_lower_width],
				[support_thickness_delta,support_upper_height, support_lower_width-(support_lower_width-support_upper_width)/2],
				[support_thickness_delta,support_upper_height, (support_lower_width-support_upper_width)/2],
				[support_thickness,0,0],
	 			[support_thickness,0,support_lower_width],
				[support_thickness-support_thickness_delta,support_upper_height, support_lower_width-(support_lower_width-support_upper_width)/2],
				[support_thickness-support_thickness_delta,support_upper_height, (support_lower_width-support_upper_width)/2]
		], faces=[[0,3,2,1], [0,4,7,3], [4,5,6,7], [1,2,6,5], [2,3,7,6], [0, 1, 5, 4]
		]);
	}
}

module screw_head(thick=thickness)
{
	union() {
  		cylinder(1,r=screw_head_d/2);
 		translate([0,0,0.99]) cylinder(screw_head_h,r1=screw_head_d/2, r2=screw_shaft_d/2);
   	translate([0,0,0.99]) cylinder(thick+2,r=screw_shaft_d/2);
	}
}

//origin(60.0);

// All measurements are in mm

e = 0.1;

thickness=2.1;
blade_width=17;
blade_height=21.7-thickness;
side_thickness=2.5;
side_width=5;
side_top_width=3;
taper_height=5;
center_gap=5.45;

ridge_offset=15;
ridge_depth=0.5; // protrusion, in Z
ridge_height=1;
prop_overlap = thickness/2;
prop_height = blade_height-ridge_offset-ridge_height;

support_thickness=1.5;
support_lower_width=5;
support_upper_width=thickness;
support_lower_height=blade_height-ridge_offset-ridge_height/2;
support_upper_height=blade_height-prop_height*2;
support_top_thickness=0.5;
support_thickness_delta=(support_thickness-support_top_thickness)/2;
insertion_depth=16.5;

ridge_length=center_gap+support_thickness;

short_side=5.5; // distance from blade to edge of the available space

screw_head_d=5;
screw_shaft_d=2.5;
screw_head_h=1.5;

screwhole_d=4;

base_x=50;
base_z=35;
base_radius=base_x/2;

//	origin(50);
color("Gray")
rotate([90,0,0]) {
	difference() {
		union() {
			difference() {
				translate([0,0,-thickness/2]) cube([blade_width, blade_height, thickness]);
				translate([blade_width/2-ridge_length/2,blade_height-ridge_offset,thickness/2]) 
					rotate([0,90,0]) 
					scale([1,ridge_height/ridge_depth,1]) cylinder(ridge_length,r=ridge_depth/2);
	
				translate([blade_width/2-ridge_length/2,blade_height-ridge_offset,-thickness/2]) 
					rotate([0,90,0]) 
					scale([1,ridge_height/ridge_depth,1]) cylinder(ridge_length,r=ridge_depth/2);
				}
			translate([-side_thickness,0, -side_width/2]) side_piece();
			translate([blade_width, 0, -side_width/2]) side_piece();
		
			translate([blade_width/2-center_gap/2-support_thickness,0,-support_lower_width/2]) support();
			translate([blade_width/2+center_gap/2,0,-support_lower_width/2]) support();
			difference() {
				// The base platform
				union() {
					translate([blade_width/2,0,0]) {
						rotate([90,0,0]) 
							scale([1,base_z/base_x,1]) 
							cylinder(thickness,r=base_radius, $fn=100);
		//				rotate([90,0,0]) 
		//					rotate_extrude(convexity = 10) 
		//					translate([base_radius,thickness,0]) 
		//					circle(r=thickness);
					}
				}
				// The screw heads
				translate([-side_thickness-(base_radius*2-(side_thickness*2+blade_width))/2+screw_head_d*1.5,0.5*thickness,0]) rotate([90,0,0]) 
						screw_head();
		// 			cylinder(thickness*2,r=screwhole_d/2);
				translate([blade_width+side_thickness+(base_radius*2-(side_thickness*2+blade_width))/2-screw_head_d*1.5,0.5*thickness,0]) rotate([90,0,0]) 
						screw_head();
		//				cylinder(thickness*2,r=screwhole_d/2);
				translate([blade_width/2,0.5*thickness,-base_z/2+screw_head_d*1.5]) rotate([90,0,0]) 
						screw_head();
			}
		}
		// the flat side
		translate([-base_radius+blade_width/2,-thickness-thickness/2,thickness/2+short_side])
		cube([base_radius*2, thickness*2, base_z/2-short_side+e]);
}
// When 2014 QX is released:
//	translate([0,20,0]) scale([1, 1, 0.1])
//  	surface(file = "crlb.png", center = true, invert = true);
}

