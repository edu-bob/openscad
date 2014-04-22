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
		cube([side_thickness, height-taper_height, side_width]);
//		origin(20);
		difference() {
			translate([0,-prop_overlap,-prop_height]) 
				cube([side_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height, -prop_height]) 
				rotate([0,90,0]) cylinder(thickness+e, r=prop_height, $fn=80);
		}
		difference() {
			translate([0,-prop_overlap,side_width-prop_overlap]) 
				cube([side_thickness,prop_height+prop_overlap,prop_height+prop_overlap]);
			translate([-e/2,prop_height,side_width+prop_height]) rotate([0,90,0])
				cylinder(thickness+e, r=prop_height, $fn=80);
		}
		translate([0, height-taper_height, 0]) {
			polyhedron(points=[
				[0,0,0],
	 			[0,0,side_width],
				[0,taper_height, side_width-(side_width-top_side_width)/2],
				[0,taper_height, (side_width-top_side_width)/2],
				[side_thickness,0,0],
	 			[side_thickness,0,side_width],
				[side_thickness,taper_height, side_width-(side_width-top_side_width)/2],
				[side_thickness,taper_height, (side_width-top_side_width)/2]
		], faces=[[0,3,2,1], [0,4,7,3], [4,5,6,7], [1,2,6,5], [2,3,7,6]
		]);
		}
	}
}


module support()
{
	union() {
		cube([thickness, support_lower_height, support_lower_width]);
		translate([0,support_lower_height, 0])
			polyhedron(points=[
				[0,0,0],
	 			[0,0,support_lower_width],
				[support_thickness_delta,support_upper_height, support_lower_width-(support_lower_width-support_upper_width)/2],
				[support_thickness_delta,support_upper_height, (support_lower_width-support_upper_width)/2],
				[thickness,0,0],
	 			[thickness,0,support_lower_width],
				[thickness-support_thickness_delta,support_upper_height, support_lower_width-(support_lower_width-support_upper_width)/2],
				[thickness-support_thickness_delta,support_upper_height, (support_lower_width-support_upper_width)/2]
		], faces=[[0,3,2,1], [0,4,7,3], [4,5,6,7], [1,2,6,5], [2,3,7,6]
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

blade_width=18.5;
height=21.7;
thickness=2;
side_thickness=2;
side_width=5;
top_side_width=4;
taper_height=5;
base_radius=25;
center_gap=5.4;
support_lower_width=6;
support_upper_width=2;
support_lower_height=5;
support_upper_height=4;
support_top_thickness=1;
support_thickness_delta=(thickness-support_top_thickness)/2;
insertion_depth=16.5;

screw_head_d=5;
screw_shaft_d=2.5;
screw_head_h=1.5;

screwhole_d=4;

prop_overlap = thickness/2;
prop_height = 3;
origin(25);

color("Gray") union() {
	translate([0,0,-thickness/2]) cube([blade_width, height, thickness]);
	translate([-side_thickness,0, -side_width/2]) side_piece();
	translate([blade_width, 0, -side_width/2]) side_piece();

	translate([blade_width/2-center_gap/2-thickness,0,-support_lower_width/2]) support();
	translate([blade_width/2+center_gap/2,0,-support_lower_width/2]) support();
	difference() {
		union() {
			translate([blade_width/2,0,0]) {
				rotate([90,0,0]) 
					scale([1,.5,1]) 
					cylinder(thickness,r=base_radius, $fn=100);
//				rotate([90,0,0]) 
//					rotate_extrude(convexity = 10) 
//					translate([base_radius,thickness,0]) 
//					circle(r=thickness);
			}
		}
		translate([-side_thickness-(base_radius*2-(side_thickness*2+blade_width))/4,0.5*thickness,0]) rotate([90,0,0]) 
				screw_head();
// 			cylinder(thickness*2,r=screwhole_d/2);
		translate([blade_width+side_thickness+(base_radius*2-(side_thickness*2+blade_width))/4,0.5*thickness,0]) rotate([90,0,0]) 
				screw_head();
//				cylinder(thickness*2,r=screwhole_d/2);
	}
}
