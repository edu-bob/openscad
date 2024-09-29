//
// Split a model at height z and add threads to screw them together
//   rlb408 2023-10
//
// Uses the threads library from https://dkprojects.net/openscad-threads/
// install it into the same directory as this or change the include statement below
//
// The threaded portion is centered on [0,0] on the XY plane and extends in the Z plane.  THreads are
// 45 degrees and shouldn't need support
//
// Parameters:
//   half - either "bottom" or "top" to specify which half to generate.  Ultimately you have to do both
//   z - z value of where to split the model
// Optional:
//   diameter - diameter of the threaded part, Obviously must be smaller than that part of the model
//   pitch - thread pitch in mm, e.g. 1.5mm
//   length = length of the threaded postion
//   thread_slop - extra doameter to make the female part of the thread, on the top piece
//   reverse - if true, place the male thread on the top piece
//
// Children:
//   The model to split.
//
// See the split_test module below for an example of how to use.
//     split(half="bottom", diameter=14, pitch=1.5, length=8) {
//         Your model, centers at origin in x, y, and z
//     }
//
// The halves of the split model are left oriented just as they were in the full model
// 
module split(half="bottom", z=0, diameter=8, pitch=1, length=10, thread_slop = 0.5, reverse=false, thread_angle=45, $fn=60, MAX_XY=500, MAX_Z=500)
{
    $fn = $fn;
    e = 0.05;
    
    // https://github.com/verhas/OpenScad/blob/main/threads.scad
    include <threads.scad>
    
    // Cut out all but the top of the model
    module top(z=z)
    {
        intersection() {
            children();
            translate([-MAX_XY/2, -MAX_XY/2,z]) cube([MAX_XY, MAX_XY, MAX_Z]);
        }
    }
    // Cut out all but the bottom of the model
    module bottom(z=z) 
    {
        difference() {
            children();
            translate([-MAX_XY/2, -MAX_XY/2, z]) cube([MAX_XY, MAX_XY, MAX_Z]);
        }
    }
    // the female end of the thread, tapers in for easier starts
    module female_thread(diameter=diameter,pitch=pitch, lenght=length)
    {
        inset = pitch * 0.25;
        translate([0,0,0]) {
            metric_thread(internal=true, diameter=diameter+thread_slop, pitch=pitch, length=length, angle=thread_angle);
            cylinder(d=diameter+pitch, h=inset);
            translate([0,0,inset])
            cylinder(d1=diameter+pitch, d2=diameter-pitch,h=pitch);
            
        }
    }
    if ( half=="bottom" ) {
        if ( reverse ) {
           difference() {
                bottom(z=z) children();
                translate([0,0,z]) rotate([180,0,0]) female_thread(diameter=diameter,pitch=pitch, lenght=length);
            }
        } else {
            // Add the external threaded part to the bottom half
            bottom(z=z) children();
            translate([0,0,z-e]) {
                metric_thread(diameter=diameter, pitch=pitch, length=length, leadin=1, leadfac=2, angle=thread_angle);
            }
        }
    } else if ( half == "top" ) {
        if ( reverse ) {
            top(z=z) children();
            translate([0,0,z-length+e]) {
                metric_thread(diameter=diameter, pitch=pitch, length=length, leadin=3, leadfac=2, angle=thread_angle);
            }
        } else {
            // Remove the internal threaded part from the top half
            difference() {
                top(z=z) children();
                translate([0,0,z-e]) 
                female_thread(diameter=diameter,pitch=pitch, lenght=length);
            }
        }
    } else {
        #text(str("\"half\" must be \"bottom\" or \"top\", is ", half),halign="center");
    }
}
//
// Test Code
//


// Draw a hexagon and split it in the middle with threads
module split_test()
{
    module hexagon(d=20, h=10) {
      for (r = [-60, 0, 60]) rotate([0,0,r]) translate([0,0,h/2]) cube([d/1.75, d, h], true);
    }
//    !shape();
    e = 0.05;
    h = 20;
    d = 22;
    split_at = h/2.5;
    
    // set to true to generate one printable type, to test the threads
    //    false ... generate  (normal,reversed) x (top,bottom) as full test
    printable = true;

    // the test shape is a tall hexagon with an index peg and the words TOP and BOTTOM on the ends
    module shape(h=h, d=d) {
        difference() {
            translate([0,0,0]) {
                hexagon(d=d, h=h);
                // an index peg to make sure that the pieces align when tight
                translate([-1,-d/2-1,0]) cube([2,d+1,20]);
            }
            translate([0,0,h-0.95])
            linear_extrude(1) text("TOP",size=d/4, halign="center", valign="center");
            translate([0,0,-e]) linear_extrude(1) mirror([1,0]) text("BOTTOM",size=d/7, halign="center", valign="center");
        }
    }
    if ( printable ) {
        // Bottom half
        split(half="bottom", z=split_at, diameter=14, pitch=1.5, length=8, reverse=false) shape();
        // Top half
        rotate([180,0,0]) 
        translate([d*1.5,0,-h]) {
            split(half="top", z=split_at, diameter=14, pitch=1.5, length=8, reverse=false) shape();
        }
    } else { // all cases
        // reverse = false
        translate([-(d/2+6),0,0]) linear_extrude(1) text("reverse=false",halign="right",valign="center");
        // Bottom half
        split(half="bottom", z=split_at, diameter=14, pitch=1.5, length=8, reverse=false) shape();
        // Top half
        translate([d*1.5,0,0]) {
            split(half="top", z=split_at, diameter=14, pitch=1.5, length=8, reverse=false) shape();
        }
        translate([0,d*1.5,0]) {
            translate([-(d/2+6),0,0]) linear_extrude(1) text("reverse=true",halign="right",valign="center");
            // Bottom half
            split(half="bottom", z=split_at, diameter=14, pitch=1.5, length=8, reverse=true) shape();
            // Top half
            translate([d*1.5,0,0]) {
                split(half="top", z=split_at, diameter=14, pitch=1.5, length=8, reverse=true) shape();
            }
        }
    }
}

// Another test module

module split_test2()
{
    $fn = 200;
    d = 100;
    h = 40;
    module torus(d,h)
    {
        translate([0,0,h/2])
        rotate_extrude()
        translate([d/2-h/2,0,0])
        circle(d=h);
    }
    module shape()
    {
        difference() {
            cylinder(h=h,d=d-h);
            torus(d=d,h=h);
        }
    }
    shape();
    translate([(d-h)+5,0,0]) {
        split(half="bottom", z=h/2, diameter=(d-2*h)/2, pitch=1.5, length=8) shape();
        translate([(d-h)+5,0,0]) translate([0,0,h]) rotate([180,0,0]) {
            split(half="top", z=h/2, diameter=(d-2*h)/2, pitch=1.5, length=8) shape();
        }
    }
}

//split_test();
