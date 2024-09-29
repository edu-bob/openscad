# split.scad

Split.scad is an OpenSCAD module to split a model in half on the XY plane and create screw threads thread between the two parts.

![Example](image.png)

## Usage

```
include <split.scad>;
```

See the **Examples** section below.

The threaded portion is centered on [0,0] on the XY plane and extends in the Z plane.  THreads are cut with 45 degree edges and shouldn't need support.

### Required Parameters

*half* - either "bottom" or "top" to specify which half to generate.  Ultimately you have to do both.  
*z* - z value of where to split the model.  

### Optional Parameters

*diameter* - diameter of the threaded part. Must be smaller than the part of the model at the given z value. Default: 8  
*pitch* - thread pitch in mm, e.g. 1.5. Default: 1  
*length* - length of the threaded postion. Default: 10  
*thread_slop* - extra doameter to make the female part of the thread, on the top piece, to allow for printer variations. Default: 0.5  
*reverse* - if true, place the male thread on the top piece. Default: false  
*thread_angle* - angle of the sides of the threads. Default: 45  
*MAX_XY* - X & Y size of the cube used in intersection() to split the model. Default: 500  
*MAX_Z* - Z size of the cube used in intersection() to split the model. Default: 500  
$fn - override for openscad's $fn. Default: 60  

### Children

The model to split.
   
### Examples

See the split_test or split_test2 module in the code for an example of how to use.

This is how you generate just the bottom half:

```
split(half="bottom", diameter=14, pitch=1.5, length=8) {
      Your model, centered at origin in x and y
}
```
or, for the top; you need to rotate this portion in X or Y and position it on the bed:
```
translate([0,0,-MODEL_HEIGHT])
rotate([180,0,0])
split(half="top",diameter=14, pitch=1.5, length=8) {
    Your model again
}
```

The halves of the split model are left oriented just as they were in the full model which is why you need to reposition the top half.

## License

[MIT](https:choosealicense.com/licenses/mit/)